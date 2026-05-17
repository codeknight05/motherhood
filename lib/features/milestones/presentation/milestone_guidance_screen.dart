import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/milestone_model.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Milestone Guidance Screen — 7 sections for a category × age band
// Navigation: Milestones tab → category card → here
// ═══════════════════════════════════════════════════════════════════════════

class MilestoneGuidanceScreen extends StatefulWidget {
  final CategoryGuidance guidance;
  final String babyName;
  final String babyAge;
  final void Function(String milestoneId, MilestoneStatus status) onStatusChanged;

  const MilestoneGuidanceScreen({
    super.key,
    required this.guidance,
    required this.babyName,
    required this.babyAge,
    required this.onStatusChanged,
  });

  @override
  State<MilestoneGuidanceScreen> createState() => _MilestoneGuidanceScreenState();
}

class _MilestoneGuidanceScreenState extends State<MilestoneGuidanceScreen> {
  late CategoryGuidance _guidance;

  Color get _accent {
    switch (_guidance.category) {
      case MilestoneCategory.grossMotor:   return AppColors.accentGreen;
      case MilestoneCategory.fineMotor:    return AppColors.accentOrange;
      case MilestoneCategory.language:     return AppColors.primary;
      case MilestoneCategory.cognitive:    return AppColors.accentBlue;
      case MilestoneCategory.social:       return AppColors.accentPink;
      case MilestoneCategory.feedingSleep: return const Color(0xFFFF8F00);
    }
  }

  Color get _bg {
    switch (_guidance.category) {
      case MilestoneCategory.grossMotor:   return AppColors.accentGreenLight;
      case MilestoneCategory.fineMotor:    return AppColors.accentOrangeLight;
      case MilestoneCategory.language:     return AppColors.primaryLight;
      case MilestoneCategory.cognitive:    return AppColors.accentBlueLight;
      case MilestoneCategory.social:       return AppColors.accentPinkLight;
      case MilestoneCategory.feedingSleep: return const Color(0xFFFFF8E1);
    }
  }

  @override
  void initState() {
    super.initState();
    _guidance = widget.guidance;
  }

  void _updateStatus(String id, MilestoneStatus status) {
    setState(() => _guidance = _guidance.withUpdatedMilestone(id, status));
    widget.onStatusChanged(id, status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildHeroCard()),
          SliverToBoxAdapter(child: _buildSection1About()),
          SliverToBoxAdapter(child: _buildSection2Milestones()),
          SliverToBoxAdapter(child: _buildSection3Activities()),
          SliverToBoxAdapter(child: _buildSection4Signs()),
          SliverToBoxAdapter(child: _buildSection5WhenToWorry()),
          SliverToBoxAdapter(child: _buildSection6CommonConcerns()),
          SliverToBoxAdapter(child: _buildSection7ParentTips()),
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────

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
      title: Text(_guidance.category.label, style: AppTextStyles.headlineMedium),
      centerTitle: true,
    );
  }

  // ── Hero card ─────────────────────────────────────────────────────────────

  Widget _buildHeroCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppConstants.paddingL, AppConstants.paddingM, AppConstants.paddingL, 0),
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: _accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: _accent.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Center(child: Text(_guidance.category.emoji, style: const TextStyle(fontSize: 32))),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${_guidance.category.label} Skills', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 3),
                Text(_guidance.category.description, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Flexible(child: Text(widget.babyName, style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
                    Container(width: 4, height: 4, margin: const EdgeInsets.symmetric(horizontal: 5), decoration: const BoxDecoration(color: AppColors.textHint, shape: BoxShape.circle)),
                    Flexible(child: Text(widget.babyAge, style: AppTextStyles.labelSmall, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header helper ─────────────────────────────────────────────────

  Widget _sectionHeader(String number, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppConstants.paddingL, AppConstants.paddingXL, AppConstants.paddingL, AppConstants.paddingM),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: _accent, shape: BoxShape.circle),
            child: Center(child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800))),
          ),
          const SizedBox(width: AppConstants.paddingS),
          Icon(icon, size: 18, color: _accent),
          const SizedBox(width: 6),
          Text(title, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  // ── Section 1 — About ─────────────────────────────────────────────────────

  Widget _buildSection1About() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('1', 'About', Icons.menu_book_outlined),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(_guidance.aboutText, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, height: 1.6)),
          ),
        ),
      ],
    );
  }

  // ── Section 2 — Common milestones ─────────────────────────────────────────

  Widget _buildSection2Milestones() {
    final milestones = _guidance.milestones;
    final achieved = _guidance.achieved;
    final total = _guidance.totalMilestones;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('2', 'Common Milestones', Icons.checklist_rounded),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
          child: Column(
            children: [
              // Progress bar
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: _accent.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Progress', style: AppTextStyles.titleMedium),
                        Text('$achieved / $total', style: AppTextStyles.labelMedium.copyWith(color: _accent, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingS),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                      child: LinearProgressIndicator(
                        value: _guidance.progressPercent,
                        minHeight: 8,
                        backgroundColor: _accent.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(_accent),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              // Milestone checklist
              ...milestones.map((m) => _MilestoneCheckRow(
                milestone: m,
                accentColor: _accent,
                bgColor: _bg,
                onStatusChanged: (s) => _updateStatus(m.id, s),
              )),
            ],
          ),
        ),
      ],
    );
  }

  // ── Section 3 — Activities ────────────────────────────────────────────────

  Widget _buildSection3Activities() {
    final activities = _guidance.activities;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('3', 'Activities to Try', Icons.directions_run_rounded),
        if (activities.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
            child: _emptyCard('No activities listed for this age band yet.'),
          )
        else
          ...activities.map((a) => Padding(
            padding: const EdgeInsets.fromLTRB(AppConstants.paddingL, 0, AppConstants.paddingL, AppConstants.paddingS),
            child: _ActivityTile(activity: a, accentColor: _accent, bgColor: _bg),
          )),
      ],
    );
  }

  // ── Section 4 — Signs to look for ────────────────────────────────────────

  Widget _buildSection4Signs() {
    final positive = _guidance.signsToLookFor.where((s) => s.isPositive).toList();
    final watch    = _guidance.signsToLookFor.where((s) => !s.isPositive).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('4', 'Signs to Look For', Icons.flag_outlined),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
          child: Column(
            children: [
              if (positive.isNotEmpty) ...[
                _SignsCard(title: 'Positive signs', subtitle: 'Your baby is on track!', emoji: '😊', color: AppColors.accentGreen, colorLight: AppColors.accentGreenLight, signs: positive, isPositive: true),
                const SizedBox(height: AppConstants.paddingM),
              ],
              if (watch.isNotEmpty)
                _SignsCard(title: 'Signs to watch', subtitle: 'May need more time and practice.', emoji: '⚠️', color: AppColors.accentOrange, colorLight: AppColors.accentOrangeLight, signs: watch, isPositive: false),
              if (positive.isEmpty && watch.isEmpty)
                _emptyCard('Signs information not yet available for this age band.'),
            ],
          ),
        ),
      ],
    );
  }

  // ── Section 5 — When to worry ─────────────────────────────────────────────

  Widget _buildSection5WhenToWorry() {
    final warnings = _guidance.whenToWorry;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('5', 'When to Worry', Icons.shield_outlined),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
          child: Column(
            children: [
              if (warnings.isEmpty)
                _emptyCard('No specific warning signs listed for this age band.')
              else ...[
                Text('Talk to your doctor if you notice any of the following.', style: AppTextStyles.bodySmall),
                const SizedBox(height: AppConstants.paddingM),
                ...warnings.map((w) => _WarningTile(warning: w)),
                const SizedBox(height: AppConstants.paddingM),
                _earlySupport(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _earlySupport() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.accentPinkLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.accentPink.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: const BoxDecoration(color: AppColors.accentPink, shape: BoxShape.circle), child: const Center(child: Text('🛡️', style: TextStyle(fontSize: 20)))),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Early support makes a big difference!', style: AppTextStyles.titleMedium.copyWith(color: AppColors.accentPink)),
                Text('If you have concerns, your doctor can guide you or refer you to a specialist.', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section 6 — Common concerns ───────────────────────────────────────────

  Widget _buildSection6CommonConcerns() {
    final concerns = _guidance.commonConcerns;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('6', 'Common Concerns', Icons.help_outline_rounded),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
          child: concerns.isEmpty
              ? _emptyCard('No common concerns listed for this age band.')
              : Column(children: concerns.map((c) => _ConcernTile(concern: c, accentColor: _accent)).toList()),
        ),
      ],
    );
  }

  // ── Section 7 — Parent tips ───────────────────────────────────────────────

  Widget _buildSection7ParentTips() {
    final tips = _guidance.parentTips;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('7', 'Parent Tips', Icons.lightbulb_outline_rounded),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
          child: tips.isEmpty
              ? _emptyCard('No tips listed for this age band.')
              : Container(
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    border: Border.all(color: _accent.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: tips.asMap().entries.map((e) => Padding(
                      padding: EdgeInsets.only(bottom: e.key < tips.length - 1 ? AppConstants.paddingM : 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(color: _accent, shape: BoxShape.circle),
                            child: Center(child: Text('${e.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                          ),
                          const SizedBox(width: AppConstants.paddingM),
                          Expanded(child: Text(e.value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary))),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusM), border: Border.all(color: AppColors.divider)),
      child: Text(message, style: AppTextStyles.bodySmall),
    );
  }
}

// ── Milestone check row (section 2 checklist) ─────────────────────────────────

class _MilestoneCheckRow extends StatelessWidget {
  final MilestoneItem milestone;
  final Color accentColor;
  final Color bgColor;
  final void Function(MilestoneStatus) onStatusChanged;

  const _MilestoneCheckRow({
    required this.milestone,
    required this.accentColor,
    required this.bgColor,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final status = milestone.status;
    final isAchieved   = status == MilestoneStatus.achieved;
    final isInProgress = status == MilestoneStatus.inProgress;

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
          // Status toggle button
          GestureDetector(
            onTap: () => _cycleStatus(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: isAchieved
                    ? AppColors.accentGreen
                    : isInProgress
                        ? accentColor
                        : Colors.transparent,
                shape: BoxShape.circle,
                border: (!isAchieved && !isInProgress)
                    ? Border.all(color: AppColors.textHint, width: 2)
                    : null,
              ),
              child: isAchieved
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                  : isInProgress
                      ? const Icon(Icons.timelapse_rounded, color: Colors.white, size: 14)
                      : null,
            ),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  milestone.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isAchieved ? AppColors.textSecondary : AppColors.textPrimary,
                    decoration: isAchieved ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.textSecondary,
                  ),
                ),
                if (milestone.description.isNotEmpty)
                  Text(milestone.description, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                if (milestone.achievedDate != null)
                  Text('Done on ${milestone.achievedDate}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentGreen)),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.paddingS),
          // Quick status chip
          if (!isAchieved)
            GestureDetector(
              onTap: () => onStatusChanged(MilestoneStatus.achieved),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Text('Done', style: AppTextStyles.labelSmall.copyWith(color: accentColor, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }

  void _cycleStatus() {
    switch (milestone.status) {
      case MilestoneStatus.notStarted:  onStatusChanged(MilestoneStatus.inProgress);
      case MilestoneStatus.inProgress:  onStatusChanged(MilestoneStatus.achieved);
      case MilestoneStatus.achieved:    onStatusChanged(MilestoneStatus.notStarted);
    }
  }
}

// ── Activity tile (section 3) ─────────────────────────────────────────────────

class _ActivityTile extends StatefulWidget {
  final MilestoneActivity activity;
  final Color accentColor;
  final Color bgColor;
  const _ActivityTile({required this.activity, required this.accentColor, required this.bgColor});

  @override
  State<_ActivityTile> createState() => _ActivityTileState();
}

class _ActivityTileState extends State<_ActivityTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingS),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: widget.bgColor, shape: BoxShape.circle),
                    child: Center(child: Text(widget.activity.emoji, style: const TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: AppConstants.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.activity.title, style: AppTextStyles.titleMedium),
                        Text(widget.activity.description, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: AppColors.textHint, size: 20),
                ],
              ),
            ),
          ),
          if (_expanded && widget.activity.steps.isNotEmpty) ...[
            Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Column(
                children: widget.activity.steps.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(color: widget.accentColor, shape: BoxShape.circle),
                        child: Center(child: Text('${e.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
                      ),
                      const SizedBox(width: AppConstants.paddingS),
                      Expanded(child: Text(e.value, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary))),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Signs card (section 4) ────────────────────────────────────────────────────

class _SignsCard extends StatelessWidget {
  final String title, subtitle, emoji;
  final Color color, colorLight;
  final List<MilestoneSign> signs;
  final bool isPositive;

  const _SignsCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.colorLight,
    required this.signs,
    required this.isPositive,
  });

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
          Divider(height: 1, color: color.withValues(alpha: 0.15)),
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
              if (s != signs.last) Divider(height: 1, color: color.withValues(alpha: 0.08)),
            ],
          )),
        ],
      ),
    );
  }
}

// ── Warning tile (section 5) ──────────────────────────────────────────────────

class _WarningTile extends StatelessWidget {
  final MilestoneWarning warning;
  const _WarningTile({required this.warning});

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
            decoration: BoxDecoration(color: AppColors.accentPinkLight, borderRadius: BorderRadius.circular(AppConstants.radiusS)),
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
        ],
      ),
    );
  }
}

// ── Concern tile (section 6) ──────────────────────────────────────────────────

class _ConcernTile extends StatefulWidget {
  final CommonConcern concern;
  final Color accentColor;
  const _ConcernTile({required this.concern, required this.accentColor});

  @override
  State<_ConcernTile> createState() => _ConcernTileState();
}

class _ConcernTileState extends State<_ConcernTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingS),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: widget.accentColor.withValues(alpha: 0.12), shape: BoxShape.circle),
                    child: Center(child: Text('Q', style: AppTextStyles.labelSmall.copyWith(color: widget.accentColor, fontWeight: FontWeight.w800))),
                  ),
                  const SizedBox(width: AppConstants.paddingM),
                  Expanded(child: Text(widget.concern.question, style: AppTextStyles.titleMedium)),
                  Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: AppColors.textHint, size: 20),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: AppColors.accentGreen.withValues(alpha: 0.12), shape: BoxShape.circle),
                    child: Center(child: Text('A', style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentGreen, fontWeight: FontWeight.w800))),
                  ),
                  const SizedBox(width: AppConstants.paddingM),
                  Expanded(child: Text(widget.concern.answer, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, height: 1.5))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
