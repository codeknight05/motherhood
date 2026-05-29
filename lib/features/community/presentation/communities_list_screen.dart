import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/community_provider.dart';
import 'community_screen.dart';

// ── Community model ───────────────────────────────────────────────────────────

class CommunityInfo {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final Color color;
  final Color colorLight;
  final int memberCount;   // live count from provider
  final int activeCount;   // static estimate
  final String category;
  final bool isJoined;     // live from provider
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

// ── Static community definitions (display data only) ─────────────────────────

const _staticCommunities = [
  _StaticCommunity(
    id: 'expecting_moms',
    name: 'Expecting Moms',
    description: 'A warm, supportive space for moms-to-be. Share your pregnancy journey, ask questions, and connect with others due around the same time.',
    emoji: '🤰',
    color: AppColors.primary,
    colorLight: AppColors.primaryLight,
    activeCount: 312,
    category: 'Pregnancy',
    tags: ['Pregnancy', 'Due Date', 'Support'],
  ),
  _StaticCommunity(
    id: 'first_time_moms',
    name: 'First-Time Moms',
    description: 'Everything is new and that\'s okay! A judgement-free zone for first-time moms to ask anything, share wins, and survive together.',
    emoji: '🌸',
    color: AppColors.accentPink,
    colorLight: AppColors.accentPinkLight,
    activeCount: 540,
    category: 'Parenting',
    tags: ['First-Time', 'Newborn', 'Support'],
  ),
  _StaticCommunity(
    id: 'feeding_nutrition',
    name: 'Feeding & Nutrition',
    description: 'Breastfeeding, formula, solids, and everything in between. Get advice, share recipes, and support each other through feeding challenges.',
    emoji: '🍼',
    color: AppColors.accentGreen,
    colorLight: AppColors.accentGreenLight,
    activeCount: 428,
    category: 'Health',
    tags: ['Breastfeeding', 'Solids', 'Nutrition'],
  ),
  _StaticCommunity(
    id: 'sleep_routine',
    name: 'Sleep & Routine',
    description: 'Sleep training, nap schedules, bedtime routines — and the 3am solidarity you didn\'t know you needed.',
    emoji: '😴',
    color: Color(0xFF5C6BC0),
    colorLight: Color(0xFFE8EAF6),
    activeCount: 390,
    category: 'Wellness',
    tags: ['Sleep', 'Routine', 'Newborn'],
  ),
  _StaticCommunity(
    id: 'working_moms_wellness',
    name: 'Working Moms & Wellness',
    description: 'Balancing career, motherhood, and your own wellbeing. Share strategies, vent freely, and celebrate every small win.',
    emoji: '💼',
    color: AppColors.accentOrange,
    colorLight: AppColors.accentOrangeLight,
    activeCount: 275,
    category: 'Lifestyle',
    tags: ['Career', 'Wellness', 'Balance'],
  ),
];

class _StaticCommunity {
  final String id, name, description, emoji, category;
  final Color color, colorLight;
  final int activeCount;
  final List<String> tags;
  const _StaticCommunity({
    required this.id, required this.name, required this.description,
    required this.emoji, required this.color, required this.colorLight,
    required this.activeCount, required this.category, required this.tags,
  });
}

// ── Screen ────────────────────────────────────────────────────────────────────

class CommunitiesListScreen extends ConsumerStatefulWidget {
  const CommunitiesListScreen({super.key});

  @override
  ConsumerState<CommunitiesListScreen> createState() =>
      _CommunitiesListScreenState();
}

class _CommunitiesListScreenState
    extends ConsumerState<CommunitiesListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(communityProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_StaticCommunity> get _filtered {
    if (_searchQuery.isEmpty) return _staticCommunities;
    final q = _searchQuery.toLowerCase();
    return _staticCommunities
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q) ||
            c.tags.any((t) => t.toLowerCase().contains(q)))
        .toList();
  }

  CommunityInfo _buildInfo(_StaticCommunity s, CommunityState cs) {
    return CommunityInfo(
      id: s.id,
      name: s.name,
      description: s.description,
      emoji: s.emoji,
      color: s.color,
      colorLight: s.colorLight,
      memberCount: cs.memberCount(s.id),
      activeCount: s.activeCount,
      category: s.category,
      isJoined: cs.isJoined(s.id),
      tags: s.tags,
    );
  }

  void _openCommunity(CommunityInfo info) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CommunityScreen(community: info)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = ref.watch(communityProvider);
    final filtered = _filtered;
    final joinedStatic =
        _staticCommunities.where((s) => cs.isJoined(s.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildSearchBar()),
          // Joined section
          if (joinedStatic.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.paddingL, AppConstants.paddingL,
                  AppConstants.paddingL, AppConstants.paddingS,
                ),
                child: Text('Your Communities', style: AppTextStyles.headlineSmall),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingL),
                  itemCount: joinedStatic.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppConstants.paddingM),
                  itemBuilder: (_, i) {
                    final s = joinedStatic[i];
                    final info = _buildInfo(s, cs);
                    return GestureDetector(
                      onTap: () => _openCommunity(info),
                      child: Container(
                        width: 96,
                        padding: const EdgeInsets.all(AppConstants.paddingM),
                        decoration: BoxDecoration(
                          color: s.colorLight,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusL),
                          border: Border.all(
                              color: s.color.withValues(alpha: 0.25)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(s.emoji,
                                style: const TextStyle(fontSize: 30)),
                            const SizedBox(height: 6),
                            Text(
                              s.name,
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
            ),
          ],
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingL, AppConstants.paddingL,
                AppConstants.paddingL, AppConstants.paddingS,
              ),
              child: Row(
                children: [
                  Text('Our Communities', style: AppTextStyles.headlineSmall),
                  const SizedBox(width: AppConstants.paddingS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusFull),
                    ),
                    child: Text(
                      '${_staticCommunities.length}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Community list
          filtered.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔍',
                              style: TextStyle(fontSize: 48)),
                          const SizedBox(height: AppConstants.paddingL),
                          Text('No communities found',
                              style: AppTextStyles.headlineSmall),
                          const SizedBox(height: 6),
                          Text('Try a different search term',
                              style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final s = filtered[i];
                      final info = _buildInfo(s, cs);
                      return _CommunityCard(
                        community: info,
                        onTap: () => _openCommunity(info),
                        onJoin: () => ref
                            .read(communityProvider.notifier)
                            .toggleJoin(s.id),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: AppColors.textPrimary, size: 22),
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
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textHint, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 18, color: AppColors.textHint),
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
            borderRadius:
                BorderRadius.circular(AppConstants.radiusFull),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.radiusFull),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.radiusFull),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        style: AppTextStyles.bodyMedium
            .copyWith(color: AppColors.textPrimary),
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

  String _fmt(int n) =>
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
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: c.colorLight,
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Center(
                  child: Text(c.emoji,
                      style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(c.name,
                            style: AppTextStyles.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (c.isJoined)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusFull),
                          ),
                          child: Text('Joined',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(c.description,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppConstants.paddingS),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: c.colorLight,
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusFull),
                        ),
                        child: Text(c.category,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: c.color,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                      const SizedBox(width: AppConstants.paddingS),
                      const Icon(Icons.people_outline_rounded,
                          size: 12, color: AppColors.textHint),
                      const SizedBox(width: 3),
                      Text(_fmt(c.memberCount),
                          style: AppTextStyles.labelSmall),
                      const SizedBox(width: AppConstants.paddingS),
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.accentGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text('${c.activeCount} active',
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.accentGreen)),
                      const Spacer(),
                      GestureDetector(
                        onTap: onJoin,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: c.isJoined
                                ? AppColors.background
                                : c.color,
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusFull),
                            border: Border.all(
                              color: c.isJoined
                                  ? AppColors.divider
                                  : c.color,
                            ),
                          ),
                          child: Text(
                            c.isJoined ? 'Leave' : 'Join',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: c.isJoined
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
          ],
        ),
      ),
    );
  }
}
