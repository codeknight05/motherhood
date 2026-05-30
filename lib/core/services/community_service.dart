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
  final String? imageUrl;
  final bool isPinned;
  final int likeCount;
  final int commentCount;
  final bool isLikedByMe;
  final DateTime createdAt;
  final List<CommunityReply> replies;

  const CommunityPost({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.content,
    this.tag,
    this.imageUrl,
    this.isPinned = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLikedByMe = false,
    required this.createdAt,
    this.replies = const [],
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
      authorName: profile?['full_name'] as String? ?? 'Community Member',
      authorAvatarUrl: profile?['avatar_url'] as String?,
      content: json['content'] as String,
      tag: json['tag'] as String?,
      imageUrl: json['image_url'] as String?,
      isPinned: json['is_pinned'] as bool? ?? false,
      likeCount: likeCount,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      isLikedByMe: isLiked,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  CommunityPost copyWith({
    String? authorName,
    String? authorAvatarUrl,
    String? content,
    String? tag,
    String? imageUrl,
    bool? isPinned,
    int? likeCount,
    int? commentCount,
    bool? isLikedByMe,
    List<CommunityReply>? replies,
  }) {
    return CommunityPost(
      id: id,
      communityId: communityId,
      userId: userId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      content: content ?? this.content,
      tag: tag ?? this.tag,
      imageUrl: imageUrl ?? this.imageUrl,
      isPinned: isPinned ?? this.isPinned,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      createdAt: createdAt,
      replies: replies ?? this.replies,
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

class CommunityReply {
  final String id;
  final String postId;
  final String userId;
  final String authorName;
  final String? authorAvatarUrl;
  final String content;
  final DateTime createdAt;

  const CommunityReply({
    required this.id,
    required this.postId,
    required this.userId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.content,
    required this.createdAt,
  });

  factory CommunityReply.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return CommunityReply(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      authorName: profile?['full_name'] as String? ?? 'Community Member',
      authorAvatarUrl: profile?['avatar_url'] as String?,
      content: json['content'] as String,
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

  /// Resolves a display name from a profile row.
  /// Priority: full_name → email prefix from auth → first 8 chars of userId
  static String _displayName(Map<String, dynamic> profile, String userId) {
    final fullName = profile['full_name'] as String?;
    if (fullName != null && fullName.trim().isNotEmpty) return fullName.trim();

    // Try to get email from auth user metadata
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && user.id == userId) {
      final email = user.email;
      if (email != null && email.isNotEmpty) {
        // Use the part before @ as display name, capitalize first letter
        final prefix = email.split('@').first;
        return prefix[0].toUpperCase() + prefix.substring(1);
      }
      // Try user metadata (Google sign-in stores name here)
      final meta = user.userMetadata;
      if (meta != null) {
        final name = meta['full_name'] as String? ??
            meta['name'] as String? ??
            meta['display_name'] as String?;
        if (name != null && name.isNotEmpty) return name;
      }
    }

    return 'User ${userId.substring(0, 6)}';
  }

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
          .select('id, community_id, user_id, content, tag, image_url, is_pinned, created_at, post_likes(user_id)')
          .eq('community_id', communityId)
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final posts = (res as List).map((r) {
        final row = r as Map<String, dynamic>;
        return CommunityPost.fromJson(row, myUserId);
      }).toList();

      // Batch-fetch author names from profiles
      final userIds = posts.map((p) => p.userId).toSet().toList();
      var hydratedPosts = posts;
      if (userIds.isNotEmpty) {
        try {
          final profiles = await _client
              .from('profiles')
              .select('id, full_name, avatar_url')
              .inFilter('id', userIds);
          final profileMap = {
            for (final p in (profiles as List))
              (p as Map<String, dynamic>)['id'] as String: p,
          };
          hydratedPosts = posts.map((post) {
            final profile = profileMap[post.userId];
            if (profile == null) return post;
            return post.copyWith(
              authorName: _displayName(profile, post.userId),
              authorAvatarUrl: profile['avatar_url'] as String?,
            );
          }).toList();
        } catch (_) {
          hydratedPosts = posts;
        }
      }
      return _withReplies(hydratedPosts);
    } catch (e) {
      debugPrint('[CommunityService] fetchPosts error: $e');
      return [];
    }
  }

  static Future<List<CommunityPost>> _withReplies(
    List<CommunityPost> posts,
  ) async {
    if (posts.isEmpty) return posts;

    try {
      final postIds = posts.map((p) => p.id).toList();
      final res = await _client
          .from('community_post_replies')
          .select('id, post_id, user_id, content, created_at')
          .inFilter('post_id', postIds)
          .order('created_at', ascending: true);

      final replies = (res as List)
          .map((r) => CommunityReply.fromJson(r as Map<String, dynamic>))
          .toList();

      final userIds = replies.map((r) => r.userId).toSet().toList();
      final profileMap = <String, Map<String, dynamic>>{};
      if (userIds.isNotEmpty) {
        final profiles = await _client
            .from('profiles')
            .select('id, full_name, avatar_url')
            .inFilter('id', userIds);
        for (final p in profiles as List) {
          final profile = p as Map<String, dynamic>;
          profileMap[profile['id'] as String] = profile;
        }
      }

      final byPost = <String, List<CommunityReply>>{};
      for (final reply in replies) {
        final profile = profileMap[reply.userId];
        final hydrated = profile == null
            ? reply
            : CommunityReply(
                id: reply.id,
                postId: reply.postId,
                userId: reply.userId,
                authorName: _displayName(profile, reply.userId),
                authorAvatarUrl: profile['avatar_url'] as String?,
                content: reply.content,
                createdAt: reply.createdAt,
              );
        byPost.putIfAbsent(reply.postId, () => []).add(hydrated);
      }

      return posts.map((post) {
        final postReplies = byPost[post.id] ?? const <CommunityReply>[];
        return post.copyWith(
          replies: postReplies,
          commentCount: postReplies.length,
        );
      }).toList();
    } catch (e) {
      debugPrint('[CommunityService] fetchReplies error: $e');
      return posts;
    }
  }

  /// Create a new post.
  static Future<CommunityPost?> createPost({
    required String communityId,
    required String userId,
    required String content,
    String? tag,
    String? imageUrl,
  }) async {
    try {
      final res = await _client
          .from('community_posts')
          .insert({
            'community_id': communityId,
            'user_id': userId,
            'content': content.trim(),
            if (tag != null) 'tag': tag,
            if (imageUrl != null) 'image_url': imageUrl,
          })
          .select('id, community_id, user_id, content, tag, image_url, is_pinned, created_at, post_likes(user_id)')
          .single();

      final post = CommunityPost.fromJson(res, userId);

      // Fetch author name
      try {
        final profile = await _client
            .from('profiles')
            .select('full_name, avatar_url')
            .eq('id', userId)
            .maybeSingle();
        if (profile != null) {
          return post.copyWith(
            authorName: _displayName(profile, userId),
            authorAvatarUrl: profile['avatar_url'] as String?,
          );
        }
      } catch (_) {}
      return post;
    } catch (e) {
      debugPrint('[CommunityService] createPost error: $e');
      return null;
    }
  }

  /// Delete a post (only the author can delete).
  static Future<void> deletePost(String postId) async {
    await _client.from('community_posts').delete().eq('id', postId);
  }

  /// Reply to a post.
  static Future<CommunityReply?> createReply({
    required String postId,
    required String userId,
    required String content,
  }) async {
    try {
      final res = await _client
          .from('community_post_replies')
          .insert({
            'post_id': postId,
            'user_id': userId,
            'content': content.trim(),
          })
          .select('id, post_id, user_id, content, created_at')
          .single();

      final reply = CommunityReply.fromJson(res);

      try {
        final profile = await _client
            .from('profiles')
            .select('full_name, avatar_url')
            .eq('id', userId)
            .maybeSingle();
        if (profile != null) {
          return CommunityReply(
            id: reply.id,
            postId: reply.postId,
            userId: reply.userId,
            authorName: _displayName(profile, userId),
            authorAvatarUrl: profile['avatar_url'] as String?,
            content: reply.content,
            createdAt: reply.createdAt,
          );
        }
      } catch (_) {}
      return reply;
    } catch (e) {
      debugPrint('[CommunityService] createReply error: $e');
      return null;
    }
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
