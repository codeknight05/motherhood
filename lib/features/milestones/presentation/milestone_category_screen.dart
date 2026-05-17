import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/milestone_model.dart';
import 'milestone_detail_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Milestone Category Screen — e.g. "Gross Motor" list with progress
// ═══════════════════════════════════════════════════════════════════════════

class MilestoneCategoryScreen extends StatefulWidget {
  final MilestoneCategoryProgress progress;
  final Color accentColor;
  final Color bgColor;
  final String babyName;
  final String babyAge;
  final void Function(String itemId, MilestoneStatus status) onStatusChanged;

  const MilestoneCategoryScreen({
    super.key,
    required this.progress,
    required this.accentColor,
    required this.bgColor,
    required this.babyName,
    required this.babyAge,
    required this.onStatusChanged,
  });

  @override
  State<MilestoneCategoryScreen> createState() => _MilestoneCategoryScreenState();
}

class _MilestoneCategoryScreenState extends State<MilestoneCategoryScreen> {
  late List<MilestoneItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.progress.items);
  }

  int get _achieved => _items.where((i) => i.status == MilestoneStatus.achieved).length;
  int get _total => _items.length;
  double get _percent => _total == 0 ? 0 : _achieved / _total;

  void _updateStatus(String itemId, MilestoneStatus status) {
    setState(() {
      final idx = _items.indexWhere((i) => i.id == itemId);
      if (idx != -1) {
        _items[idx] = _items[idx].copyWith(
          status: status,
          achievedDate: status == MilestoneStatus.achieved
              ? _items[idx].achievedDate ?? _todayString()
              : null,
        );
      }
    });
    widget.onStatusChanged(itemId, status);
  }

  String _todayString() {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String get _progressMessage {
    if (_percent >= 1.0) return 'All milestones achieved! Amazing! 🎉';
    if (_percent >= 0.6) return 'Keep encouraging! Your baby is doing great 💜';
    if (_percent >= 0.3) return 'Great progress! Keep going 🌟';
    return 'Every step counts. You\'re doing great! 💪';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildHeroCard()),
          SliverToBoxAdapter(child: _buildProgressSection()),
          SliverToBoxAdapter(child: _buildMilestoneListHeader()),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _MilestoneListRow(
                item: _items[i],
                accentColor: widget.accentColor,
                bgColor: widget.bgColor,
                onTap: () => _openDetail(_items[i]),
              ),
              childCount: _items.length,
            ),
          ),
          SliverToBoxAdapter(child: _buildParentingTip()),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(widget.progress.category.label, style: AppTextStyles.headlineMedium),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline_rounded, color: AppColors.textPrimary, size: 22),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppConstants.paddingL, AppConstants.paddingM, AppConstants.paddingL, 0),
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: widget.bgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Row(
        children: [
          // Baby image placeholder
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: widget.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Center(child: Text(widget.progress.category.emoji, style: const TextStyle(fontSize: 40))),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${widget.progress.category.label} Skills', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  _categoryDescription,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            widget.babyName,
                            style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(width: 4, height: 4, margin: const EdgeInsets.symmetric(horizontal: 5), decoration: const BoxDecoration(color: AppColors.textHint, shape: BoxShape.circle)),
                        Flexible(
                          child: Text(
                            widget.babyAge,
                            style: AppTextStyles.labelSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.textHint),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppConstants.paddingL, AppConstants.paddingM, AppConstants.paddingL, 0),
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_items.first.ageRange} Progress', style: AppTextStyles.titleLarge),
              Text('$_achieved/$_total Achieved', style: AppTextStyles.labelMedium.copyWith(color: widget.accentColor, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            child: LinearProgressIndicator(
              value: _percent,
              minHeight: 10,
              backgroundColor: widget.bgColor,
              valueColor: AlwaysStoppedAnimation<Color>(widget.accentColor),
            ),
          ),
          const SizedBox(height: AppConstants.paddingS),
          Row(
            children: [
              Text(_progressMessage, style: AppTextStyles.bodySmall.copyWith(color: widget.accentColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneListHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppConstants.paddingL, AppConstants.paddingXL, AppConstants.paddingL, AppConstants.paddingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Milestones in this age', style: AppTextStyles.headlineSmall),
          GestureDetector(
            onTap: () {},
            child: Text('What are milestones?', style: AppTextStyles.labelMedium.copyWith(color: widget.accentColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildParentingTip() {
    // Find a tip from any item in this category
    final tip = _items.firstWhere((i) => i.parentingTip != null, orElse: () => _items.first).parentingTip
        ?? 'Give your baby daily practice time. It strengthens skills and builds confidence!';

    return Container(
      margin: const EdgeInsets.fromLTRB(AppConstants.paddingL, AppConstants.paddingXL, AppConstants.paddingL, 0),
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: widget.bgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: widget.accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: widget.accentColor, shape: BoxShape.circle),
            child: const Center(child: Text('💡', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Parenting Tip', style: AppTextStyles.titleMedium.copyWith(color: widget.accentColor)),
                const SizedBox(height: 3),
                Text(tip, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const Text('🪀', style: TextStyle(fontSize: 28)),
        ],
      ),
    );
  }

  String get _categoryDescription {
    switch (widget.progress.category) {
      case MilestoneCategory.grossMotor:   return 'Track your baby\'s physical development and movement milestones.';
      case MilestoneCategory.fineMotor:    return 'Track your baby\'s hand and finger coordination milestones.';
      case MilestoneCategory.language:     return 'Track your baby\'s communication and language development.';
      case MilestoneCategory.social:       return 'Track your baby\'s social bonding and emotional growth.';
      case MilestoneCategory.cognitive:    return 'Track your baby\'s thinking, learning and problem-solving skills.';
      case MilestoneCategory.feedingSleep: return 'Track feeding patterns, sleep routines and self-regulation.';
    }
  }

  void _openDetail(MilestoneItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MilestoneDetailScreen(
          item: item,
          accentColor: widget.accentColor,
          bgColor: widget.bgColor,
          onStatusChanged: (s) => _updateStatus(item.id, s),
        ),
      ),
    );
  }
}

// ── Milestone list row ────────────────────────────────────────────────────────


class _MilestoneListRow extends StatelessWidget {
  final MilestoneItem item;
  final Color accentColor, bgColor;
  final VoidCallback onTap;

  const _MilestoneListRow({
    required this.item,
    required this.accentColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppConstants.paddingL, 0, AppConstants.paddingL, AppConstants.paddingS),
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Center(
                child: Text(item.category.emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item.title, style: AppTextStyles.titleMedium),
                  if (item.description.isNotEmpty)
                    Text(
                      item.description,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.paddingS),
            _StatusBadge(status: item.status, accentColor: accentColor),
            const SizedBox(width: AppConstants.paddingS),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final MilestoneStatus status;
  final Color accentColor;
  const _StatusBadge({required this.status, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MilestoneStatus.achieved:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.accentGreen, size: 16),
            const SizedBox(width: 4),
            Text(
              'Achieved',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.accentGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      case MilestoneStatus.inProgress:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16, height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accentColor, width: 2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'In Progress',
              style: AppTextStyles.labelMedium.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      case MilestoneStatus.notStarted:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline_rounded, color: AppColors.textHint, size: 14),
            const SizedBox(width: 4),
            Text(
              'Not Started',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textHint),
            ),
          ],
        );
    }
  }
}
