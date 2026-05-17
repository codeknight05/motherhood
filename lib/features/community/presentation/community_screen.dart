import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import 'communities_list_screen.dart';

// ── Sample data ───────────────────────────────────────────────────────────────

class _Post {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String authorBadge; // e.g. 'New Member', 'Top Contributor'
  final String authorBadgeEmoji;
  final String authorSub; // e.g. '8w pregnant · Jan 2026'
  final String content;
  final String? tag; // e.g. 'Question', 'Win & Milestone'
  final Color? tagColor;
  final int likes;
  final int comments;
  final String timeAgo;

  const _Post({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.authorBadge,
    required this.authorBadgeEmoji,
    required this.authorSub,
    required this.content,
    this.tag,
    this.tagColor,
    required this.likes,
    required this.comments,
    required this.timeAgo,
  });
}

const _pinnedPost = _Post(
  id: 'pinned',
  authorName: 'Admin',
  authorAvatar: '',
  authorBadge: '',
  authorBadgeEmoji: '',
  authorSub: 'Jan 1, 2025',
  content:
      'Welcome January 2026 Moms! 💜\nIntroduce yourself, share a little about your due date, and let\'s build a caring and supportive community together.',
  likes: 128,
  comments: 56,
  timeAgo: 'Jan 1, 2025',
);

final _allPosts = <_Post>[
  const _Post(
    id: '1',
    authorName: 'Neha Sharma',
    authorAvatar: 'https://i.pravatar.cc/150?img=47',
    authorBadge: 'New Member',
    authorBadgeEmoji: '',
    authorSub: '8w pregnant · Jan 2026',
    content:
        'Hi everyone! I\'m Neha, 8 weeks pregnant with my first baby 💕\nSo excited (and a little nervous 😅). Can\'t wait to connect with all of you!',
    likes: 32,
    comments: 18,
    timeAgo: '2h ago',
  ),
  const _Post(
    id: '2',
    authorName: 'Ayesha Khan',
    authorAvatar: 'https://i.pravatar.cc/150?img=32',
    authorBadge: 'Top Contributor',
    authorBadgeEmoji: '🏅',
    authorSub: '12w pregnant · Jan 2026',
    content:
        'Nausea got me like 🤢 any tips that actually helped you in the first trimester?',
    tag: 'Question',
    tagColor: Color(0xFF7C4DFF),
    likes: 0,
    comments: 24,
    timeAgo: '5h ago',
  ),
  const _Post(
    id: '3',
    authorName: 'Pooja Mehta',
    authorAvatar: 'https://i.pravatar.cc/150?img=25',
    authorBadge: 'Top Contributor',
    authorBadgeEmoji: '🏅',
    authorSub: '20w pregnant · Jan 2026',
    content:
        'Had my anomaly scan today and everything looks perfect! Feeling so grateful and relieved 🙏 💜',
    tag: 'Win & Milestone',
    tagColor: Color(0xFFFF80AB),
    likes: 89,
    comments: 42,
    timeAgo: '1d ago',
  ),
  const _Post(
    id: '4',
    authorName: 'Riya Patel',
    authorAvatar: 'https://i.pravatar.cc/150?img=44',
    authorBadge: 'New Member',
    authorBadgeEmoji: '',
    authorSub: '6w pregnant · Jan 2026',
    content:
        'Just found out I\'m pregnant! Still in shock but so happy 🥹 This is my second pregnancy and I\'m already feeling more tired than the first time.',
    likes: 54,
    comments: 12,
    timeAgo: '2d ago',
  ),
];

final _questionPosts = _allPosts.where((p) => p.tag == 'Question').toList();
final _milestonePosts = _allPosts.where((p) => p.tag == 'Win & Milestone').toList();

// ── Screen ────────────────────────────────────────────────────────────────────

class CommunityScreen extends StatefulWidget {
  final CommunityInfo? community;

  const CommunityScreen({super.key, this.community});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Map<String, bool> _liked = {};

  static const _tabs = ['All Posts', 'Questions', 'Wins & Milestones', 'Rants & Raves', 'Resources'];

  // Convenience getter — falls back to the default "January 2026 Moms" data
  CommunityInfo get _info => widget.community ?? const CommunityInfo(
    id: 'jan2026moms',
    name: 'January 2026 Moms',
    description: 'A safe space for moms due in January 2026 to connect, share and support each other.',
    emoji: '🤱',
    color: AppColors.primary,
    colorLight: AppColors.primaryLight,
    memberCount: 2400,
    activeCount: 126,
    category: 'Pregnancy',
    isJoined: true,
    tags: ['Pregnancy', 'Support'],
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_Post> _postsForTab(int index) {
    switch (index) {
      case 1: return _questionPosts;
      case 2: return _milestonePosts;
      default: return _allPosts;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(innerBoxIsScrolled),
        ],
        body: TabBarView(
          controller: _tabController,
          children: List.generate(_tabs.length, (i) {
            final posts = _postsForTab(i);
            return _PostFeed(
              posts: posts,
              liked: _liked,
              onLike: (id) => setState(() {
                _liked[id] = !(_liked[id] ?? false);
              }),
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
        label: Text('Create Post', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
      ),
    );
  }

  // Header shown above the post feed — hero + quick actions + pinned post
  Widget _buildFeedHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeroBanner(),
        _buildQuickActions(),
        _buildPinnedPost(),
        const SizedBox(height: AppConstants.paddingS),
      ],
    );
  }

  Widget _buildAppBar(bool innerBoxIsScrolled) {
    final hasBack = widget.community != null;
    return SliverAppBar(
      pinned: true,
      floating: false,
      forceElevated: innerBoxIsScrolled,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.divider,
      automaticallyImplyLeading: false,
      leading: hasBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: Text(_info.name, style: AppTextStyles.headlineMedium),
      centerTitle: !hasBack,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 22),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textPrimary, size: 22),
          onPressed: () {},
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: _buildTabBar(),
      ),
    );
  }

  Widget _buildHeroBanner() {
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
                Text(
                  'Hello, Mama! 👋',
                  style: AppTextStyles.bodyMedium.copyWith(color: _info.color),
                ),
                const SizedBox(height: 2),
                Text(
                  _info.name,
                  style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary),
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
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Member avatars
                    SizedBox(
                      width: 56,
                      height: 22,
                      child: Stack(
                        children: List.generate(3, (i) => Positioned(
                          left: i * 16.0,
                          child: Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                              color: _info.color.withValues(alpha: 0.3),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                'https://i.pravatar.cc/150?img=${40 + i}',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Text('👩', style: TextStyle(fontSize: 10)),
                                ),
                              ),
                            ),
                          ),
                        )),
                      ),
                    ),
                    Text(
                      _formatCount(_info.memberCount),
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7, height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.accentGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Active now ${_info.activeCount}',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentGreen),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Emoji illustration
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: _info.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Center(
              child: Text(_info.emoji, style: const TextStyle(fontSize: 44)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K Members';
    return '$n Members';
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
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Icon(a['icon'] as IconData, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    a['label'] as String,
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
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

  Widget _buildPinnedPost() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.push_pin_rounded, size: 13, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                'Pinned by Admin',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
              ),
              const Spacer(),
              const Icon(Icons.more_horiz_rounded, size: 16, color: AppColors.textHint),
            ],
          ),
          const SizedBox(height: AppConstants.paddingS),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: const Center(child: Text('📢', style: TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_pinnedPost.content, style: AppTextStyles.bodySmall, maxLines: 3, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Posted by Admin · ${_pinnedPost.timeAgo}',
                          style: AppTextStyles.labelSmall,
                        ),
                        const Spacer(),
                        const Icon(Icons.favorite_rounded, size: 12, color: AppColors.accentPink),
                        const SizedBox(width: 3),
                        Text('${_pinnedPost.likes}', style: AppTextStyles.labelSmall),
                        const SizedBox(width: 8),
                        const Icon(Icons.chat_bubble_outline_rounded, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text('${_pinnedPost.comments}', style: AppTextStyles.labelSmall),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.background,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        dividerColor: AppColors.divider,
        labelStyle: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
        unselectedLabelStyle: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  void _showCreatePost(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreatePostSheet(),
    );
  }
}

// ── Post Feed ─────────────────────────────────────────────────────────────────

class _PostFeed extends StatelessWidget {
  final List<_Post> posts;
  final Map<String, bool> liked;
  final void Function(String id) onLike;
  final Widget? header;

  const _PostFeed({
    required this.posts,
    required this.liked,
    required this.onLike,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty && header == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💬', style: TextStyle(fontSize: 48)),
              const SizedBox(height: AppConstants.paddingL),
              Text('No posts yet', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 6),
              Text('Be the first to post here!', style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      );
    }

    // Build item list: optional header + posts (or empty state)
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
                Text('Be the first to post here!', style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        )
      else
        ...posts.map((p) => _PostCard(
              post: p,
              isLiked: liked[p.id] ?? false,
              onLike: () => onLike(p.id),
            )),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingL, 0,
        AppConstants.paddingL, 100,
      ),
      itemCount: items.length,
      separatorBuilder: (_, i) {
        // No divider before/after the header
        if (header != null && (i == 0)) return const SizedBox.shrink();
        return const Divider(height: 1, color: AppColors.divider);
      },
      itemBuilder: (_, i) => items[i],
    );
  }
}

// ── Post Card ─────────────────────────────────────────────────────────────────

class _PostCard extends StatelessWidget {
  final _Post post;
  final bool isLiked;
  final VoidCallback onLike;

  const _PostCard({required this.post, required this.isLiked, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              ClipOval(
                child: post.authorAvatar.isNotEmpty
                    ? Image.network(
                        post.authorAvatar,
                        width: 40, height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _avatarFallback(post.authorName),
                      )
                    : _avatarFallback(post.authorName),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(post.authorName, style: AppTextStyles.titleMedium),
                        if (post.authorBadge.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: post.authorBadge == 'Top Contributor'
                                  ? AppColors.accentOrangeLight
                                  : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (post.authorBadgeEmoji.isNotEmpty)
                                  Text(post.authorBadgeEmoji, style: const TextStyle(fontSize: 10)),
                                if (post.authorBadgeEmoji.isNotEmpty)
                                  const SizedBox(width: 3),
                                Text(
                                  post.authorBadge,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: post.authorBadge == 'Top Contributor'
                                        ? AppColors.accentOrange
                                        : AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    Text(post.authorSub, style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
              Text(post.timeAgo, style: AppTextStyles.labelSmall),
              const SizedBox(width: 4),
              const Icon(Icons.more_horiz_rounded, size: 18, color: AppColors.textHint),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          // Content
          Text(post.content, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
          // Tag
          if (post.tag != null) ...[
            const SizedBox(height: AppConstants.paddingS),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (post.tagColor ?? AppColors.primary).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              ),
              child: Text(
                post.tag!,
                style: AppTextStyles.labelMedium.copyWith(
                  color: post.tagColor ?? AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppConstants.paddingM),
          // Reactions row
          Row(
            children: [
              GestureDetector(
                onTap: onLike,
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        key: ValueKey(isLiked),
                        size: 18,
                        color: isLiked ? AppColors.accentPink : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likes + (isLiked ? 1 : 0)}',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.paddingXL),
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${post.comments} comments',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(String name) {
    return Container(
      width: 40, height: 40,
      color: AppColors.primaryLight,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '👩',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}

// ── Create Post Sheet ─────────────────────────────────────────────────────────

class _CreatePostSheet extends StatefulWidget {
  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _controller = TextEditingController();
  String? _selectedTag;

  static const _tags = ['Question', 'Win & Milestone', 'Rant & Rave', 'Resource', 'General'];

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
              decoration: InputDecoration(
                hintText: 'Share something with the community...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: BorderSide.none,
                ),
                counterStyle: AppTextStyles.labelSmall,
              ),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
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
                  onTap: () => setState(() => _selectedTag = isSelected ? null : tag),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
                onPressed: _controller.text.trim().isEmpty
                    ? null
                    : () => Navigator.pop(context),
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
                child: Text(
                  'Post to Community',
                  style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
