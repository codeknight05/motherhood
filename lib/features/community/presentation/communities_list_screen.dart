import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import 'community_screen.dart';

// ── Community model ───────────────────────────────────────────────────────────

class CommunityInfo {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final Color color;
  final Color colorLight;
  final int memberCount;
  final int activeCount;
  final String category;
  final bool isJoined;
  final List<String> tags;

  const CommunityInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.color,
    required this.colorLight,
    required this.memberCount,
    required this.activeCount,
    required this.category,
    this.isJoined = false,
    this.tags = const [],
  });
}

// ── The 5 fixed communities ───────────────────────────────────────────────────

List<CommunityInfo> _buildCommunities() => [
  const CommunityInfo(
    id: 'expecting_moms',
    name: 'Expecting Moms',
    description: 'A warm, supportive space for moms-to-be. Share your pregnancy journey, ask questions, and connect with others due around the same time.',
    emoji: '🤰',
    color: AppColors.primary,
    colorLight: AppColors.primaryLight,
    memberCount: 5800,
    activeCount: 312,
    category: 'Pregnancy',
    isJoined: true,
    tags: ['Pregnancy', 'Due Date', 'Support'],
  ),
  const CommunityInfo(
    id: 'first_time_moms',
    name: 'First-Time Moms',
    description: 'Everything is new and that\'s okay! A judgement-free zone for first-time moms to ask anything, share wins, and survive together.',
    emoji: '🌸',
    color: AppColors.accentPink,
    colorLight: AppColors.accentPinkLight,
    memberCount: 8200,
    activeCount: 540,
    category: 'Parenting',
    tags: ['First-Time', 'Newborn', 'Support'],
  ),
  const CommunityInfo(
    id: 'feeding_nutrition',
    name: 'Feeding & Nutrition',
    description: 'Breastfeeding, formula, solids, and everything in between. Get advice, share recipes, and support each other through feeding challenges.',
    emoji: '🍼',
    color: AppColors.accentGreen,
    colorLight: AppColors.accentGreenLight,
    memberCount: 6400,
    activeCount: 428,
    category: 'Health',
    tags: ['Breastfeeding', 'Solids', 'Nutrition'],
  ),
  const CommunityInfo(
    id: 'sleep_routine',
    name: 'Sleep & Routine',
    description: 'Sleep training, nap schedules, bedtime routines — and the 3am solidarity you didn\'t know you needed. We\'ve all been there.',
    emoji: '😴',
    color: Color(0xFF5C6BC0),
    colorLight: Color(0xFFE8EAF6),
    memberCount: 7100,
    activeCount: 390,
    category: 'Wellness',
    tags: ['Sleep', 'Routine', 'Newborn'],
  ),
  const CommunityInfo(
    id: 'working_moms_wellness',
    name: 'Working Moms & Wellness',
    description: 'Balancing career, motherhood, and your own wellbeing. Share strategies, vent freely, and celebrate every small win.',
    emoji: '💼',
    color: AppColors.accentOrange,
    colorLight: AppColors.accentOrangeLight,
    memberCount: 4900,
    activeCount: 275,
    category: 'Lifestyle',
    tags: ['Career', 'Wellness', 'Balance'],
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class CommunitiesListScreen extends StatefulWidget {
  const CommunitiesListScreen({super.key});

  @override
  State<CommunitiesListScreen> createState() => _CommunitiesListScreenState();
}

class _CommunitiesListScreenState extends State<CommunitiesListScreen> {
  late final List<CommunityInfo> _communities;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _communities = _buildCommunities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CommunityInfo> get _filtered {
    if (_searchQuery.isEmpty) return _communities;
    final q = _searchQuery.toLowerCase();
    return _communities.where((c) =>
        c.name.toLowerCase().contains(q) ||
        c.description.toLowerCase().contains(q) ||
        c.tags.any((t) => t.toLowerCase().contains(q))).toList();
  }

  void _toggleJoin(String id) {
    setState(() {
      final idx = _communities.indexWhere((c) => c.id == id);
      if (idx == -1) return;
      final c = _communities[idx];
      _communities[idx] = CommunityInfo(
        id: c.id, name: c.name, description: c.description,
        emoji: c.emoji, color: c.color, colorLight: c.colorLight,
        memberCount: c.isJoined ? c.memberCount - 1 : c.memberCount + 1,
        activeCount: c.activeCount, category: c.category,
        isJoined: !c.isJoined, tags: c.tags,
      );
    });
  }

  void _openCommunity(CommunityInfo community) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => CommunityScreen(community: community),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildJoinedSection()),
          SliverToBoxAdapter(child: _buildHeader()),
          filtered.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyState())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _CommunityCard(
                      community: filtered[i],
                      onTap: () => _openCommunity(filtered[i]),
                      onJoin: () => _toggleJoin(filtered[i].id),
                    ),
                    childCount: filtered.length,
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.divider,
      automaticallyImplyLeading: false,
      title: Text('Community', style: AppTextStyles.headlineMedium),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 22),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingL, AppConstants.paddingS,
        AppConstants.paddingL, 0,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search communities...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textHint),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            borderSide: BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            borderSide: BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildJoinedSection() {
    final joined = _communities.where((c) => c.isJoined).toList();
    if (joined.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingL, AppConstants.paddingL,
            AppConstants.paddingL, AppConstants.paddingS,
          ),
          child: Text('Your Communities', style: AppTextStyles.headlineSmall),
        ),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
            itemCount: joined.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppConstants.paddingM),
            itemBuilder: (_, i) {
              final c = joined[i];
              return GestureDetector(
                onTap: () => _openCommunity(c),
                child: Container(
                  width: 96,
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  decoration: BoxDecoration(
                    color: c.colorLight,
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    border: Border.all(color: c.color.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(c.emoji, style: const TextStyle(fontSize: 30)),
                      const SizedBox(height: 6),
                      Text(
                        c.name,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingL, AppConstants.paddingL,
        AppConstants.paddingL, AppConstants.paddingS,
      ),
      child: Row(
        children: [
          Text('Our Communities', style: AppTextStyles.headlineSmall),
          const SizedBox(width: AppConstants.paddingS),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            ),
            child: Text(
              '${_communities.length}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppConstants.paddingL),
            Text('No communities found', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 6),
            Text('Try a different search term', style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}

// ── Community Card ────────────────────────────────────────────────────────────

class _CommunityCard extends StatelessWidget {
  final CommunityInfo community;
  final VoidCallback onTap;
  final VoidCallback onJoin;

  const _CommunityCard({
    required this.community,
    required this.onTap,
    required this.onJoin,
  });

  String _formatCount(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';

  @override
  Widget build(BuildContext context) {
    final c = community;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppConstants.paddingL, 0,
          AppConstants.paddingL, AppConstants.paddingM,
        ),
        padding: const EdgeInsets.all(AppConstants.paddingL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji avatar
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: c.colorLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Center(child: Text(c.emoji, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.name,
                          style: AppTextStyles.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (c.isJoined)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                          ),
                          child: Text(
                            'Joined',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    c.description,
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.paddingS),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: c.colorLight,
                          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                        ),
                        child: Text(
                          c.category,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: c.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingS),
                      const Icon(Icons.people_outline_rounded, size: 12, color: AppColors.textHint),
                      const SizedBox(width: 3),
                      Text(_formatCount(c.memberCount), style: AppTextStyles.labelSmall),
                      const SizedBox(width: AppConstants.paddingS),
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.accentGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${c.activeCount} active',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentGreen),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onJoin,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: c.isJoined ? AppColors.background : c.color,
                            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                            border: Border.all(
                              color: c.isJoined ? AppColors.divider : c.color,
                            ),
                          ),
                          child: Text(
                            c.isJoined ? 'Leave' : 'Join',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: c.isJoined ? AppColors.textSecondary : Colors.white,
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
          ],
        ),
      ),
    );
  }
}
