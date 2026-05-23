import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/baby_provider.dart';
import '../../../core/providers/pregnancy_provider.dart';
import '../../../core/services/pregnancy_guidance_service.dart';
import 'baby_size_card.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Pregnancy Home Screen
// Shows BabySizeCard + 11-section weekly guidance for pregnant users.
// ═══════════════════════════════════════════════════════════════════════════

class PregnancyHomeScreen extends ConsumerStatefulWidget {
  const PregnancyHomeScreen({super.key});

  @override
  ConsumerState<PregnancyHomeScreen> createState() =>
      _PregnancyHomeScreenState();
}

class _PregnancyHomeScreenState extends ConsumerState<PregnancyHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCurrentWeek());
  }

  void _loadCurrentWeek() {
    final baby = ref.read(babyProvider).baby;
    if (baby == null) return;

    final notifier = ref.read(pregnancyProvider.notifier);
    if (baby.dueDate != null) {
      notifier.loadFromDueDate(baby.dueDate!);
    } else {
      notifier.loadWeek(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final baby = ref.watch(babyProvider).baby;
    final pgState = ref.watch(pregnancyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(baby, pgState.currentWeek),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: AppConstants.paddingL),
                // Week navigator
                _WeekNavigator(
                  currentWeek: pgState.currentWeek,
                  onWeekChanged: (w) =>
                      ref.read(pregnancyProvider.notifier).loadWeek(w),
                ),
                const SizedBox(height: AppConstants.paddingL),
                // Baby size card
                BabySizeCard(
                  pregnancyWeek: pgState.currentWeek,
                  emojiOverride: pgState.guidance?.babySizeEmoji,
                  objectOverride: pgState.guidance?.babySizeObject,
                  lengthCmOverride: pgState.guidance?.babyLengthCm,
                  weightGOverride: pgState.guidance?.babyWeightG,
                ),
                const SizedBox(height: AppConstants.paddingXL),
                // Guidance sections
                if (pgState.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.5,
                    ),
                  )
                else if (pgState.guidance != null)
                  _GuidanceSections(guidance: pgState.guidance!)
                else
                  _EmptyState(week: pgState.currentWeek),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(baby, int week) {
    final name = baby?.name ?? 'Your Baby';
    final trimester = week <= 13
        ? '1st Trimester'
        : week <= 26
            ? '2nd Trimester'
            : '3rd Trimester';

    return SliverAppBar(
      pinned: true,
      floating: false,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.divider,
      titleSpacing: AppConstants.paddingL,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🤰', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, style: AppTextStyles.headlineSmall),
                Text(
                  'Week $week · $trimester',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Week Navigator ───────────────────────────────────────────────────────────

class _WeekNavigator extends StatelessWidget {
  final int currentWeek;
  final ValueChanged<int> onWeekChanged;

  const _WeekNavigator({
    required this.currentWeek,
    required this.onWeekChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
          vertical: AppConstants.paddingS,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(color: AppColors.primaryMid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous week
            _NavButton(
              icon: Icons.chevron_left_rounded,
              enabled: currentWeek > 1,
              onTap: () => onWeekChanged(currentWeek - 1),
            ),
            // Week display
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Week $currentWeek of 40',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                // Progress bar
                SizedBox(
                  width: 140,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusFull,
                    ),
                    child: LinearProgressIndicator(
                      value: currentWeek / 40,
                      minHeight: 6,
                      backgroundColor: AppColors.primaryMid.withValues(
                        alpha: 0.3,
                      ),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${((currentWeek / 40) * 100).toInt()}% complete',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            // Next week
            _NavButton(
              icon: Icons.chevron_right_rounded,
              enabled: currentWeek < 40,
              onTap: () => onWeekChanged(currentWeek + 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.divider,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : AppColors.textHint,
          size: 22,
        ),
      ),
    );
  }
}

// ─── Guidance Sections ────────────────────────────────────────────────────────

class _GuidanceSections extends StatelessWidget {
  final PregnancyWeekGuidance guidance;

  const _GuidanceSections({required this.guidance});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
      child: Column(
        children: [
          _GuidanceSection(
            emoji: '👶',
            title: 'Baby This Week',
            content: guidance.babyThisWeek,
            color: const Color(0xFFE8F5E9),
            accentColor: const Color(0xFF2E7D32),
          ),
          _GuidanceSection(
            emoji: '🤰',
            title: 'Your Body This Week',
            content: guidance.yourBodyThisWeek,
            color: const Color(0xFFF3E5F5),
            accentColor: AppColors.primary,
          ),
          _GuidanceSection(
            emoji: '💫',
            title: 'Symptoms & Body Changes',
            content: guidance.symptomsAndChanges,
            color: const Color(0xFFFFF3E0),
            accentColor: const Color(0xFFE65100),
          ),
          _GuidanceSection(
            emoji: '🥗',
            title: 'Nutrition Guide',
            content: guidance.nutritionGuide,
            color: const Color(0xFFE8F5E9),
            accentColor: const Color(0xFF388E3C),
          ),
          _GuidanceSection(
            emoji: '🧘',
            title: 'Self-care & Activities',
            content: guidance.selfcareActivities,
            color: const Color(0xFFE3F2FD),
            accentColor: const Color(0xFF1565C0),
          ),
          _GuidanceSection(
            emoji: '💜',
            title: 'Emotional Wellness',
            content: guidance.emotionalWellness,
            color: const Color(0xFFF8BBD9).withValues(alpha: 0.4),
            accentColor: const Color(0xFFAD1457),
          ),
          _GuidanceSection(
            emoji: '✅',
            title: "What's Usually Normal",
            content: guidance.whatsUsuallyNormal,
            color: const Color(0xFFF1F8E9),
            accentColor: const Color(0xFF558B2F),
          ),
          _ChecklistSection(content: guidance.checklistThisWeek),
          _GuidanceSection(
            emoji: '🏥',
            title: 'When To Contact Doctor',
            content: guidance.whenToContactDoctor,
            color: const Color(0xFFFFEBEE),
            accentColor: const Color(0xFFC62828),
          ),
          _GuidanceSection(
            emoji: '🤝',
            title: 'Partner Support',
            content: guidance.partnerSupport,
            color: const Color(0xFFFCE4EC),
            accentColor: const Color(0xFFAD1457),
          ),
          _EncouragementSection(content: guidance.weeklyEncouragement),
        ],
      ),
    );
  }
}

// ─── Individual section card ──────────────────────────────────────────────────

class _GuidanceSection extends StatefulWidget {
  final String emoji;
  final String title;
  final String content;
  final Color color;
  final Color accentColor;

  const _GuidanceSection({
    required this.emoji,
    required this.title,
    required this.content,
    required this.color,
    required this.accentColor,
  });

  @override
  State<_GuidanceSection> createState() => _GuidanceSectionState();
}

class _GuidanceSectionState extends State<_GuidanceSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          onExpansionChanged: (v) => setState(() => _expanded = v),
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingL,
            vertical: AppConstants.paddingS,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppConstants.paddingL,
            0,
            AppConstants.paddingL,
            AppConstants.paddingL,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(widget.emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          title: Text(
            widget.title,
            style: AppTextStyles.titleMedium.copyWith(
              color: widget.accentColor,
            ),
          ),
          trailing: AnimatedRotation(
            turns: _expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: widget.accentColor,
            ),
          ),
          children: [
            _ContentText(content: widget.content, color: widget.accentColor),
          ],
        ),
      ),
    );
  }
}

// ─── Checklist section (special rendering with checkmarks) ───────────────────

class _ChecklistSection extends StatefulWidget {
  final String content;
  const _ChecklistSection({required this.content});

  @override
  State<_ChecklistSection> createState() => _ChecklistSectionState();
}

class _ChecklistSectionState extends State<_ChecklistSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFE8F5E9);
    const accent = Color(0xFF2E7D32);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          onExpansionChanged: (v) => setState(() => _expanded = v),
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingL,
            vertical: AppConstants.paddingS,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppConstants.paddingL,
            0,
            AppConstants.paddingL,
            AppConstants.paddingL,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('📋', style: TextStyle(fontSize: 20)),
            ),
          ),
          title: Text(
            'Checklist This Week',
            style: AppTextStyles.titleMedium.copyWith(color: accent),
          ),
          trailing: AnimatedRotation(
            turns: _expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: accent,
            ),
          ),
          children: [
            _ChecklistItems(content: widget.content),
          ],
        ),
      ),
    );
  }
}

class _ChecklistItems extends StatelessWidget {
  final String content;
  const _ChecklistItems({required this.content});

  @override
  Widget build(BuildContext context) {
    // Parse lines that start with ✅
    final lines = content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final isCheck = line.startsWith('✅');
        final text = isCheck ? line.replaceFirst('✅', '').trim() : line;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 1, right: 10),
                decoration: BoxDecoration(
                  color: isCheck
                      ? const Color(0xFF2E7D32)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF2E7D32),
                    width: 1.5,
                  ),
                ),
                child: isCheck
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      )
                    : null,
              ),
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Encouragement section (special gradient card) ───────────────────────────

class _EncouragementSection extends StatelessWidget {
  final String content;
  const _EncouragementSection({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💜', style: TextStyle(fontSize: 24)),
              const SizedBox(width: AppConstants.paddingS),
              Text(
                'Weekly Encouragement',
                style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Content text renderer ────────────────────────────────────────────────────

class _ContentText extends StatelessWidget {
  final String content;
  final Color color;
  const _ContentText({required this.content, required this.color});

  @override
  Widget build(BuildContext context) {
    final lines = content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        // Detect bullet-style lines
        final isBullet = line.startsWith('-') ||
            line.startsWith('•') ||
            line.startsWith('*');
        final text = isBullet ? line.replaceFirst(RegExp(r'^[-•*]\s*'), '') : line;

        if (isBullet) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 7, right: 10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    text,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }

        // Sub-heading (all caps or ends with colon)
        final isHeading = line == line.toUpperCase() && line.length > 3 ||
            line.endsWith(':');
        if (isHeading) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              text,
              style: AppTextStyles.titleMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final int week;
  const _EmptyState({required this.week});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Text('🌸', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'Week $week guidance coming soon',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for detailed guidance.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
