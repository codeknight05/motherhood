import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/community_service.dart';
import '../services/supabase_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class CommunityState {
  final Set<String> joinedIds;
  final Map<String, int> memberCounts;
  final bool isLoading;

  const CommunityState({
    this.joinedIds = const {},
    this.memberCounts = const {},
    this.isLoading = false,
  });

  bool isJoined(String id) => joinedIds.contains(id);
  int memberCount(String id) => memberCounts[id] ?? 0;

  CommunityState copyWith({
    Set<String>? joinedIds,
    Map<String, int>? memberCounts,
    bool? isLoading,
  }) {
    return CommunityState(
      joinedIds: joinedIds ?? this.joinedIds,
      memberCounts: memberCounts ?? this.memberCounts,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class CommunityNotifier extends StateNotifier<CommunityState> {
  CommunityNotifier() : super(const CommunityState());

  Future<void> load() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final results = await Future.wait([
        CommunityService.fetchJoinedIds(user.id),
        CommunityService.fetchMemberCounts(),
      ]);
      state = state.copyWith(
        joinedIds: results[0] as Set<String>,
        memberCounts: results[1] as Map<String, int>,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleJoin(String communityId) async {
    final user = SupabaseService.currentUser;
    if (user == null) return;

    final wasJoined = state.isJoined(communityId);
    // Optimistic update
    final newJoined = Set<String>.from(state.joinedIds);
    final newCounts = Map<String, int>.from(state.memberCounts);
    if (wasJoined) {
      newJoined.remove(communityId);
      newCounts[communityId] = (newCounts[communityId] ?? 1) - 1;
    } else {
      newJoined.add(communityId);
      newCounts[communityId] = (newCounts[communityId] ?? 0) + 1;
    }
    state = state.copyWith(joinedIds: newJoined, memberCounts: newCounts);

    try {
      if (wasJoined) {
        await CommunityService.leaveCommunity(communityId, user.id);
      } else {
        await CommunityService.joinCommunity(communityId, user.id);
      }
    } catch (_) {
      // Revert on failure
      state = state.copyWith(
        joinedIds: Set<String>.from(state.joinedIds)
          ..remove(communityId)
          ..addAll(wasJoined ? [communityId] : []),
        memberCounts: Map<String, int>.from(state.memberCounts)
          ..[communityId] = wasJoined
              ? (state.memberCounts[communityId] ?? 0) + 1
              : (state.memberCounts[communityId] ?? 1) - 1,
      );
    }
  }
}

final communityProvider =
    StateNotifierProvider<CommunityNotifier, CommunityState>(
  (_) => CommunityNotifier(),
);

// ── Posts state per community ─────────────────────────────────────────────────

class PostsState {
  final List<CommunityPost> posts;
  final bool isLoading;
  final bool isPosting;
  final String? error;

  const PostsState({
    this.posts = const [],
    this.isLoading = false,
    this.isPosting = false,
    this.error,
  });

  PostsState copyWith({
    List<CommunityPost>? posts,
    bool? isLoading,
    bool? isPosting,
    String? error,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isPosting: isPosting ?? this.isPosting,
      error: error,
    );
  }
}

class PostsNotifier extends StateNotifier<PostsState> {
  final String communityId;
  PostsNotifier(this.communityId) : super(const PostsState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final myId = SupabaseService.currentUser?.id;
      final posts = await CommunityService.fetchPosts(
        communityId: communityId,
        myUserId: myId,
      );
      state = state.copyWith(posts: posts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createPost({required String content, String? tag}) async {
    final user = SupabaseService.currentUser;
    if (user == null) return false;

    state = state.copyWith(isPosting: true);
    try {
      final post = await CommunityService.createPost(
        communityId: communityId,
        userId: user.id,
        content: content,
        tag: tag,
      );
      if (post != null) {
        state = state.copyWith(
          posts: [post, ...state.posts],
          isPosting: false,
        );
        return true;
      }
      state = state.copyWith(isPosting: false);
      return false;
    } catch (e) {
      state = state.copyWith(isPosting: false, error: e.toString());
      return false;
    }
  }

  Future<void> toggleLike(String postId) async {
    final user = SupabaseService.currentUser;
    if (user == null) return;

    final idx = state.posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;

    final post = state.posts[idx];
    // Optimistic update
    final updated = List<CommunityPost>.from(state.posts);
    updated[idx] = CommunityPost(
      id: post.id,
      communityId: post.communityId,
      userId: post.userId,
      authorName: post.authorName,
      authorAvatarUrl: post.authorAvatarUrl,
      content: post.content,
      tag: post.tag,
      isPinned: post.isPinned,
      likeCount: post.isLikedByMe ? post.likeCount - 1 : post.likeCount + 1,
      commentCount: post.commentCount,
      isLikedByMe: !post.isLikedByMe,
      createdAt: post.createdAt,
    );
    state = state.copyWith(posts: updated);

    await CommunityService.toggleLike(
      postId: postId,
      userId: user.id,
      currentlyLiked: post.isLikedByMe,
    );
  }

  Future<void> deletePost(String postId) async {
    await CommunityService.deletePost(postId);
    state = state.copyWith(
      posts: state.posts.where((p) => p.id != postId).toList(),
    );
  }
}

// Family of providers — one per community
final postsProviderFamily =
    StateNotifierProvider.family<PostsNotifier, PostsState, String>(
  (_, communityId) => PostsNotifier(communityId),
);
