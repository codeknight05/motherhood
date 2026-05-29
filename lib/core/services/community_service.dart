import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class CommunityPost {
  final String id;
  final String communityId;
  final String userId;
  final String authorName;
  final String? authorAvatarUrl;
  final String content;
  final String? tag;
  final bool isPinned;
  final int likeCount;
  final int commentCount;
  final bool isLikedByMe;
  final DateTime createdAt;

  const CommunityPost({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.content,
    this.tag,
    this.isPinned = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLikedByMe = false,
    required this.createdAt,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json, String? myUserId) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    final likes = json['post_likes'] as List<dynamic>? ?? [];
    final likeCount = (json['like_count'] as num?)?.toInt() ?? likes.length;
    final isLiked = myUserId != null &&
        likes.any((l) => (l as Map)['user_id'] == myUserId);

    return CommunityPost(
      id: json['id'] as String,
      communityId: json['community_id'] as String,
      userId: json['user_id'] as String,
      authorName: profile?['full_name'] as String? ?? 'Anonymous',
      authorAvatarUrl: profile?['avatar_url'] as String?,
      content: json['content'] as String,
      tag: json['tag'] as String?,
      isPinned: json['is_pinned'] as bool? ?? false,
      likeCount: likeCount,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      isLikedByMe: isLiked,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

// ── Service ───────────────────────────────────────────────────────────────────

class CommunityService {
  CommunityService._();

  static final _client = Supabase.instance.client;

  // ── Member counts ─────────────────────────────────────────────────────────

  /// Returns member count for each community id.
  static Future<Map<String, int>> fetchMemberCounts() async {
    try {
      final res = await _client
          .from('community_members')
          .select('community_id');
      final counts = <String, int>{};
      for (final row in (res as List)) {
        final id = row['community_id'] as String;
        counts[id] = (counts[id] ?? 0) + 1;
      }
      return counts;
    } catch (e) {
      debugPrint('[CommunityService] fetchMemberCounts error: $e');
      return {};
    }
  }

  /// Returns set of community ids the current user has joined.
  static Future<Set<String>> fetchJoinedIds(String userId) async {
    try {
      final res = await _client
          .from('community_members')
          .select('community_id')
          .eq('user_id', userId);
      return (res as List)
          .map((r) => r['community_id'] as String)
          .toSet();
    } catch (e) {
      debugPrint('[CommunityService] fetchJoinedIds error: $e');
      return {};
    }
  }

  /// Join a community.
  static Future<void> joinCommunity(String communityId, String userId) async {
    await _client.from('community_members').upsert({
      'community_id': communityId,
      'user_id': userId,
    }, onConflict: 'community_id,user_id');
  }

  /// Leave a community.
  static Future<void> leaveCommunity(String communityId, String userId) async {
    await _client
        .from('community_members')
        .delete()
        .eq('community_id', communityId)
        .eq('user_id', userId);
  }

  // ── Posts ─────────────────────────────────────────────────────────────────

  /// Fetch posts for a community, newest first. Includes like count + author.
  static Future<List<CommunityPost>> fetchPosts({
    required String communityId,
    String? myUserId,
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      final res = await _client
          .from('community_posts')
          .select('''
            id, community_id, user_id, content, tag, is_pinned, created_at,
            profiles!community_posts_user_id_fkey(full_name, avatar_url),
            post_likes(user_id)
          ''')
          .eq('community_id', communityId)
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (res as List)
          .map((r) => CommunityPost.fromJson(r as Map<String, dynamic>, myUserId))
          .toList();
    } catch (e) {
      debugPrint('[CommunityService] fetchPosts error: $e');
      return [];
    }
  }

  /// Create a new post.
  static Future<CommunityPost?> createPost({
    required String communityId,
    required String userId,
    required String content,
    String? tag,
  }) async {
    try {
      final res = await _client
          .from('community_posts')
          .insert({
            'community_id': communityId,
            'user_id': userId,
            'content': content.trim(),
            if (tag != null) 'tag': tag,
          })
          .select('''
            id, community_id, user_id, content, tag, is_pinned, created_at,
            profiles!community_posts_user_id_fkey(full_name, avatar_url),
            post_likes(user_id)
          ''')
          .single();
      return CommunityPost.fromJson(res, userId);
    } catch (e) {
      debugPrint('[CommunityService] createPost error: $e');
      return null;
    }
  }

  /// Delete a post (only the author can delete).
  static Future<void> deletePost(String postId) async {
    await _client.from('community_posts').delete().eq('id', postId);
  }

  // ── Likes ─────────────────────────────────────────────────────────────────

  /// Toggle like on a post. Returns new like count.
  static Future<int> toggleLike({
    required String postId,
    required String userId,
    required bool currentlyLiked,
  }) async {
    try {
      if (currentlyLiked) {
        await _client
            .from('post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);
      } else {
        await _client.from('post_likes').upsert({
          'post_id': postId,
          'user_id': userId,
        }, onConflict: 'post_id,user_id');
      }
      // Return updated count
      final res = await _client
          .from('post_likes')
          .select('id')
          .eq('post_id', postId);
      return (res as List).length;
    } catch (e) {
      debugPrint('[CommunityService] toggleLike error: $e');
      return 0;
    }
  }
}
