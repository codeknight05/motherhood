import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/baby_avatar.dart';
import '../../../core/providers/baby_provider.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../models/baby_model.dart';
import '../../../models/milestone_model.dart';
import '../../../models/memory_model.dart';

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
          children: const [
            _MilestonesTab(),
            _MemoryDiaryTab(),
          ],
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
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
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
                const Icon(Icons.swap_horiz_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text('Change', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
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
          AppConstants.paddingL, 0, AppConstants.paddingL, AppConstants.paddingM),
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
        unselectedLabelStyle: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
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

class _MilestonesTabState extends ConsumerState<_MilestonesTab> {
  int _selectedAgeGroup = 2;

  static const List<Map<String, String>> _ageGroups = [
    {'label': '0-3\nMonths', 'emoji': '🍼'},
    {'label': '4-6\nMonths', 'emoji': '🌱'},
    {'label': '7-9\nMonths', 'emoji': '🧸'},
    {'label': '10-12\nMonths', 'emoji': '🎀'},
    {'label': '1-2\nYears', 'emoji': '🚶'},
  ];

  static const List<Map<String, String>> _ageBanners = [
    {'title': '0–3 Months', 'desc': 'Your newborn is discovering the world through senses and bonding.', 'emoji': '🍼'},
    {'title': '4–6 Months', 'desc': 'Your baby is becoming more alert, smiling and reaching for objects.', 'emoji': '🌱'},
    {'title': '7–9 Months', 'desc': 'Your baby is exploring more, becoming more independent, and showing curiosity.', 'emoji': '🧸'},
    {'title': '10–12 Months', 'desc': 'Your baby is pulling to stand and may be saying first words.', 'emoji': '🎀'},
    {'title': '1–2 Years', 'desc': 'Your toddler is walking, talking and developing a big personality.', 'emoji': '🚶'},
  ];

  @override
  Widget build(BuildContext context) {
    final milestones = sampleMilestones;
    final totalAchieved = milestones.fold<int>(0, (s, m) => s + m.achieved);
    final totalInProgress = milestones.fold<int>(0, (s, m) => s + m.inProgress);
    final totalItems = milestones.fold<int>(0, (s, m) => s + m.total);
    final totalNotStarted = totalItems - totalAchieved - totalInProgress;
    final percent = totalItems == 0 ? 0.0 : totalAchieved / totalItems;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingL, AppConstants.paddingL,
        AppConstants.paddingL, 100,
      ),
      children: [
        _buildAgeGroupSelector(),
        const SizedBox(height: AppConstants.paddingM),
        _buildAgeBanner(),
        const SizedBox(height: AppConstants.paddingM),
        _buildOverallProgress(totalAchieved, totalItems, totalInProgress, totalNotStarted, percent),
        const SizedBox(height: AppConstants.paddingXL),
        _buildDevelopmentAreas(milestones),
        const SizedBox(height: AppConstants.paddingM),
        _buildEncouragementCard(),
      ],
    );
  }

  Widget _buildAgeGroupSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _ageGroups.asMap().entries.map((e) {
          final i = e.key;
          final isSelected = _selectedAgeGroup == i;
          return Padding(
            padding: EdgeInsets.only(right: i < _ageGroups.length - 1 ? AppConstants.paddingS : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedAgeGroup = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_ageGroups[i]['emoji']!, style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 3),
                    Text(
                      _ageGroups[i]['label']!,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAgeBanner() {
    final banner = _ageBanners[_selectedAgeGroup];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(_selectedAgeGroup),
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
                  Text(banner['title']!, style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 6),
                  Text(banner['desc']!, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Text(banner['emoji']!, style: const TextStyle(fontSize: 52)),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallProgress(int achieved, int total, int inProgress, int notStarted, double percent) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Overall Progress', style: AppTextStyles.titleLarge),
              Text('$achieved / $total Achieved', style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: AppColors.primaryLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(percent * 100).toInt()}%',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          Wrap(
            spacing: AppConstants.paddingL,
            runSpacing: 4,
            children: [
              _ProgressLegend(color: AppColors.accentGreen, label: 'Achieved ($achieved)'),
              _ProgressLegend(color: AppColors.warning, label: 'In Progress ($inProgress)'),
              _ProgressLegend(color: AppColors.textHint, label: 'Not Started ($notStarted)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDevelopmentAreas(List<MilestoneCategoryProgress> milestones) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Development Areas', style: AppTextStyles.headlineSmall),
            Row(
              children: [
                Text('Why it matters?', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                const SizedBox(width: 2),
                const Icon(Icons.help_outline_rounded, size: 14, color: AppColors.primary),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingM),
        ...milestones.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
              child: _DevelopmentAreaCard(milestone: m),
            )),
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
            child: const Center(child: Text('⭐', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Great job, Mom! 🎉', style: AppTextStyles.titleLarge.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  '${baby.name} is meeting most of her milestones. Keep nurturing and engaging with her.',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
          const Text('🌟', style: TextStyle(fontSize: 32)),
        ],
      ),
    );
  }
}

// ─── Milestone sub-widgets ────────────────────────────────────────────────────

class _ProgressLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ProgressLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}

class _DevelopmentAreaCard extends StatelessWidget {
  final MilestoneCategoryProgress milestone;
  const _DevelopmentAreaCard({required this.milestone});

  Color get _bgColor {
    switch (milestone.category) {
      case MilestoneCategory.grossMotor: return AppColors.accentGreenLight;
      case MilestoneCategory.fineMotor: return AppColors.accentOrangeLight;
      case MilestoneCategory.language: return AppColors.primaryLight;
      case MilestoneCategory.socialEmotional: return AppColors.accentPinkLight;
      case MilestoneCategory.cognitive: return AppColors.accentBlueLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {},
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: _bgColor, borderRadius: BorderRadius.circular(AppConstants.radiusM)),
            child: Center(child: Text(milestone.category.emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(milestone.category.label, style: AppTextStyles.titleMedium),
                Text('${milestone.achieved} / ${milestone.total} Milestones Achieved', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Row(
            children: List.generate(milestone.total, (i) {
              MilestoneStatus s;
              if (i < milestone.achieved) { s = MilestoneStatus.achieved; }
              else if (i < milestone.achieved + milestone.inProgress) { s = MilestoneStatus.inProgress; }
              else { s = MilestoneStatus.notStarted; }
              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: _StatusDot(status: s),
              );
            }),
          ),
          const SizedBox(width: AppConstants.paddingS),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final MilestoneStatus status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData? icon;
    switch (status) {
      case MilestoneStatus.achieved: color = AppColors.accentGreen; icon = Icons.check_rounded;
      case MilestoneStatus.inProgress: color = AppColors.warning; icon = Icons.check_rounded;
      case MilestoneStatus.notStarted: color = AppColors.textHint; icon = null;
    }
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
        color: icon != null ? color : Colors.transparent,
        shape: BoxShape.circle,
        border: icon == null ? Border.all(color: color, width: 1.5) : null,
      ),
      child: icon != null ? Icon(icon, size: 12, color: Colors.white) : null,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB 2 — MEMORY DIARY
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

      final loaded = (res as List).map((m) => MemoryEntry(
        id: m['id'] as String,
        babyId: m['baby_id'] as String,
        imageUrl: m['image_url'] as String?,
        caption: m['caption'] as String?,
        date: DateTime.parse(m['memory_date'] as String),
        tag: memoryTagFromDb(m['tag'] as String? ?? 'everyday'),
        ageMonths: m['age_months'] as int?,
      )).toList();

      if (mounted) setState(() { _memories = loaded; _loadingMemories = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingMemories = false);
    }
  }

  List<MemoryEntry> get _filtered =>
      _selectedFilter == null ? _memories : _memories.where((m) => m.tag == _selectedFilter).toList();

  Map<String, List<MemoryEntry>> get _grouped {
    final map = <String, List<MemoryEntry>>{};
    for (final m in _filtered) {
      map.putIfAbsent(_monthLabel(m.date), () => []).add(m);
    }
    return map;
  }

  String _monthLabel(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.year}';
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1200);
      if (file == null || !mounted) return;
      _showAddSheet(file.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not access ${source == ImageSource.camera ? "camera" : "gallery"}. Check permissions.'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  void showSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SourcePickerSheet(
        onCamera: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
        onGallery: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
      ),
    );
  }

  void _showAddSheet(String path) {
    final baby = ref.read(babyProvider).baby ?? sampleBaby;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMemorySheet(
        imagePath: path,
        baby: baby,
        onSave: (e) => setState(() => _memories.insert(0, e)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    return Stack(
      children: [
        // Loading overlay
        if (_loadingMemories)
          const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5)),
        ListView(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingL, AppConstants.paddingL,
            AppConstants.paddingL, 120,
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
              ...grouped.entries.map((e) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMonthHeader(e.key, e.value.length),
                      const SizedBox(height: AppConstants.paddingM),
                      _buildGrid(e.value),
                      const SizedBox(height: AppConstants.paddingXL),
                    ],
                  )),
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
              label: Text('Add Memory', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    final baby = ref.watch(babyProvider).baby ?? sampleBaby;
    final milestoneCount = _memories.where((m) => m.tag == MemoryTag.milestone).length;
    return Row(
      children: [
        Expanded(child: _StatCard(value: '${_memories.length}', label: 'Memories', emoji: '📸', color: AppColors.primaryLight, textColor: AppColors.primary)),
        const SizedBox(width: AppConstants.paddingM),
        Expanded(child: _StatCard(value: '${baby.ageInMonths}', label: 'Months old', emoji: '🎂', color: AppColors.accentPinkLight, textColor: AppColors.accentPink)),
        const SizedBox(width: AppConstants.paddingM),
        Expanded(child: _StatCard(value: '$milestoneCount', label: 'Milestones', emoji: '🏆', color: AppColors.accentOrangeLight, textColor: AppColors.accentOrange)),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(label: 'All', emoji: '✨', isSelected: _selectedFilter == null, onTap: () => setState(() => _selectedFilter = null)),
          const SizedBox(width: AppConstants.paddingS),
          ...MemoryTag.values.map((tag) => Padding(
                padding: const EdgeInsets.only(right: AppConstants.paddingS),
                child: _FilterChip(
                  label: tag.label, emoji: tag.emoji,
                  isSelected: _selectedFilter == tag,
                  onTap: () => setState(() => _selectedFilter = _selectedFilter == tag ? null : tag),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(String month, int count) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(month, style: AppTextStyles.headlineSmall),
        const SizedBox(width: 8),
        Text('$count photos', style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildGrid(List<MemoryEntry> memories) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 6, mainAxisSpacing: 6, childAspectRatio: 1,
      ),
      itemCount: memories.length,
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _MemoryDetailScreen(memory: memories[i]))),
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
              width: 80, height: 80,
              decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              child: const Center(child: Text('📷', style: TextStyle(fontSize: 36))),
            ),
            const SizedBox(height: AppConstants.paddingL),
            Text('No memories yet', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 6),
            Text('Tap Add Memory to capture your first moment', style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
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
          memory.imagePath != null
              ? Image.file(File(memory.imagePath!), fit: BoxFit.cover)
              : memory.imageUrl != null
                  ? Image.network(memory.imageUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: AppColors.primaryLight,
                          child: const Center(child: Icon(Icons.image_rounded, color: AppColors.primaryMid, size: 28))))
                  : Container(color: AppColors.primaryLight,
                      child: const Center(child: Icon(Icons.image_rounded, color: AppColors.primaryMid, size: 28))),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            top: 5, left: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(6)),
              child: Text(memory.tag.emoji, style: const TextStyle(fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label, emoji;
  final Color color, textColor;
  const _StatCard({required this.value, required this.label, required this.emoji, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppConstants.radiusL)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.headlineMedium.copyWith(color: textColor)),
          Text(label, style: AppTextStyles.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label, emoji;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.emoji, required this.isSelected, required this.onTap});

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
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Text(label, style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            )),
          ],
        ),
      ),
    );
  }
}

class _SourcePickerSheet extends StatelessWidget {
  final VoidCallback onCamera, onGallery;
  const _SourcePickerSheet({required this.onCamera, required this.onGallery});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingL),
      padding: const EdgeInsets.all(AppConstants.paddingXL),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusXXL)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: AppConstants.paddingL),
          Text('Add a Memory', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 6),
          Text('Choose how to add your photo', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppConstants.paddingXL),
          Row(
            children: [
              Expanded(child: _SourceOption(icon: Icons.camera_alt_rounded, label: 'Camera', color: AppColors.primaryLight, iconColor: AppColors.primary, onTap: onCamera)),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(child: _SourceOption(icon: Icons.photo_library_rounded, label: 'Gallery', color: AppColors.accentPinkLight, iconColor: AppColors.accentPink, onTap: onGallery)),
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
  const _SourceOption({required this.icon, required this.label, required this.color, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppConstants.radiusL)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.titleMedium.copyWith(color: iconColor)),
          ],
        ),
      ),
    );
  }
}

class _AddMemorySheet extends StatefulWidget {
  final String imagePath;
  final BabyModel baby;
  final void Function(MemoryEntry) onSave;
  const _AddMemorySheet({required this.imagePath, required this.baby, required this.onSave});

  @override
  State<_AddMemorySheet> createState() => _AddMemorySheetState();
}

class _AddMemorySheetState extends State<_AddMemorySheet> {
  final _captionController = TextEditingController();
  MemoryTag _selectedTag = MemoryTag.everyday;
  bool _saving = false;

  @override
  void dispose() { _captionController.dispose(); super.dispose(); }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      String? imageUrl;

      // Upload to Cloudinary if we have a local file
      if (widget.imagePath.isNotEmpty) {
        imageUrl = await CloudinaryService.uploadMemoryPhoto(
          file: File(widget.imagePath),
          userId: Supabase.instance.client.auth.currentUser?.id ?? 'unknown',
          babyId: widget.baby.id,
        );
      }

      // Save to Supabase memories table
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null && widget.baby.id.isNotEmpty) {
        await Supabase.instance.client.from('memories').insert({
          'baby_id': widget.baby.id,
          'user_id': userId,
          'image_url': imageUrl,
          'caption': _captionController.text.trim().isEmpty ? null : _captionController.text.trim(),
          'tag': _selectedTag.dbValue,
          'age_months': widget.baby.ageInMonths,
          'memory_date': DateTime.now().toIso8601String().split('T').first,
        });
      }

      // Also update local state immediately for instant UI feedback
      widget.onSave(MemoryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        babyId: widget.baby.id,
        imagePath: imageUrl == null ? widget.imagePath : null,
        imageUrl: imageUrl,
        caption: _captionController.text.trim().isEmpty ? null : _captionController.text.trim(),
        date: DateTime.now(),
        tag: _selectedTag,
        ageMonths: widget.baby.ageInMonths,
      ));

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
        left: AppConstants.paddingXL, right: AppConstants.paddingXL,
        top: AppConstants.paddingXL, bottom: AppConstants.paddingXL + bottomInset,
      ),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusXXL)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: AppConstants.paddingL),
            Text('Save Memory', style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppConstants.paddingXL),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              child: Image.file(File(widget.imagePath), height: 200, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: AppConstants.paddingXL),
            Text('Caption', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.paddingS),
            TextField(
              controller: _captionController,
              maxLines: 2, maxLength: 150,
              decoration: InputDecoration(
                hintText: 'Write something about this moment...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                filled: true, fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM), borderSide: BorderSide.none),
                counterStyle: AppTextStyles.labelSmall,
              ),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppConstants.paddingL),
            Text('Tag this memory', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.paddingM),
            Wrap(
              spacing: AppConstants.paddingS, runSpacing: AppConstants.paddingS,
              children: MemoryTag.values.map((tag) {
                final sel = _selectedTag == tag;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTag = tag),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                      border: Border.all(color: sel ? AppColors.primary : AppColors.divider, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(tag.emoji, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 5),
                        Text(tag.label, style: AppTextStyles.labelMedium.copyWith(
                          color: sel ? Colors.white : AppColors.textPrimary,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                        )),
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
                  backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Save Memory 💾', style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryDetailScreen extends StatelessWidget {
  final MemoryEntry memory;
  const _MemoryDetailScreen({required this.memory});

  String _formatDate(DateTime d) {
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              child: memory.imagePath != null
                  ? Image.file(File(memory.imagePath!), fit: BoxFit.contain)
                  : memory.imageUrl != null
                      ? Image.network(memory.imageUrl!, fit: BoxFit.contain)
                      : const Center(child: Icon(Icons.image_rounded, color: Colors.white54, size: 64)),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM, vertical: AppConstants.paddingS),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                        child: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.paddingXL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(memory.tag.emoji, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(memory.tag.label, style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                        if (memory.ageMonths != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                            ),
                            child: Text('${memory.ageMonths} months old', style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                    if (memory.caption != null) ...[
                      const SizedBox(height: 10),
                      Text(memory.caption!, style: AppTextStyles.bodyLarge.copyWith(color: Colors.white)),
                    ],
                    const SizedBox(height: 6),
                    Text(_formatDate(memory.date), style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
