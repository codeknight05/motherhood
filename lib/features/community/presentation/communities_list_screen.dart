import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import 'community_screen.dart';
import 'create_community_screen.dart';

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

// ── Sample communities ────────────────────────────────────────────────────────

final _sampleCommunities = <CommunityInfo>[
  const CommunityInfo(
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
  ),
  const CommunityInfo(
    id: 'dads_corner',
    name: "Dad's Corner",
    description: 'A no-judgement zone for dads to talk parenting, share wins, and ask the questions they\'re too embarrassed to Google.',
    emoji: '👨‍👧',
    color: Color(0xFF1565C0),
    colorLight: Color(0xFFE3F2FD),
    memberCount: 1100,
    activeCount: 48,
    category: 'Parenting',
    tags: ['Dads', 'Parenting'],
  ),
  const CommunityInfo(
    id: 'diaper_changers',
    name: 'Diaper Changers 💩',
    description: 'For parents who have changed enough diapers to deserve a medal. Funny stories, survival tips, and solidarity.',
    emoji: '🍼',
    color: Color(0xFF6D4C41),
    colorLight: Color(0xFFEFEBE9),
    memberCount: 870,
    activeCount: 62,
    category: 'Humor',
    tags: ['Funny', 'Newborn'],
  ),
  const CommunityInfo(
    id: 'breastfeeding_support',
    name: 'Breastfeeding Support',
    description: 'Tips, struggles, and wins from the breastfeeding journey. Lactation consultants welcome!',
    emoji: '🤍',
    color: AppColors.accentPink,
    colorLight: AppColors.accentPinkLight,
    memberCount: 3200,
    activeCount: 210,
    category: 'Health',
    tags: ['Feeding', 'Newborn'],
  ),
  const CommunityInfo(
    id: 'sleep_deprived',
    name: 'Sleep Deprived Club',
    description: 'If you\'re reading this at 3am while feeding your baby, you belong here. Sleep tips, commiseration, and coffee memes.',
    emoji: '😴',
    color: Color(0xFF5C6BC0),
    colorLight: Color(0xFFE8EAF6),
    memberCount: 4500,
    activeCount: 312,
    category: 'Humor',
    tags: ['Sleep', 'Newborn', 'Funny'],
  ),
  const CommunityInfo(
    id: 'indian_moms',
    name: 'Indian Moms Network',
    description: 'Desi parenting wisdom, traditional recipes, and navigating motherhood with family opinions. 🇮🇳',
    emoji: '🪔',
    color: AppColors.accentOrange,
    colorLight: AppColors.accentOrangeLight,
    memberCount: 5800,
    activeCount: 430,
    category: 'Culture',
    tags: ['Indian', 'Culture', 'Food'],
  ),
  const CommunityInfo(
    id: 'working_moms',
    name: 'Working Moms',
    description: 'Balancing career and motherhood. Share your wins, vent your frustrations, and find your tribe.',
    emoji: '💼',
    color: AppColors.accentGreen,
    colorLight: AppColors.accentGreenLight,
    memberCount: 2900,
    activeCount: 175,
    category: 'Lifestyle',
    tags: ['Career', 'Balance'],
  ),
  const CommunityInfo(
    id: 'toddler_taming',
    name: 'Toddler Taming Squad',
    description: 'Surviving the terrible twos (and threes). Tantrums, milestones, and the chaos of toddlerhood.',
    emoji: '🦁',
    color: Color(0xFFE53935),
    colorLight: Color(0xFFFFEBEE),
    memberCount: 1650,
    activeCount: 88,
    category: 'Parenting',
    tags: ['Toddler', 'Behavior'],
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class CommunitiesListScreen extends StatefulWidget {
  const CommunitiesListScreen({super.key});

  @override
  State<CommunitiesListScreen> createState() => _CommunitiesListScreenState();
}

class _CommunitiesListScreenState extends State<CommunitiesListScreen> {
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final List<CommunityInfo> _communities = List.from(_sampleCommunities);

  static const _categories = ['All', 'Pregnancy', 'Parenting', 'Health', 'Humor', 'Culture', 'Lifestyle'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CommunityInfo> get _filtered {
    return _communities.where((c) {
      final matchesCategory = _selectedCategory == 'All' || c.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<CommunityInfo> get _joined => _communities.where((c) => c.isJoined).toList();

  void _toggleJoin(String id) {
    setState(() {
      final idx = _communities.indexWhere((c) => c.id == id);
      if (idx != -1) {
        final c = _communities[idx];
        _communities[idx] = CommunityInfo(
          id: c.id,
          name: c.name,
          description: c.description,
          emoji: c.emoji,
          color: c.color,
          colorLight: c.colorLight,
          memberCount: c.isJoined ? c.memberCount - 1 : c.memberCount + 1,
          activeCount: c.activeCount,
          category: c.category,
          isJoined: !c.isJoined,
          tags: c.tags,
        );
      }
    });
  }

  void _openCommunity(CommunityInfo community) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityScreen(community: community),
      ),
    );
  }

  void _openCreateCommunity() async {
    final result = await Navigator.push<CommunityInfo>(
      context,
      MaterialPageRoute(builder: (_) => const CreateCommunityScreen()),
    );
    if (result != null) {
      setState(() => _communities.insert(0, result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildCategoryChips()),
          if (_joined.isNotEmpty && _searchQuery.isEmpty && _selectedCategory == 'All') ...[
            SliverToBoxAdapter(child: _buildSectionHeader('Your Communities', _joined.length)),
            SliverToBoxAdapter(child: _buildJoinedRow()),
          ],
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              _selectedCategory == 'All' ? 'Discover Communities' : _selectedCategory,
              _filtered.length,
            ),
          ),
          _filtered.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyState())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _CommunityCard(
                      community: _filtered[i],
                      onTap: () => _openCommunity(_filtered[i]),
                      onJoin: () => _toggleJoin(_filtered[i].id),
                    ),
                    childCount: _filtered.length,
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateCommunity,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text('Create Community', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
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

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingL,
          vertical: AppConstants.paddingS,
        ),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppConstants.paddingS),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                ),
              ),
              child: Text(
                cat,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingL, AppConstants.paddingL,
        AppConstants.paddingL, AppConstants.paddingS,
      ),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.headlineSmall),
          const SizedBox(width: AppConstants.paddingS),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            ),
            child: Text(
              '$count',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinedRow() {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
        itemCount: _joined.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppConstants.paddingM),
        itemBuilder: (_, i) {
          final c = _joined[i];
          return GestureDetector(
            onTap: () => _openCommunity(c),
            child: Container(
              width: 90,
              padding: const EdgeInsets.all(AppConstants.paddingM),
              decoration: BoxDecoration(
                color: c.colorLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                border: Border.all(color: c.color.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(c.emoji, style: const TextStyle(fontSize: 28)),
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
            Text('Try a different search or create one!', style: AppTextStyles.bodyMedium),
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

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

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
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: c.colorLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Center(
                child: Text(c.emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: AppConstants.paddingM),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(c.name, style: AppTextStyles.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
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
                      // Category chip
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
                      Text('${c.activeCount} active', style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentGreen)),
                      const Spacer(),
                      // Join / Leave button
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
