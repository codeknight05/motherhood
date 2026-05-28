import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/baby_avatar.dart';
import '../../../core/providers/baby_provider.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/providers/milestones_provider.dart';
import '../../../models/baby_model.dart';
import '../../../models/milestone_model.dart';
import '../../../models/memory_model.dart';
import '../../../models/milestone_library.dart';
import 'milestone_guidance_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Baby Journey Screen — Milestones + Memory Diary merged with TabBar
// ═══════════════════════════════════════════════════════════════════════════

class MilestonesScreen extends ConsumerStatefulWidget {
  const MilestonesScreen({super.key});

  @override
  ConsumerState<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends ConsumerState<MilestonesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baby = ref.watch(babyProvider).baby ?? sampleBaby;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(baby, innerBoxIsScrolled),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [_MilestonesTab(), _MemoryDiaryTab()],
        ),
      ),
      floatingActionButton: null,
    );
  }

  Widget _buildAppBar(BabyModel baby, bool innerBoxIsScrolled) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      forceElevated: innerBoxIsScrolled,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.divider,
      titleSpacing: AppConstants.paddingL,
      title: _BabyHeaderCard(baby: baby),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: _JourneyTabBar(controller: _tabController),
      ),
    );
  }
}

// ─── Shared Header ────────────────────────────────────────────────────────────

class _BabyHeaderCard extends StatelessWidget {
  final BabyModel baby;
  const _BabyHeaderCard({required this.baby});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BabyAvatar(name: baby.name, size: 40),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(baby.name, style: AppTextStyles.headlineSmall),
              Text(
                baby.ageString,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(color: AppColors.primaryMid),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.swap_horiz_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Change',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Tab Bar ─────────────────────────────────────────────────────────────────

class _JourneyTabBar extends StatelessWidget {
  final TabController controller;
  const _JourneyTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppConstants.paddingL,
        0,
        AppConstants.paddingL,
        AppConstants.paddingM,
      ),
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppConstants.radiusM - 2),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: AppTextStyles.titleMedium.copyWith(color: Colors.white),
        unselectedLabelStyle: AppTextStyles.titleMedium.copyWith(
          color: AppColors.primary,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.primary,
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🏆', style: TextStyle(fontSize: 14)),
                SizedBox(width: 6),
                Text('Milestones'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('📸', style: TextStyle(fontSize: 14)),
                SizedBox(width: 6),
                Text('Memory Diary'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB 1 — MILESTONES
// ═══════════════════════════════════════════════════════════════════════════

class _MilestonesTab extends ConsumerStatefulWidget {
  const _MilestonesTab();
  @override
  ConsumerState<_MilestonesTab> createState() => _MilestonesTabState();
}

class _MilestonesTabState extends ConsumerState<_MilestonesTab>
    with WidgetsBindingObserver {
  int _selectedBand = 10;
  bool _bandInitialised = false;
  int _babyBand = 10;
  late final ScrollController _bandScroll;

  @override
  void initState() {
    super.initState();
    _bandScroll = ScrollController();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual<BabyState>(babyProvider, (prev, next) {
        if (!_bandInitialised && next.baby != null) {
          setState(() => _initFromBaby(next.baby));
        }
      });
      final baby = ref.read(babyProvider).baby;
      if (!_bandInitialised && baby != null) {
        setState(() => _initFromBaby(baby));
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bandScroll.dispose();
    super.dispose();
  }

  // Item 4 — recalculate band when app resumes (handles day-change across sessions)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final baby = ref.read(babyProvider).baby;
      if (baby != null) {
        final newBand = _bandForBaby(baby);
        if (newBand != _babyBand) {
          // Baby has moved to a new age band since last open
          setState(() {
            _babyBand = newBand;
            _bandInitialised = false;
          });
          _initFromBaby(baby);
        }
      }
    }
  }

  void _initFromBaby(baby) {
    if (_bandInitialised || baby == null) return;
    _bandInitialised = true;
    final band = _bandForBaby(baby);
    _selectedBand = band;
    _babyBand = band;
    _loadBand(band);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBand(band));
  }

  int _bandForBaby(baby) {
    if (baby.birthDate == null) return 10;
    final days = DateTime.now().difference(baby.birthDate!).inDays;
    return ageBandFromDays(days);
  }

  void _scrollToBand(int band) {
    if (!_bandScroll.hasClients) return;
    _bandScroll.animateTo(
      band * 80.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  Future<void> _loadBand(
  int band, {
  bool forceRefresh = false,
}) async {
  final baby = ref.read(babyProvider).baby;

  if (baby == null) return;

  final current = ref.read(milestonesProvider);

  if (!forceRefresh &&
      current.guidance.isNotEmpty &&
      current.selectedBandIndex == band) {
    return;
  }

  String role = 'parent';

  try {
    final user = SupabaseService.currentUser;

    if (user != null) {
      role = await SupabaseService.fetchUserRole(user.id);
    }
  } catch (e) {
    debugPrint('Failed to fetch user role: $e');
  }

  await ref.read(milestonesProvider.notifier).loadMilestones(
        baby.id,
        baby.ageInMonths,
        bandIndex: band,
        audience: role,
      );
}

  void _selectBand(int band) {
    setState(() => _selectedBand = band);
    _loadBand(band);
    _scrollToBand(band);
  }

  // Item 1 — pull-to-refresh
  Future<void> _onRefresh() async {
    _loadBand(_selectedBand, forceRefresh: true);
    // Wait for loading to complete
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return ref.read(milestonesProvider).isLoading;
    }).timeout(const Duration(seconds: 10), onTimeout: () {});
  }

  @override
  Widget build(BuildContext context) {
    final msState = ref.watch(milestonesProvider);
    final guidance = msState.guidance.isNotEmpty
        ? msState.guidance
        : guidanceForAgeBand(_selectedBand);

    final totalAchieved = msState.totalAchieved;
    final totalItems = msState.totalItems;
    final totalInProgress = msState.totalInProgress;
    final totalNotStarted = msState.totalNotStarted;
    final percent = msState.overallPercent;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, AppConstants.paddingM, 0, 100),
        children: [
          _buildBandSelector(),
          const SizedBox(height: AppConstants.paddingM),
          _buildBandBanner(),
          const SizedBox(height: AppConstants.paddingM),
          if (msState.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2.5,
                ),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingL,
              ),
              child: _buildOverallProgress(
                totalAchieved,
                totalItems,
                totalInProgress,
                totalNotStarted,
                percent,
              ),
            ),
            const SizedBox(height: AppConstants.paddingXL),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingL,
              ),
              child: _buildCategoryGrid(guidance),
            ),
            const SizedBox(height: AppConstants.paddingM),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingL,
              ),
              child: _buildEncouragementCard(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBandSelector() {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        controller: _bandScroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
        itemCount: ageBands.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppConstants.paddingS),
        itemBuilder: (_, i) {
          final band = ageBands[i];
          final isSelected = _selectedBand == i;
          final isBabyAge = _babyBand == i;
          return GestureDetector(
            onTap: () => _selectBand(i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Item 6 — "your baby" label above the chip
                SizedBox(
                  height: 14,
                  child: isBabyAge
                      ? Text(
                          '👶 Now',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 2),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(
                      color: isBabyAge && !isSelected
                          ? AppColors.primary
                          : isSelected
                          ? AppColors.primary
                          : AppColors.divider,
                      width: isBabyAge ? 2 : 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(band.emoji, style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(
                        band.shortLabel,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBandBanner() {
    final band = ageBands[_selectedBand];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(_selectedBand),
        margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
        padding: const EdgeInsets.all(AppConstants.paddingL),
        decoration: BoxDecoration(
          gradient: AppColors.softPurpleGradient,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    band.label,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap a category to see milestones, activities and guidance.',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Text(band.emoji, style: const TextStyle(fontSize: 44)),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallProgress(
    int achieved,
    int total,
    int inProgress,
    int notStarted,
    double percent,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Overall Progress', style: AppTextStyles.titleLarge),
              Text('$achieved / $total Done', style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: AppColors.primaryLight,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(percent * 100).toInt()}%',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          Wrap(
            spacing: AppConstants.paddingL,
            runSpacing: 4,
            children: [
              _ProgressLegend(
                color: AppColors.accentGreen,
                label: 'Done ($achieved)',
              ),
              _ProgressLegend(
                color: AppColors.warning,
                label: 'In Progress ($inProgress)',
              ),
              _ProgressLegend(
                color: AppColors.textHint,
                label: 'Not Started ($notStarted)',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(List<CategoryGuidance> guidance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Development Areas', style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppConstants.paddingM),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppConstants.paddingM,
            mainAxisSpacing: AppConstants.paddingM,
            childAspectRatio: 1.1,
          ),
          itemCount: guidance.length,
          itemBuilder: (_, i) => _CategoryCard(
            guidance: guidance[i],
            onTap: () => _openGuidance(guidance[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildEncouragementCard() {
    final baby = ref.watch(babyProvider).baby ?? sampleBaby;
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('⭐', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Great job! 🎉',
                  style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '${baby.name} is growing beautifully. Keep nurturing and engaging every day.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const Text('🌟', style: TextStyle(fontSize: 32)),
        ],
      ),
    );
  }

  void _openGuidance(CategoryGuidance guidance) {
    final baby = ref.read(babyProvider).baby ?? sampleBaby;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MilestoneGuidanceScreen(
          guidance: guidance,
          babyName: baby.name,
          babyAge: baby.ageString,
          onStatusChanged: (id, status) => ref
              .read(milestonesProvider.notifier)
              .updateMilestoneStatus(baby.id, id, status),
        ),
      ),
    );
  }
}

// ── Category card (grid tile) ─────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final CategoryGuidance guidance;
  final VoidCallback onTap;
  const _CategoryCard({required this.guidance, required this.onTap});

  Color get _bg {
    switch (guidance.category) {
      case MilestoneCategory.grossMotor:
        return AppColors.accentGreenLight;
      case MilestoneCategory.fineMotor:
        return AppColors.accentOrangeLight;
      case MilestoneCategory.language:
        return AppColors.primaryLight;
      case MilestoneCategory.cognitive:
        return AppColors.accentBlueLight;
      case MilestoneCategory.social:
        return AppColors.accentPinkLight;
      case MilestoneCategory.feedingSleep:
        return const Color(0xFFFFF8E1);
    }
  }

  Color get _accent {
    switch (guidance.category) {
      case MilestoneCategory.grossMotor:
        return AppColors.accentGreen;
      case MilestoneCategory.fineMotor:
        return AppColors.accentOrange;
      case MilestoneCategory.language:
        return AppColors.primary;
      case MilestoneCategory.cognitive:
        return AppColors.accentBlue;
      case MilestoneCategory.social:
        return AppColors.accentPink;
      case MilestoneCategory.feedingSleep:
        return const Color(0xFFFF8F00);
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = guidance.achieved;
    final total = guidance.totalMilestones;
    final pct = guidance.progressPercent;
    final allDone = total > 0 && done == total;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: allDone ? _accent.withValues(alpha: 0.12) : _bg,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
            color: allDone ? _accent : _accent.withValues(alpha: 0.2),
            width: allDone ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  allDone ? '🏆' : guidance.category.emoji,
                  style: const TextStyle(fontSize: 26),
                ),
                const Spacer(),
                if (allDone)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusFull,
                      ),
                    ),
                    child: Text(
                      'All done!',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else
                  Text(
                    '$done/$total',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingS),
            Text(guidance.category.label, style: AppTextStyles.titleMedium),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 5,
                backgroundColor: _accent.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(_accent),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              allDone ? '✨ Amazing progress!' : guidance.category.description,
              style: AppTextStyles.labelSmall.copyWith(
                color: allDone ? _accent : AppColors.textSecondary,
                fontWeight: allDone ? FontWeight.w700 : FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ProgressLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}
// ═══════════════════════════════════════════════════════════════════════════

class _MemoryDiaryTab extends ConsumerStatefulWidget {
  const _MemoryDiaryTab();

  @override
  ConsumerState<_MemoryDiaryTab> createState() => _MemoryDiaryTabState();
}

class _MemoryDiaryTabState extends ConsumerState<_MemoryDiaryTab> {
  final _picker = ImagePicker();
  List<MemoryEntry> _memories = List.from(sampleMemories);
  MemoryTag? _selectedFilter;
  bool _loadingMemories = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMemories());
  }

  Future<void> _loadMemories() async {
    final baby = ref.read(babyProvider).baby;
    if (baby == null || baby.id.isEmpty) return;

    setState(() => _loadingMemories = true);
    try {
      final res = await Supabase.instance.client
          .from('memories')
          .select()
          .eq('baby_id', baby.id)
          .order('memory_date', ascending: false);

      final loaded = (res as List)
          .map(
            (m) => MemoryEntry(
              id: m['id'] as String,
              babyId: m['baby_id'] as String,
              imageUrl: m['image_url'] as String?,
              videoUrl: m['video_url'] as String?,
              caption: m['caption'] as String?,
              date: DateTime.parse(m['memory_date'] as String),
              tag: memoryTagFromDb(m['tag'] as String? ?? 'everyday'),
              ageMonths: m['age_months'] as int?,
            ),
          )
          .toList();

      if (mounted) {
        setState(() {
          _memories = loaded;
          _loadingMemories = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingMemories = false);
    }
  }

  List<MemoryEntry> get _filtered => _selectedFilter == null
      ? _memories
      : _memories.where((m) => m.tag == _selectedFilter).toList();

  Map<String, List<MemoryEntry>> get _grouped {
    final map = <String, List<MemoryEntry>>{};
    for (final m in _filtered) {
      map.putIfAbsent(_monthLabel(m.date), () => []).add(m);
    }
    return map;
  }

  String _monthLabel(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (file == null || !mounted) return;
      _showAddSheet(file.path, isVideo: false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not access ${source == ImageSource.camera ? "camera" : "gallery"}. Check permissions.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final file = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );
      if (file == null || !mounted) return;
      _showAddSheet(file.path, isVideo: true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not access ${source == ImageSource.camera ? "camera" : "gallery"}. Check permissions.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void showSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SourcePickerSheet(
        onCameraPhoto: () {
          Navigator.pop(context);
          _pickImage(ImageSource.camera);
        },
        onGalleryPhoto: () {
          Navigator.pop(context);
          _pickImage(ImageSource.gallery);
        },
        onCameraVideo: () {
          Navigator.pop(context);
          _pickVideo(ImageSource.camera);
        },
        onGalleryVideo: () {
          Navigator.pop(context);
          _pickVideo(ImageSource.gallery);
        },
      ),
    );
  }

  void _showAddSheet(String path, {required bool isVideo}) {
    final baby = ref.read(babyProvider).baby ?? sampleBaby;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMemorySheet(
        mediaPath: path,
        isVideo: isVideo,
        baby: baby,
        onSave: (e) => setState(() => _memories.insert(0, e)),
      ),
    );
  }

  Future<void> _confirmDeleteFromGrid(MemoryEntry memory) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: const Text('Delete Memory?'),
        content: const Text(
          'This will permanently delete this photo. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await Supabase.instance.client
          .from('memories')
          .delete()
          .eq('id', memory.id);
      if (memory.imageUrl != null) {
        await CloudinaryService.deletePhoto(memory.imageUrl!);
      }
      if (memory.videoUrl != null) {
        await CloudinaryService.deletePhoto(memory.videoUrl!);
      }
      if (mounted) {
        setState(() => _memories.removeWhere((m) => m.id == memory.id));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    return Stack(
      children: [
        // Loading overlay
        if (_loadingMemories)
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2.5,
            ),
          ),
        ListView(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingL,
            AppConstants.paddingL,
            AppConstants.paddingL,
            120,
          ),
          children: [
            _buildStats(),
            const SizedBox(height: AppConstants.paddingM),
            _buildFilterChips(),
            const SizedBox(height: AppConstants.paddingL),
            if (_loadingMemories)
              const SizedBox(height: 200) // space for loading indicator
            else if (_filtered.isEmpty)
              _buildEmpty()
            else
              ...grouped.entries.map(
                (e) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMonthHeader(e.key, e.value.length),
                    const SizedBox(height: AppConstants.paddingM),
                    _buildGrid(e.value),
                    const SizedBox(height: AppConstants.paddingXL),
                  ],
                ),
              ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 0,
          left: 0,
          child: Center(
            child: FloatingActionButton.extended(
              heroTag: 'memory_fab',
              onPressed: showSourcePicker,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_a_photo_rounded),
              label: Text(
                'Add Photo / Video',
                style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    final baby = ref.watch(babyProvider).baby ?? sampleBaby;
    final milestoneCount = _memories
        .where((m) => m.tag == MemoryTag.milestone)
        .length;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '${_memories.length}',
            label: 'Memories',
            emoji: '📸',
            color: AppColors.primaryLight,
            textColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppConstants.paddingM),
        Expanded(
          child: _StatCard(
            value: '${baby.ageInMonths}',
            label: 'Months old',
            emoji: '🎂',
            color: AppColors.accentPinkLight,
            textColor: AppColors.accentPink,
          ),
        ),
        const SizedBox(width: AppConstants.paddingM),
        Expanded(
          child: _StatCard(
            value: '$milestoneCount',
            label: 'Milestones',
            emoji: '🏆',
            color: AppColors.accentOrangeLight,
            textColor: AppColors.accentOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            emoji: '✨',
            isSelected: _selectedFilter == null,
            onTap: () => setState(() => _selectedFilter = null),
          ),
          const SizedBox(width: AppConstants.paddingS),
          ...MemoryTag.values.map(
            (tag) => Padding(
              padding: const EdgeInsets.only(right: AppConstants.paddingS),
              child: _FilterChip(
                label: tag.label,
                emoji: tag.emoji,
                isSelected: _selectedFilter == tag,
                onTap: () => setState(
                  () => _selectedFilter = _selectedFilter == tag ? null : tag,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(String month, int count) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(month, style: AppTextStyles.headlineSmall),
        const SizedBox(width: 8),
        Text(
          '$count ${count == 1 ? "memory" : "memories"}',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildGrid(List<MemoryEntry> memories) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1,
      ),
      itemCount: memories.length,
      itemBuilder: (_, i) => GestureDetector(
        onTap: () async {
          final deletedId = await Navigator.push<String>(
            context,
            MaterialPageRoute(
              builder: (_) => _MemoryDetailScreen(memory: memories[i]),
            ),
          );
          if (deletedId != null && mounted) {
            setState(() => _memories.removeWhere((m) => m.id == deletedId));
          }
        },
        onLongPress: () => _confirmDeleteFromGrid(memories[i]),
        child: _MemoryGridTile(memory: memories[i]),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🎬', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: AppConstants.paddingL),
            Text('No memories yet', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Tap the button below to capture\nyour first photo or video moment',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Memory Widgets ────────────────────────────────────────────────────

class _MemoryGridTile extends StatelessWidget {
  final MemoryEntry memory;
  const _MemoryGridTile({required this.memory});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail
          _buildThumbnail(),
          // Bottom gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Tag emoji badge
          Positioned(
            top: 5,
            left: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                memory.tag.emoji,
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          // Video play icon
          if (memory.isVideo)
            Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          // Video badge
          if (memory.isVideo)
            Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam_rounded, color: Colors.white, size: 10),
                    SizedBox(width: 2),
                    Text(
                      'VIDEO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    if (memory.isVideo) {
      // Use Cloudinary-generated video thumbnail
      final thumb = memory.videoThumbnailUrl;
      if (thumb != null) {
        return Image.network(
          thumb,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _videoPlaceholder(),
        );
      }
      if (memory.videoPath != null) {
        // Local video — show placeholder (thumbnail generation needs video_thumbnail package)
        return _videoPlaceholder();
      }
      return _videoPlaceholder();
    }
    // Image
    if (memory.imagePath != null) {
      return Image.file(File(memory.imagePath!), fit: BoxFit.cover);
    }
    if (memory.imageUrl != null) {
      return Image.network(
        memory.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }
    return _imagePlaceholder();
  }

  Widget _videoPlaceholder() => Container(
    color: const Color(0xFF1A1A2E),
    child: const Center(
      child: Icon(Icons.videocam_rounded, color: Colors.white54, size: 28),
    ),
  );

  Widget _imagePlaceholder() => Container(
    color: AppColors.primaryLight,
    child: const Center(
      child: Icon(Icons.image_rounded, color: AppColors.primaryMid, size: 28),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String value, label, emoji;
  final Color color, textColor;
  const _StatCard({
    required this.value,
    required this.label,
    required this.emoji,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(color: textColor),
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label, emoji;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourcePickerSheet extends StatelessWidget {
  final VoidCallback onCameraPhoto,
      onGalleryPhoto,
      onCameraVideo,
      onGalleryVideo;
  const _SourcePickerSheet({
    required this.onCameraPhoto,
    required this.onGalleryPhoto,
    required this.onCameraVideo,
    required this.onGalleryVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingL),
      padding: const EdgeInsets.all(AppConstants.paddingXL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
      ),
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
          Text('Add a Memory', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 4),
          Text('Choose photo or video', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppConstants.paddingXL),
          // Photo row
          Text('📷  Photo', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppConstants.paddingS),
          Row(
            children: [
              Expanded(
                child: _SourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: AppColors.primaryLight,
                  iconColor: AppColors.primary,
                  onTap: onCameraPhoto,
                ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: _SourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: AppColors.accentPinkLight,
                  iconColor: AppColors.accentPink,
                  onTap: onGalleryPhoto,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingL),
          // Video row
          Text('🎥  Video', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppConstants.paddingS),
          Row(
            children: [
              Expanded(
                child: _SourceOption(
                  icon: Icons.videocam_rounded,
                  label: 'Camera',
                  color: AppColors.accentOrangeLight,
                  iconColor: AppColors.accentOrange,
                  onTap: onCameraVideo,
                ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: _SourceOption(
                  icon: Icons.video_library_rounded,
                  label: 'Gallery',
                  color: AppColors.accentBlueLight,
                  iconColor: AppColors.accentBlue,
                  onTap: onGalleryVideo,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
        ],
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, iconColor;
  final VoidCallback onTap;
  const _SourceOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.titleMedium.copyWith(color: iconColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddMemorySheet extends StatefulWidget {
  final String mediaPath;
  final bool isVideo;
  final BabyModel baby;
  final void Function(MemoryEntry) onSave;
  const _AddMemorySheet({
    required this.mediaPath,
    required this.isVideo,
    required this.baby,
    required this.onSave,
  });

  @override
  State<_AddMemorySheet> createState() => _AddMemorySheetState();
}

class _AddMemorySheetState extends State<_AddMemorySheet> {
  final _captionController = TextEditingController();
  MemoryTag _selectedTag = MemoryTag.everyday;
  bool _saving = false;
  VideoPlayerController? _previewController;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _previewController = VideoPlayerController.file(File(widget.mediaPath))
        ..initialize().then((_) {
          if (mounted) setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _previewController?.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'unknown';
      String? imageUrl;
      String? videoUrl;

      if (widget.isVideo) {
        videoUrl = await CloudinaryService.uploadMemoryVideo(
          file: File(widget.mediaPath),
          userId: userId,
          babyId: widget.baby.id,
        );
      } else {
        imageUrl = await CloudinaryService.uploadMemoryPhoto(
          file: File(widget.mediaPath),
          userId: userId,
          babyId: widget.baby.id,
        );
      }

      String savedId = DateTime.now().millisecondsSinceEpoch.toString();
      if (widget.baby.id.isNotEmpty) {
        final inserted = await Supabase.instance.client
            .from('memories')
            .insert({
              'baby_id': widget.baby.id,
              'user_id': userId,
              if (imageUrl != null) 'image_url': imageUrl,
              if (videoUrl != null) 'video_url': videoUrl,
              'caption': _captionController.text.trim().isEmpty
                  ? null
                  : _captionController.text.trim(),
              'tag': _selectedTag.dbValue,
              'age_months': widget.baby.ageInMonths,
              'memory_date': DateTime.now().toIso8601String().split('T').first,
            })
            .select()
            .single();
        savedId = inserted['id'] as String;
      }

      widget.onSave(
        MemoryEntry(
          id: savedId,
          babyId: widget.baby.id,
          imagePath: (!widget.isVideo && imageUrl == null)
              ? widget.mediaPath
              : null,
          imageUrl: imageUrl,
          videoPath: (widget.isVideo && videoUrl == null)
              ? widget.mediaPath
              : null,
          videoUrl: videoUrl,
          caption: _captionController.text.trim().isEmpty
              ? null
              : _captionController.text.trim(),
          date: DateTime.now(),
          tag: _selectedTag,
          ageMonths: widget.baby.ageInMonths,
        ),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save memory: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingL),
            Text('Save Memory', style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppConstants.paddingXL),
            // Preview
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              child: widget.isVideo
                  ? _buildVideoPreview()
                  : Image.file(
                      File(widget.mediaPath),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: AppConstants.paddingXL),
            Text('Caption', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.paddingS),
            TextField(
              controller: _captionController,
              maxLines: 2,
              maxLength: 150,
              decoration: InputDecoration(
                hintText: 'Write something about this moment...',
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
            Text('Tag this memory', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.paddingM),
            Wrap(
              spacing: AppConstants.paddingS,
              runSpacing: AppConstants.paddingS,
              children: MemoryTag.values.map((tag) {
                final sel = _selectedTag == tag;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTag = tag),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusFull,
                      ),
                      border: Border.all(
                        color: sel ? AppColors.primary : AppColors.divider,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(tag.emoji, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 5),
                        Text(
                          tag.label,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: sel ? Colors.white : AppColors.textPrimary,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppConstants.paddingXXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.isVideo ? 'Save Video 🎥' : 'Save Photo �',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    final ctrl = _previewController;
    if (ctrl == null || !ctrl.value.isInitialized) {
      return Container(
        height: 200,
        width: double.infinity,
        color: const Color(0xFF1A1A2E),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    }
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: ctrl.value.aspectRatio,
            child: VideoPlayer(ctrl),
          ),
          GestureDetector(
            onTap: () => setState(
              () => ctrl.value.isPlaying ? ctrl.pause() : ctrl.play(),
            ),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                ctrl.value.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoryDetailScreen extends StatefulWidget {
  final MemoryEntry memory;
  const _MemoryDetailScreen({required this.memory});

  @override
  State<_MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<_MemoryDetailScreen> {
  bool _deleting = false;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    if (widget.memory.isVideo) _initVideo();
  }

  Future<void> _initVideo() async {
    final url = widget.memory.videoUrl;
    final path = widget.memory.videoPath;
    if (url != null) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    } else if (path != null) {
      _videoController = VideoPlayerController.file(File(path));
    } else {
      return;
    }

    await _videoController!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: false,
      looping: false,
      allowFullScreen: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.primary,
        handleColor: AppColors.primary,
        backgroundColor: AppColors.divider,
        bufferedColor: AppColors.primaryMid,
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Text('Delete ${widget.memory.isVideo ? "Video" : "Photo"}?'),
        content: Text(
          'This will permanently delete this ${widget.memory.isVideo ? "video" : "photo"} and remove it from your diary. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    _deleteMemory();
  }

  Future<void> _deleteMemory() async {
    setState(() => _deleting = true);
    try {
      await Supabase.instance.client
          .from('memories')
          .delete()
          .eq('id', widget.memory.id)
          .select();
      if (widget.memory.imageUrl != null) {
        await CloudinaryService.deletePhoto(widget.memory.imageUrl!);
      }
      if (widget.memory.videoUrl != null) {
        await CloudinaryService.deletePhoto(widget.memory.videoUrl!);
      }
      if (mounted) {
        Navigator.pop(context, widget.memory.id);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _deleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Media
          Positioned.fill(child: _buildMedia()),
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingM,
                  vertical: AppConstants.paddingS,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.share_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: _deleting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                      ),
                      onPressed: _deleting ? null : _confirmDelete,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom info bar — only show when not playing video
          if (!widget.memory.isVideo || _chewieController == null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.paddingXL),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusFull,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.memory.tag.emoji,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.memory.tag.label,
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.memory.ageMonths != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusFull,
                                ),
                              ),
                              child: Text(
                                '${widget.memory.ageMonths} months old',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (widget.memory.caption != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          widget.memory.caption!,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(widget.memory.date),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedia() {
    if (widget.memory.isVideo) {
      if (_chewieController != null) {
        return Center(child: Chewie(controller: _chewieController!));
      }
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    // Photo
    return InteractiveViewer(
      child: widget.memory.imagePath != null
          ? Image.file(File(widget.memory.imagePath!), fit: BoxFit.contain)
          : widget.memory.imageUrl != null
          ? Image.network(widget.memory.imageUrl!, fit: BoxFit.contain)
          : const Center(
              child: Icon(Icons.image_rounded, color: Colors.white54, size: 64),
            ),
    );
  }
}
