import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/milestone_model.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Milestone Detail Screen — 4 tabs: About · Activities · Signs · When to worry
// ═══════════════════════════════════════════════════════════════════════════

class MilestoneDetailScreen extends StatefulWidget {
  final MilestoneItem item;
  final Color accentColor;
  final Color bgColor;
  final void Function(MilestoneStatus) onStatusChanged;

  const MilestoneDetailScreen({
    super.key,
    required this.item,
    required this.accentColor,
    required this.bgColor,
    required this.onStatusChanged,
  });

  @override
  State<MilestoneDetailScreen> createState() => _MilestoneDetailScreenState();
}

class _MilestoneDetailScreenState extends State<MilestoneDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late MilestoneItem _item;

  static const _tabs = [
    _TabInfo(icon: Icons.menu_book_outlined, label: 'About'),
    _TabInfo(icon: Icons.directions_run_rounded, label: 'Activities'),
    _TabInfo(icon: Icons.flag_outlined, label: 'Signs to look for'),
    _TabInfo(icon: Icons.shield_outlined, label: 'When to worry'),
  ];

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateStatus(MilestoneStatus s) {
    setState(() {
      _item = _item.copyWith(
        status: s,
        achievedDate: s == MilestoneStatus.achieved
            ? _item.achievedDate ?? _todayString()
            : null,
      );
    });
    widget.onStatusChanged(s);
  }

  String _todayString() {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildUpdateBar(),
      body: NestedScrollView(
        headerSliverBuilder: (_, innerScrolled) => [
          // 1. Standard app bar — title + actions only, no dynamic content
          SliverAppBar(
            pinned: true,
            forceElevated: innerScrolled,
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 1,
            shadowColor: AppColors.divider,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              _item.title,
              style: AppTextStyles.headlineSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border_rounded, color: AppColors.textPrimary, size: 22),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textPrimary, size: 22),
                onPressed: () {},
              ),
            ],
          ),
          // 2. Hero header — scrolls away with content
          SliverToBoxAdapter(child: _buildHeroHeader()),
          // 3. Tab bar — sticks below the app bar when scrolled
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              tabBar: _buildTabBar(),
              color: AppColors.background,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _AboutTab(item: _item, accentColor: widget.accentColor, bgColor: widget.bgColor),
            _ActivitiesTab(item: _item, accentColor: widget.accentColor),
            _SignsTab(item: _item),
            _WhenToWorryTab(item: _item, accentColor: widget.accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingL, AppConstants.paddingS,
        AppConstants.paddingL, AppConstants.paddingM,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji illustration
            Container(
              width: 68, height: 68,
              decoration: BoxDecoration(
                color: widget.bgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(_item.category.emoji, style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: AppConstants.paddingM),
            // Title + description + age chip
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _item.category.label.toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: widget.accentColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _item.title,
                    style: AppTextStyles.headlineMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _item.description,
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.bgColor,
                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                      border: Border.all(color: widget.accentColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _item.ageRange,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: widget.accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.paddingS),
            // Status card — constrained width so it doesn't push content off screen
            SizedBox(
              width: 110,
              child: _StatusCard(
                item: _item,
                accentColor: widget.accentColor,
                onEdit: () => _showStatusPicker(),
              ),
            ),
          ],
        ),
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
        indicatorColor: widget.accentColor,
        indicatorWeight: 2.5,
        dividerColor: AppColors.divider,
        labelColor: widget.accentColor,
        unselectedLabelColor: AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
        tabs: _tabs.map((t) => Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(t.icon, size: 15),
              const SizedBox(width: 5),
              Text(t.label, style: AppTextStyles.labelLarge),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildUpdateBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingL, AppConstants.paddingM,
        AppConstants.paddingL,
        AppConstants.paddingM + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _showStatusPicker(),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Update Progress'),
          style: OutlinedButton.styleFrom(
            foregroundColor: widget.accentColor,
            side: BorderSide(color: widget.accentColor, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
            textStyle: AppTextStyles.titleMedium,
          ),
        ),
      ),
    );
  }

  void _showStatusPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _StatusPickerSheet(
        current: _item.status,
        accentColor: widget.accentColor,
        onSelected: (s) { Navigator.pop(context); _updateStatus(s); },
      ),
    );
  }
}

// ── Sticky tab bar delegate ───────────────────────────────────────────────────

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;
  final Color color;
  const _StickyTabBarDelegate({required this.tabBar, required this.color});

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: color,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate old) =>
      old.tabBar != tabBar || old.color != color;
}

// ── Tab info helper ───────────────────────────────────────────────────────────

class _TabInfo {
  final IconData icon;
  final String label;
  const _TabInfo({required this.icon, required this.label});
}

// ── Status card ───────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final MilestoneItem item;
  final Color accentColor;
  final VoidCallback onEdit;
  const _StatusCard({required this.item, required this.accentColor, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final isAchieved = item.status == MilestoneStatus.achieved;
    final isInProgress = item.status == MilestoneStatus.inProgress;
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingS),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Milestone Status',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAchieved ? Icons.check_circle_rounded : isInProgress ? Icons.timelapse_rounded : Icons.radio_button_unchecked_rounded,
                color: isAchieved ? AppColors.accentGreen : isInProgress ? AppColors.warning : AppColors.textHint,
                size: 14,
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  isAchieved ? 'Achieved' : isInProgress ? 'In Progress' : 'Not Started',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isAchieved ? AppColors.accentGreen : isInProgress ? AppColors.warning : AppColors.textHint,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (item.achievedDate != null) ...[
            const SizedBox(height: 4),
            Text('Achieved on', style: AppTextStyles.labelSmall),
            Text(item.achievedDate!, style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onEdit,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit', style: AppTextStyles.labelSmall.copyWith(color: accentColor, fontWeight: FontWeight.w700)),
                const SizedBox(width: 3),
                Icon(Icons.edit_rounded, size: 11, color: accentColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status picker sheet ───────────────────────────────────────────────────────

class _StatusPickerSheet extends StatelessWidget {
  final MilestoneStatus current;
  final Color accentColor;
  final void Function(MilestoneStatus) onSelected;
  const _StatusPickerSheet({required this.current, required this.accentColor, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingL),
      padding: const EdgeInsets.all(AppConstants.paddingXL),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusXXL)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: AppConstants.paddingL),
          Text('Update Progress', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppConstants.paddingXL),
          _StatusOption(status: MilestoneStatus.achieved, label: 'Achieved', sub: 'Baby has mastered this milestone', icon: Icons.check_circle_rounded, color: AppColors.accentGreen, isSelected: current == MilestoneStatus.achieved, onTap: () => onSelected(MilestoneStatus.achieved)),
          const SizedBox(height: AppConstants.paddingM),
          _StatusOption(status: MilestoneStatus.inProgress, label: 'In Progress', sub: 'Baby is working on this', icon: Icons.timelapse_rounded, color: AppColors.warning, isSelected: current == MilestoneStatus.inProgress, onTap: () => onSelected(MilestoneStatus.inProgress)),
          const SizedBox(height: AppConstants.paddingM),
          _StatusOption(status: MilestoneStatus.notStarted, label: 'Not Started', sub: 'Haven\'t tried this yet', icon: Icons.radio_button_unchecked_rounded, color: AppColors.textHint, isSelected: current == MilestoneStatus.notStarted, onTap: () => onSelected(MilestoneStatus.notStarted)),
          const SizedBox(height: AppConstants.paddingL),
        ],
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final MilestoneStatus status;
  final String label, sub;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  const _StatusOption({required this.status, required this.label, required this.sub, required this.icon, required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : AppColors.background,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: isSelected ? color : AppColors.divider, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: AppTextStyles.titleMedium.copyWith(color: color)),
                  Text(sub, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB 1 — ABOUT
// ═══════════════════════════════════════════════════════════════════════════

class _AboutTab extends StatelessWidget {
  final MilestoneItem item;
  final Color accentColor;
  final Color bgColor;
  const _AboutTab({required this.item, required this.accentColor, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppConstants.paddingL, AppConstants.paddingL, AppConstants.paddingL, 100),
      children: [
        Text('What this milestone looks like', style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppConstants.paddingM),
        // Two video placeholder cards
        Row(
          children: [
            Expanded(child: _VideoCard(label: 'Front to Back', caption: 'Baby rolls from lying on tummy\nto lying on back.', accentColor: accentColor, bgColor: bgColor)),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(child: _VideoCard(label: 'Back to Front', caption: 'Baby rolls from lying on back\nto lying on tummy.', accentColor: accentColor, bgColor: bgColor)),
          ],
        ),
        const SizedBox(height: AppConstants.paddingL),
        // Tip banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL, vertical: AppConstants.paddingM),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Text(
                  'Every baby develops at their own pace. Celebrate small steps!',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.paddingXL),
        Text('How to encourage', style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppConstants.paddingM),
        // Encourage list from activities (first 4)
        ...item.activities.take(4).map((a) => _EncourageRow(activity: a, accentColor: accentColor, bgColor: bgColor)),
        if (item.activities.isEmpty) ...[
          _EncourageRow(activity: const MilestoneActivity(title: 'Daily practice', description: 'Incorporate practice into your daily routine.', emoji: '🌟', steps: []), accentColor: accentColor, bgColor: bgColor),
          _EncourageRow(activity: const MilestoneActivity(title: 'Make it fun', description: 'Use smiles, songs and encouragement.', emoji: '😊', steps: []), accentColor: accentColor, bgColor: bgColor),
        ],
        if (item.status == MilestoneStatus.achieved) ...[
          const SizedBox(height: AppConstants.paddingXL),
          Text('Track Progress', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppConstants.paddingM),
          _TrackProgressCard(item: item, accentColor: accentColor),
        ],
      ],
    );
  }
}

class _VideoCard extends StatelessWidget {
  final String label, caption;
  final Color accentColor, bgColor;
  const _VideoCard({required this.label, required this.caption, required this.accentColor, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 110,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(color: accentColor.withValues(alpha: 0.2)),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 6, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  ),
                  child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: accentColor, fontWeight: FontWeight.w700)),
                ),
              ),
              Center(
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                  child: Icon(Icons.play_arrow_rounded, color: accentColor, size: 22),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(caption, style: AppTextStyles.labelSmall, maxLines: 2),
      ],
    );
  }
}

class _EncourageRow extends StatelessWidget {
  final MilestoneActivity activity;
  final Color accentColor, bgColor;
  const _EncourageRow({required this.activity, required this.accentColor, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingS),
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Center(child: Text(activity.emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(activity.title, style: AppTextStyles.titleMedium),
                Text(activity.description, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
        ],
      ),
    );
  }
}

class _TrackProgressCard extends StatelessWidget {
  final MilestoneItem item;
  final Color accentColor;
  const _TrackProgressCard({required this.item, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppConstants.radiusS)),
            child: Icon(Icons.calendar_today_rounded, color: accentColor, size: 18),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Achieved on ${item.achievedDate ?? "—"}', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                Text('How did your baby do?', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit', style: AppTextStyles.labelMedium.copyWith(color: accentColor, fontWeight: FontWeight.w700)),
                const SizedBox(width: 3),
                Icon(Icons.edit_rounded, size: 12, color: accentColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB 2 — ACTIVITIES
// ═══════════════════════════════════════════════════════════════════════════

class _ActivitiesTab extends StatefulWidget {
  final MilestoneItem item;
  final Color accentColor;
  const _ActivitiesTab({required this.item, required this.accentColor});

  @override
  State<_ActivitiesTab> createState() => _ActivitiesTabState();
}

class _ActivitiesTabState extends State<_ActivitiesTab> {
  String _selectedFilter = 'All Activities';

  List<MilestoneActivity> get _filtered {
    if (_selectedFilter == 'All Activities') return widget.item.activities;
    return widget.item.activities.where((a) => a.filter == _selectedFilter).toList();
  }

  List<String> get _filters {
    if (widget.item.activityFilters.isNotEmpty) return widget.item.activityFilters;
    return ['All Activities'];
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.item.activitySectionTitle ?? 'Activities to encourage ${widget.item.title.toLowerCase()}';
    final activities = _filtered;

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppConstants.paddingL, AppConstants.paddingL, AppConstants.paddingL, 100),
      children: [
        Text(title, style: AppTextStyles.headlineSmall),
        const SizedBox(height: 4),
        Text('Try these simple and fun activities to help your baby build skills.', style: AppTextStyles.bodySmall),
        const SizedBox(height: AppConstants.paddingM),
        // Filter chips
        if (_filters.length > 1) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((f) {
                final isSel = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: AppConstants.paddingS),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSel ? widget.accentColor.withValues(alpha: 0.12) : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                        border: Border.all(color: isSel ? widget.accentColor : AppColors.divider),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (f == 'Tips') const Text('💡', style: TextStyle(fontSize: 13)),
                          if (f == 'Tips') const SizedBox(width: 4),
                          Text(f, style: AppTextStyles.labelMedium.copyWith(
                            color: isSel ? widget.accentColor : AppColors.textSecondary,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          )),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppConstants.paddingL),
        ],
        if (activities.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎯', style: TextStyle(fontSize: 40)),
                const SizedBox(height: AppConstants.paddingM),
                Text('No activities for this filter', style: AppTextStyles.bodyMedium),
              ],
            )),
          )
        else
          ...activities.map((a) => _ActivityCard(activity: a, accentColor: widget.accentColor)),
        const SizedBox(height: AppConstants.paddingL),
        // Make it fun banner
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          decoration: BoxDecoration(
            color: widget.accentColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: widget.accentColor, shape: BoxShape.circle),
                child: const Center(child: Text('💡', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Make it fun!', style: AppTextStyles.titleMedium.copyWith(color: widget.accentColor)),
                    Text('Use lots of smiles, encouragement and praise.\nCelebrate every little effort!', style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const Text('🌈', style: TextStyle(fontSize: 28)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final MilestoneActivity activity;
  final Color accentColor;
  const _ActivityCard({required this.activity, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppConstants.radiusL),
              bottomLeft: Radius.circular(AppConstants.radiusL),
            ),
            child: Container(
              width: 110, height: 130,
              color: accentColor.withValues(alpha: 0.08),
              child: Center(child: Text(activity.emoji, style: const TextStyle(fontSize: 44))),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.12), shape: BoxShape.circle),
                        child: Center(child: Text(activity.emoji, style: const TextStyle(fontSize: 14))),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(activity.title, style: AppTextStyles.titleMedium)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(activity.description, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppConstants.paddingS),
                  ...activity.steps.take(3).toList().asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 16, height: 16,
                          decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                          child: Center(child: Text('${e.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))),
                        ),
                        const SizedBox(width: 6),
                        Expanded(child: Text(e.value, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary))),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppConstants.paddingM, right: AppConstants.paddingS),
            child: Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB 3 — SIGNS TO LOOK FOR
// ═══════════════════════════════════════════════════════════════════════════

class _SignsTab extends StatelessWidget {
  final MilestoneItem item;
  const _SignsTab({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppConstants.paddingL, AppConstants.paddingL, AppConstants.paddingL, 100),
      children: [
        Text('Signs to look for', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 4),
        Text('These signs show your baby is developing ${item.title.toLowerCase()} skills.', style: AppTextStyles.bodySmall),
        const SizedBox(height: AppConstants.paddingL),
        // Positive signs card
        if (item.signsToLookFor.isNotEmpty) ...[
          _SignsGroupCard(
            title: 'Positive signs',
            subtitle: 'Your baby is on track!',
            emoji: '😊',
            color: AppColors.accentGreen,
            colorLight: AppColors.accentGreenLight,
            signs: item.signsToLookFor,
            isPositive: true,
          ),
          const SizedBox(height: AppConstants.paddingM),
        ],
        // Watch signs card
        if (item.watchSigns.isNotEmpty) ...[
          _SignsGroupCard(
            title: 'Signs to watch',
            subtitle: 'May need more time and practice.',
            emoji: '⚠️',
            color: AppColors.accentOrange,
            colorLight: AppColors.accentOrangeLight,
            signs: item.watchSigns,
            isPositive: false,
          ),
          const SizedBox(height: AppConstants.paddingL),
        ],
        // Every baby is unique banner
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Center(child: Text('💡', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Every baby is unique!', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                    Text('Compare your baby with their own progress, not with other babies.', style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SignsGroupCard extends StatelessWidget {
  final String title, subtitle, emoji;
  final Color color, colorLight;
  final List<MilestoneSign> signs;
  final bool isPositive;
  const _SignsGroupCard({required this.title, required this.subtitle, required this.emoji, required this.color, required this.colorLight, required this.signs, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: AppConstants.paddingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: AppTextStyles.titleMedium.copyWith(color: color)),
                      Text(subtitle, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white),
          ...signs.map((s) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM, vertical: AppConstants.paddingM),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isPositive ? Icons.check_circle_rounded : Icons.circle,
                      color: color,
                      size: isPositive ? 18 : 10,
                    ),
                    const SizedBox(width: AppConstants.paddingS),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(s.title, style: AppTextStyles.titleMedium),
                          Text(s.description, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (s != signs.last) Divider(height: 1, color: color.withValues(alpha: 0.1)),
            ],
          )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB 4 — WHEN TO WORRY
// ═══════════════════════════════════════════════════════════════════════════

class _WhenToWorryTab extends StatelessWidget {
  final MilestoneItem item;
  final Color accentColor;
  const _WhenToWorryTab({required this.item, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppConstants.paddingL, AppConstants.paddingL, AppConstants.paddingL, 100),
      children: [
        Text('When to worry', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 4),
        Text('While every baby develops at their own pace, talk to your doctor if you notice any of the following.', style: AppTextStyles.bodySmall),
        const SizedBox(height: AppConstants.paddingL),
        if (item.warnings.isEmpty) ...[
          _WarningRow(warning: MilestoneWarning(title: 'No progress after several weeks', description: 'If you see no improvement despite regular practice, consult your paediatrician.', emoji: '📅')),
          _WarningRow(warning: MilestoneWarning(title: 'You have any concerns', description: 'If something doesn\'t feel right, trust your instincts and reach out to your doctor.', emoji: '💬')),
        ] else
          ...item.warnings.map((w) => _WarningRow(warning: w)),
        const SizedBox(height: AppConstants.paddingM),
        // Early support card
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          decoration: BoxDecoration(
            color: AppColors.accentPinkLight,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(color: AppColors.accentPink.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(color: AppColors.accentPink, shape: BoxShape.circle),
                child: const Center(child: Text('🛡️', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Early support makes a big difference!', style: AppTextStyles.titleMedium.copyWith(color: AppColors.accentPink)),
                    Text('If you have concerns, your doctor can guide you or refer you to a specialist if needed.', style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const Text('💗', style: TextStyle(fontSize: 28)),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.paddingM),
        // Remember card
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          child: Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 22)),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Remember', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                    Text('Every baby is unique and grows at their own pace.\nYou\'re doing a great job!', style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WarningRow extends StatelessWidget {
  final MilestoneWarning warning;
  const _WarningRow({required this.warning});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingS),
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentPinkLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Center(child: Text(warning.emoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(warning.title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(warning.description, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
        ],
      ),
    );
  }
}
