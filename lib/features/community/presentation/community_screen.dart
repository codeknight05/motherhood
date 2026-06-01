import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/community_provider.dart';
import '../../../core/services/community_service.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/widgets/notifications_sheet.dart';
import 'communities_list_screen.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class CommunityScreen extends ConsumerStatefulWidget {
  final CommunityInfo community;
  const CommunityScreen({super.key, required this.community});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    'All Posts',
    'Questions',
    'Wins & Milestones',
    'Polls',
    'Resources',
  ];

  CommunityInfo get _info => widget.community;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postsProviderFamily(_info.id).notifier).load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<CommunityPost> _postsForTab(List<CommunityPost> all, int index) {
    switch (index) {
      case 1:
        return all.where((p) => p.tag == 'Question').toList();
      case 2:
        return all.where((p) => p.tag == 'Win & Milestone').toList();
      case 3:
        return all.where((p) => p.tag == 'Poll').toList();
      case 4:
        return all.where((p) => p.tag == 'Resource').toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsProviderFamily(_info.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(innerBoxIsScrolled),
        ],
        body: TabBarView(
          controller: _tabController,
          children: List.generate(_tabs.length, (i) {
            final posts = _postsForTab(postsState.posts, i);
            return _PostFeed(
              communityId: _info.id,
              posts: posts,
              isLoading: postsState.isLoading,
              header: i == 0 ? _buildFeedHeader() : null,
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final cs = ref.read(communityProvider);
          if (!cs.isJoined(_info.id)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Join ${_info.name} to post'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                action: SnackBarAction(
                  label: 'Join',
                  textColor: Colors.white,
                  onPressed: () => ref
                      .read(communityProvider.notifier)
                      .toggleJoin(_info.id),
                ),
              ),
            );
            return;
          }
          _showCreatePost(context);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.edit_rounded, size: 18),
        label: Text(
          'Create Post',
          style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFeedHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [_buildHeroBanner(), _buildQuickActions()],
    );
  }

  Widget _buildAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      forceElevated: innerBoxIsScrolled,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.divider,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textPrimary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(_info.name, style: AppTextStyles.headlineMedium),
      actions: [
        const NotificationBell(),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: AppColors.background,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2.5,
            dividerColor: AppColors.divider,
            labelStyle: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primary,
            ),
            unselectedLabelStyle: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingL,
            ),
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    final cs = ref.watch(communityProvider);
    final memberCount = cs.memberCount(_info.id);
    final isJoined = cs.isJoined(_info.id);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppConstants.paddingL,
        AppConstants.paddingS,
        AppConstants.paddingL,
        0,
      ),
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: _info.colorLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hello, Mama! 👋',
                  style: AppTextStyles.bodyMedium.copyWith(color: _info.color),
                ),
                const SizedBox(height: 2),
                Text(
                  _info.name,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _info.description,
                  style: AppTextStyles.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.people_outline_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          memberCount > 0
                              ? '${memberCount >= 1000 ? '${(memberCount / 1000).toStringAsFixed(1)}K' : memberCount} Members'
                              : 'Be the first to join!',
                          style: AppTextStyles.labelMedium,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.accentGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_info.activeCount} active',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.accentGreen,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => ref
                          .read(communityProvider.notifier)
                          .toggleJoin(_info.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isJoined ? AppColors.background : _info.color,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusFull,
                          ),
                          border: Border.all(
                            color: isJoined ? AppColors.divider : _info.color,
                          ),
                        ),
                        child: Text(
                          isJoined ? 'Leave' : 'Join',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isJoined
                                ? AppColors.textSecondary
                                : Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _info.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Center(
              child: Text(_info.emoji, style: const TextStyle(fontSize: 40)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.waving_hand_rounded,
        'label': 'Introduce\nyourself',
        'tag': 'General',
      },
      {
        'icon': Icons.help_outline_rounded,
        'label': 'Ask a\nquestion',
        'tag': 'Question',
      },
      {
        'icon': Icons.edit_note_rounded,
        'label': 'Share an\nupdate',
        'tag': 'Win & Milestone',
      },
      {'icon': Icons.bar_chart_rounded, 'label': 'Poll', 'tag': 'Poll'},
      {
        'icon': Icons.menu_book_rounded,
        'label': 'Resources',
        'tag': 'Resource',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingL,
        vertical: AppConstants.paddingM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((a) {
          return Expanded(
            child: GestureDetector(
              onTap: () =>
                  _showCreatePost(context, preselectedTag: a['tag'] as String),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Icon(
                      a['icon'] as IconData,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    a['label'] as String,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showCreatePost(BuildContext context, {String? preselectedTag}) {
    if (preselectedTag == 'Poll') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _PollSheet(
          communityId: _info.id,
          onPost: (content, tag, imageUrl) async {
            final messenger = ScaffoldMessenger.of(context);
            final ok = await ref
                .read(postsProviderFamily(_info.id).notifier)
                .createPost(content: content, tag: tag, imageUrl: imageUrl);
            if (ok && mounted) {
              messenger.showSnackBar(
                SnackBar(
                  content: const Text('Poll posted to the community!'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                ),
              );
            }
          },
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreatePostSheet(
        communityId: _info.id,
        preselectedTag: preselectedTag,
        onPost: (content, tag, imageUrl) async {
          final messenger = ScaffoldMessenger.of(context);
          final ok = await ref
              .read(postsProviderFamily(_info.id).notifier)
              .createPost(content: content, tag: tag, imageUrl: imageUrl);
          if (ok && mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: const Text('Post shared with the community!'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

// ── Post Feed ─────────────────────────────────────────────────────────────────

class _PostFeed extends ConsumerWidget {
  final String communityId;
  final List<CommunityPost> posts;
  final bool isLoading;
  final Widget? header;

  const _PostFeed({
    required this.communityId,
    required this.posts,
    required this.isLoading,
    this.header,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading && posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.5,
        ),
      );
    }

    final items = <Widget>[
      if (header != null) header!,
      if (posts.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💬', style: TextStyle(fontSize: 48)),
                const SizedBox(height: AppConstants.paddingL),
                Text('No posts yet', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 6),
                Text(
                  'Be the first to post here!',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        )
      else
        ...posts.map((p) => _PostCard(post: p, communityId: communityId)),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingL,
        0,
        AppConstants.paddingL,
        100,
      ),
      itemCount: items.length,
      separatorBuilder: (_, i) {
        if (header != null && i == 0) return const SizedBox.shrink();
        return const Divider(height: 1, color: AppColors.divider);
      },
      itemBuilder: (_, i) => items[i],
    );
  }
}

// ── Post Card ─────────────────────────────────────────────────────────────────

class _PostCard extends ConsumerWidget {
  final CommunityPost post;
  final String communityId;

  const _PostCard({required this.post, required this.communityId});

  static const _tagColors = {
    'Question': Color(0xFF7C4DFF),
    'Win & Milestone': Color(0xFFFF80AB),
    'Resource': Color(0xFF00C853),
    'Poll': Color(0xFF0288D1),
    'General': AppColors.primary,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = SupabaseService.currentUser?.id;
    final isMyPost = myId == post.userId;
    final tagColor = _tagColors[post.tag] ?? AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pinned indicator
          if (post.isPinned) ...[
            Row(
              children: [
                const Icon(
                  Icons.push_pin_rounded,
                  size: 13,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Pinned',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          // Author row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(name: post.authorName, url: post.authorAvatarUrl),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(post.authorName, style: AppTextStyles.titleMedium),
                    Text(post.timeAgo, style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
              if (isMyPost)
                GestureDetector(
                  onTap: () => _confirmDelete(context, ref),
                  child: const Icon(
                    Icons.more_horiz_rounded,
                    size: 18,
                    color: AppColors.textHint,
                  ),
                )
              else
                const Icon(
                  Icons.more_horiz_rounded,
                  size: 18,
                  color: AppColors.textHint,
                ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          // Content
          if (post.tag == 'Poll')
            _PollContent(
              post: post,
              onVote: (optionIndex) => ref
                  .read(postsProviderFamily(communityId).notifier)
                  .votePoll(post.id, optionIndex),
            )
          else
            Text(
              post.content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          // Post image
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingM),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              child: Image.network(
                post.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                        height: 200,
                        color: AppColors.primaryLight,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: AppColors.primaryLight,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: AppColors.primaryMid,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ],
          // Tag
          if (post.tag != null) ...[
            const SizedBox(height: AppConstants.paddingS),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tagColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              ),
              child: Text(
                post.tag!,
                style: AppTextStyles.labelMedium.copyWith(
                  color: tagColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppConstants.paddingM),
          // Reactions
          Row(
            children: [
              GestureDetector(
                onTap: () => ref
                    .read(postsProviderFamily(communityId).notifier)
                    .toggleLike(post.id),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        post.isLikedByMe
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        key: ValueKey(post.isLikedByMe),
                        size: 18,
                        color: post.isLikedByMe
                            ? AppColors.accentPink
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likeCount}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.paddingXL),
              GestureDetector(
                onTap: () => _showReplies(context),
                child: Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.commentCount == 1
                          ? '1 reply'
                          : '${post.commentCount} replies',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (post.replies.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingM),
            _ReplyPreview(
              replies: post.replies,
              replyCount: post.commentCount,
              onViewAll: () => _showReplies(context),
            ),
          ],
        ],
      ),
    );
  }

  void _showReplies(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RepliesSheet(communityId: communityId, postId: post.id),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(AppConstants.paddingL),
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Delete Post?', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text('This cannot be undone.', style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppConstants.paddingXL),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ref
                          .read(postsProviderFamily(communityId).notifier)
                          .deletePost(post.id);
                    },
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PollContent extends StatelessWidget {
  final CommunityPost post;
  final ValueChanged<int> onVote;

  const _PollContent({required this.post, required this.onVote});

  @override
  Widget build(BuildContext context) {
    final poll = _ParsedPoll.tryParse(post.content);
    if (poll == null) {
      return Text(
        post.content,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      );
    }

    final totalVotes = post.pollVoteCounts.values.fold<int>(
      0,
      (total, count) => total + count,
    );
    final hasVoted = post.myPollVote != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.bar_chart_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                poll.question,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingM),
        ...List.generate(poll.options.length, (index) {
          final count = post.pollVoteCounts[index] ?? 0;
          final percent = totalVotes == 0 ? 0.0 : count / totalVotes;
          final isSelected = post.myPollVote == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
            child: GestureDetector(
              onTap: () => onVote(index),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    if (hasVoted)
                      Positioned.fill(
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: percent.clamp(0.0, 1.0),
                          child: ColoredBox(
                            color:
                                (isSelected
                                        ? AppColors.primary
                                        : AppColors.primaryMid)
                                    .withValues(alpha: 0.16),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 18,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textHint,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              poll.options[index],
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (hasVoted) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${(percent * 100).round()}%',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        Text(
          totalVotes == 1 ? '1 vote' : '$totalVotes votes',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ParsedPoll {
  final String question;
  final List<String> options;

  const _ParsedPoll({required this.question, required this.options});

  static _ParsedPoll? tryParse(String content) {
    final lines = content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.length < 3) return null;

    final question = lines.first.replaceFirst(RegExp(r'^📊\s*'), '').trim();
    final options = <String>[];
    final optionPattern = RegExp(r'^\d+[\.)]\s+(.+)$');

    for (final line in lines.skip(1)) {
      final match = optionPattern.firstMatch(line);
      if (match == null) return null;
      options.add(match.group(1)!.trim());
    }

    if (question.isEmpty || options.length < 2) return null;
    return _ParsedPoll(question: question, options: options);
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final String? url;
  final double size;
  const _Avatar({required this.name, this.url, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: url != null && url!.isNotEmpty
          ? Image.network(
              url!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(),
            )
          : _fallback(),
    );
  }

  Widget _fallback() => Container(
    width: size,
    height: size,
    color: AppColors.primaryLight,
    child: Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '👩',
        style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.primary,
          fontSize: size * 0.42,
        ),
      ),
    ),
  );
}

// ── Replies ──────────────────────────────────────────────────────────────────

class _ReplyPreview extends StatelessWidget {
  final List<CommunityReply> replies;
  final int replyCount;
  final VoidCallback onViewAll;

  const _ReplyPreview({
    required this.replies,
    required this.replyCount,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final visible = replies.length <= 2
        ? replies
        : replies.sublist(replies.length - 2);

    return Container(
      padding: const EdgeInsets.only(left: AppConstants.paddingM),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.22),
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: [
          ...visible.map((reply) => _ReplyRow(reply: reply, compact: true)),
          if (replyCount > visible.length) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'View all $replyCount replies',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReplyRow extends StatelessWidget {
  final CommunityReply reply;
  final bool compact;

  const _ReplyRow({required this.reply, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 8 : AppConstants.paddingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(
            name: reply.authorName,
            url: reply.authorAvatarUrl,
            size: compact ? 28 : 34,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(reply.authorName, style: AppTextStyles.labelMedium),
                    Text(reply.timeAgo, style: AppTextStyles.labelSmall),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  reply.content,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RepliesSheet extends ConsumerStatefulWidget {
  final String communityId;
  final String postId;

  const _RepliesSheet({required this.communityId, required this.postId});

  @override
  ConsumerState<_RepliesSheet> createState() => _RepliesSheetState();
}

class _RepliesSheetState extends ConsumerState<_RepliesSheet> {
  final _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxSheetHeight =
        (screenHeight - bottomInset - AppConstants.paddingL * 2)
            .clamp(260.0, screenHeight * 0.82)
            .toDouble();
    final postsState = ref.watch(postsProviderFamily(widget.communityId));
    CommunityPost? post;
    for (final candidate in postsState.posts) {
      if (candidate.id == widget.postId) {
        post = candidate;
        break;
      }
    }
    final replies = post?.replies ?? const <CommunityReply>[];

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        margin: const EdgeInsets.all(AppConstants.paddingL),
        padding: const EdgeInsets.only(
          left: AppConstants.paddingXL,
          right: AppConstants.paddingXL,
          top: AppConstants.paddingXL,
          bottom: AppConstants.paddingL,
        ),
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
        ),
        child: post == null
            ? const SizedBox.shrink()
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                  Text('Replies', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: AppConstants.paddingM),
                  _OriginalPostSummary(post: post),
                  const SizedBox(height: AppConstants.paddingM),
                  Flexible(
                    child: replies.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 28),
                            child: Center(
                              child: Text(
                                'No replies yet',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: replies.length,
                            itemBuilder: (_, i) => _ReplyRow(reply: replies[i]),
                          ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  _buildComposer(post),
                ],
              ),
      ),
    );
  }

  Widget _buildComposer(CommunityPost post) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            minLines: 1,
            maxLines: 4,
            maxLength: 300,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Reply to ${post.authorName}...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
              filled: true,
              fillColor: AppColors.background,
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                borderSide: BorderSide.none,
              ),
            ),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: AppConstants.paddingS),
        IconButton.filled(
          onPressed: _controller.text.trim().isEmpty || _isSending
              ? null
              : () async {
                  setState(() => _isSending = true);
                  final ok = await ref
                      .read(postsProviderFamily(widget.communityId).notifier)
                      .createReply(
                        postId: widget.postId,
                        content: _controller.text.trim(),
                      );
                  if (!mounted) return;
                  setState(() => _isSending = false);
                  if (ok) {
                    _controller.clear();
                    setState(() {});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Could not send reply. Try again.'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusM,
                          ),
                        ),
                      ),
                    );
                  }
                },
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primaryMid,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(14),
          ),
          icon: _isSending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.send_rounded, size: 18),
        ),
      ],
    );
  }
}

class _OriginalPostSummary extends StatelessWidget {
  final CommunityPost post;

  const _OriginalPostSummary({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(name: post.authorName, url: post.authorAvatarUrl, size: 34),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.authorName, style: AppTextStyles.labelMedium),
                const SizedBox(height: 2),
                Text(
                  post.content,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Create Post Sheet ─────────────────────────────────────────────────────────

class _CreatePostSheet extends StatefulWidget {
  final String communityId;
  final String? preselectedTag;
  final Future<void> Function(String content, String? tag, String? imageUrl)
  onPost;

  const _CreatePostSheet({
    required this.communityId,
    required this.onPost,
    this.preselectedTag,
  });

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();
  late String? _selectedTag;
  bool _isPosting = false;
  File? _imageFile;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    _selectedTag = widget.preselectedTag;
  }

  static const _tags = [
    'Question',
    'Win & Milestone',
    'Poll',
    'Resource',
    'General',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (picked != null && mounted) {
      setState(() {
        _imageFile = File(picked.path);
        _uploadError = null;
      });
    }
  }

  Future<void> _takePhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (picked != null && mounted) {
      setState(() {
        _imageFile = File(picked.path);
        _uploadError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxSheetHeight =
        (screenHeight - bottomInset - AppConstants.paddingL * 2)
            .clamp(260.0, screenHeight * 0.9)
            .toDouble();

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        margin: const EdgeInsets.all(AppConstants.paddingL),
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingL),
              Text('Create Post', style: AppTextStyles.headlineMedium),
              const SizedBox(height: AppConstants.paddingXL),
              // Text input
              TextField(
                controller: _controller,
                maxLines: 4,
                maxLength: 500,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Share something with the community...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    borderSide: BorderSide.none,
                  ),
                  counterStyle: AppTextStyles.labelSmall,
                ),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),

              // Image preview
              if (_imageFile != null) ...[
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      child: Image.file(
                        _imageFile!,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _imageFile = null),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingM),
              ],

              // Image picker buttons
              Row(
                children: [
                  _ImagePickerBtn(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: _pickImage,
                  ),
                  const SizedBox(width: AppConstants.paddingS),
                  _ImagePickerBtn(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: _takePhoto,
                  ),
                ],
              ),

              if (_uploadError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _uploadError!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],

              const SizedBox(height: AppConstants.paddingL),
              Text('Tag your post', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppConstants.paddingS),
              Wrap(
                spacing: AppConstants.paddingS,
                runSpacing: AppConstants.paddingS,
                children: _tags.map((tag) {
                  final isSelected = _selectedTag == tag;
                  return GestureDetector(
                    onTap: () {
                      if (tag == 'Poll') {
                        final navigator = Navigator.of(context);
                        final navigatorContext = navigator.context;
                        navigator.pop();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!navigator.mounted) return;
                          showModalBottomSheet(
                            context: navigatorContext,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => _PollSheet(
                              communityId: widget.communityId,
                              onPost: widget.onPost,
                            ),
                          );
                        });
                        return;
                      }
                      setState(() => _selectedTag = isSelected ? null : tag);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusFull,
                        ),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.divider,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.paddingXXL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _controller.text.trim().isEmpty || _isPosting
                      ? null
                      : () async {
                          setState(() {
                            _isPosting = true;
                            _uploadError = null;
                          });
                          final nav = Navigator.of(context);
                          String? imageUrl;
                          // Upload image to Cloudinary if selected
                          if (_imageFile != null) {
                            try {
                              final userId =
                                  SupabaseService.currentUser?.id ??
                                  'community';
                              final url =
                                  await CloudinaryService.uploadMemoryPhoto(
                                    file: _imageFile!,
                                    userId: userId,
                                    babyId: 'community_posts',
                                  );
                              imageUrl = url;
                            } catch (e) {
                              if (mounted) {
                                setState(() {
                                  _isPosting = false;
                                  _uploadError =
                                      'Image upload failed. Try again.';
                                });
                              }
                              return;
                            }
                          }
                          await widget.onPost(
                            _controller.text.trim(),
                            _selectedTag,
                            imageUrl,
                          );
                          if (mounted) nav.pop();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primaryMid,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    elevation: 0,
                  ),
                  child: _isPosting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _imageFile != null
                              ? 'Post with Photo'
                              : 'Post to Community',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Poll Sheet ────────────────────────────────────────────────────────────────

class _PollSheet extends StatefulWidget {
  final String communityId;
  final Future<void> Function(String content, String? tag, String? imageUrl)
  onPost;

  const _PollSheet({required this.communityId, required this.onPost});

  @override
  State<_PollSheet> createState() => _PollSheetState();
}

class _PollSheetState extends State<_PollSheet> {
  final _questionCtrl = TextEditingController();
  final List<TextEditingController> _optionCtrls = [
    TextEditingController(),
    TextEditingController(),
  ];
  bool _isPosting = false;

  @override
  void dispose() {
    _questionCtrl.dispose();
    for (final c in _optionCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionCtrls.length >= 4) return;
    setState(() => _optionCtrls.add(TextEditingController()));
  }

  void _removeOption(int i) {
    if (_optionCtrls.length <= 2) return;
    setState(() {
      _optionCtrls[i].dispose();
      _optionCtrls.removeAt(i);
    });
  }

  bool get _isValid {
    final q = _questionCtrl.text.trim();
    final opts = _optionCtrls.where((c) => c.text.trim().isNotEmpty).toList();
    return q.isNotEmpty && opts.length >= 2;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxSheetHeight =
        (screenHeight - bottomInset - AppConstants.paddingL * 2)
            .clamp(260.0, screenHeight * 0.9)
            .toDouble();

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        margin: const EdgeInsets.all(AppConstants.paddingL),
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingL),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingM),
                  Text('Create Poll', style: AppTextStyles.headlineMedium),
                ],
              ),
              const SizedBox(height: AppConstants.paddingXL),
              // Question
              Text('Your question', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppConstants.paddingS),
              TextField(
                controller: _questionCtrl,
                maxLines: 2,
                maxLength: 200,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Ask the community something...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    borderSide: BorderSide.none,
                  ),
                  counterStyle: AppTextStyles.labelSmall,
                ),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.paddingL),
              // Options
              Text('Options (2–4)', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppConstants.paddingS),
              ...List.generate(_optionCtrls.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingS),
                      Expanded(
                        child: TextField(
                          controller: _optionCtrls[i],
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Option ${i + 1}',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textHint,
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusM,
                              ),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (_optionCtrls.length > 2) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _removeOption(i),
                          child: const Icon(
                            Icons.remove_circle_outline_rounded,
                            color: AppColors.error,
                            size: 20,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
              if (_optionCtrls.length < 4)
                TextButton.icon(
                  onPressed: _addOption,
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    'Add option',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              const SizedBox(height: AppConstants.paddingXL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: !_isValid || _isPosting
                      ? null
                      : () async {
                          setState(() => _isPosting = true);
                          final nav = Navigator.of(context);
                          // Format poll as structured text
                          final opts = _optionCtrls
                              .where((c) => c.text.trim().isNotEmpty)
                              .map((c) => c.text.trim())
                              .toList();
                          final content =
                              '📊 ${_questionCtrl.text.trim()}\n\n${opts.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}';
                          await widget.onPost(content, 'Poll', null);
                          if (mounted) nav.pop();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primaryMid,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    elevation: 0,
                  ),
                  child: _isPosting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Post Poll',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Image picker button ───────────────────────────────────────────────────────

class _ImagePickerBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImagePickerBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: AppColors.primaryMid),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
