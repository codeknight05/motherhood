import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/community_provider.dart';
import '../../../core/services/community_service.dart';
import '../../../core/services/supabase_service.dart';
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
    'All Posts', 'Questions', 'Wins & Milestones', 'Rants & Raves', 'Resources'
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
      case 1: return all.where((p) => p.tag == 'Question').toList();
      case 2: return all.where((p) => p.tag == 'Win & Milestone').toList();
      case 3: return all.where((p) => p.tag == 'Rant & Rave').toList();
      case 4: return all.where((p) => p.tag == 'Resource').toList();
      default: return all;
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
        onPressed: () => _showCreatePost(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.edit_rounded, size: 18),
        label: Text('Create Post',
            style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _buildFeedHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeroBanner(),
        _buildQuickActions(),
      ],
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
        icon: const Icon(Icons.arrow_back_rounded,
            color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(_info.name, style: AppTextStyles.headlineMedium),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: AppColors.textPrimary, size: 22),
          onPressed: () {},
        ),
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
            labelStyle: AppTextStyles.titleMedium
                .copyWith(color: AppColors.primary),
            unselectedLabelStyle: AppTextStyles.titleMedium
                .copyWith(color: AppColors.textSecondary),
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingL),
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
        AppConstants.paddingL, AppConstants.paddingS,
        AppConstants.paddingL, 0,
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
                Text('Hello, Mama! 👋',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: _info.color)),
                const SizedBox(height: 2),
                Text(_info.name,
                    style: AppTextStyles.headlineLarge
                        .copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text(_info.description,
                    style: AppTextStyles.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_outline_rounded,
                            size: 14, color: AppColors.textSecondary),
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
                            width: 7, height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.accentGreen,
                              shape: BoxShape.circle,
                            )),
                        const SizedBox(width: 4),
                        Text('${_info.activeCount} active',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.accentGreen)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => ref
                          .read(communityProvider.notifier)
                          .toggleJoin(_info.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isJoined
                              ? AppColors.background
                              : _info.color,
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusFull),
                          border: Border.all(
                            color: isJoined
                                ? AppColors.divider
                                : _info.color,
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
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: _info.color.withValues(alpha: 0.08),
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Center(
              child: Text(_info.emoji,
                  style: const TextStyle(fontSize: 40)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.waving_hand_rounded, 'label': 'Introduce\nyourself'},
      {'icon': Icons.help_outline_rounded, 'label': 'Ask a\nquestion'},
      {'icon': Icons.edit_note_rounded, 'label': 'Share an\nupdate'},
      {'icon': Icons.bar_chart_rounded, 'label': 'Poll'},
      {'icon': Icons.menu_book_rounded, 'label': 'Resources'},
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
              onTap: () => _showCreatePost(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Icon(a['icon'] as IconData,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    a['label'] as String,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textSecondary),
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

  void _showCreatePost(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreatePostSheet(
        communityId: _info.id,
        onPost: (content, tag) async {
          final messenger = ScaffoldMessenger.of(context);
          final ok = await ref
              .read(postsProviderFamily(_info.id).notifier)
              .createPost(content: content, tag: tag);
          if (ok && mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: const Text('Post shared with the community!'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusM)),
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
            color: AppColors.primary, strokeWidth: 2.5),
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
                Text('Be the first to post here!',
                    style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        )
      else
        ...posts.map((p) => _PostCard(
              post: p,
              communityId: communityId,
            )),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
          AppConstants.paddingL, 0, AppConstants.paddingL, 100),
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
    'Rant & Rave': Color(0xFFFF6D00),
    'Resource': Color(0xFF00C853),
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
                const Icon(Icons.push_pin_rounded,
                    size: 13, color: AppColors.primary),
                const SizedBox(width: 4),
                Text('Pinned',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.primary)),
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
                    Text(post.authorName,
                        style: AppTextStyles.titleMedium),
                    Text(post.timeAgo,
                        style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
              if (isMyPost)
                GestureDetector(
                  onTap: () => _confirmDelete(context, ref),
                  child: const Icon(Icons.more_horiz_rounded,
                      size: 18, color: AppColors.textHint),
                )
              else
                const Icon(Icons.more_horiz_rounded,
                    size: 18, color: AppColors.textHint),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          // Content
          Text(post.content,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textPrimary)),
          // Tag
          if (post.tag != null) ...[
            const SizedBox(height: AppConstants.paddingS),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tagColor.withValues(alpha: 0.12),
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusFull),
              ),
              child: Text(post.tag!,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: tagColor,
                    fontWeight: FontWeight.w700,
                  )),
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
                    Text('${post.likeCount}',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.paddingXL),
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('${post.commentCount} comments',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ],
      ),
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
            Text('This cannot be undone.',
                style: AppTextStyles.bodyMedium),
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

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final String? url;
  const _Avatar({required this.name, this.url});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: url != null && url!.isNotEmpty
          ? Image.network(url!, width: 40, height: 40, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback())
          : _fallback(),
    );
  }

  Widget _fallback() => Container(
        width: 40, height: 40,
        color: AppColors.primaryLight,
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '👩',
            style: AppTextStyles.titleMedium
                .copyWith(color: AppColors.primary),
          ),
        ),
      );
}

// ── Create Post Sheet ─────────────────────────────────────────────────────────

class _CreatePostSheet extends StatefulWidget {
  final String communityId;
  final Future<void> Function(String content, String? tag) onPost;

  const _CreatePostSheet({
    required this.communityId,
    required this.onPost,
  });

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _controller = TextEditingController();
  String? _selectedTag;
  bool _isPosting = false;

  static const _tags = [
    'Question', 'Win & Milestone', 'Rant & Rave', 'Resource', 'General'
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingL),
      padding: EdgeInsets.only(
        left: AppConstants.paddingXL,
        right: AppConstants.paddingXL,
        top: AppConstants.paddingXL,
        bottom: AppConstants.paddingXL + bottomInset,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingL),
            Text('Create Post', style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppConstants.paddingXL),
            TextField(
              controller: _controller,
              maxLines: 5,
              maxLength: 500,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Share something with the community...',
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusM),
                  borderSide: BorderSide.none,
                ),
                counterStyle: AppTextStyles.labelSmall,
              ),
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppConstants.paddingM),
            Text('Tag your post', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.paddingS),
            Wrap(
              spacing: AppConstants.paddingS,
              runSpacing: AppConstants.paddingS,
              children: _tags.map((tag) {
                final isSelected = _selectedTag == tag;
                return GestureDetector(
                  onTap: () => setState(
                      () => _selectedTag = isSelected ? null : tag),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(
                          AppConstants.radiusFull),
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
                        setState(() => _isPosting = true);
                        final nav = Navigator.of(context);
                        await widget.onPost(
                            _controller.text.trim(), _selectedTag);
                        if (mounted) nav.pop();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primaryMid,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusM),
                  ),
                  elevation: 0,
                ),
                child: _isPosting
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('Post to Community',
                        style: AppTextStyles.titleMedium
                            .copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
