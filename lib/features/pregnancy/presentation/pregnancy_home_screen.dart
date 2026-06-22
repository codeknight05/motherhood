import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/baby_provider.dart';
import '../../../core/providers/pregnancy_provider.dart';
import '../../../core/services/pregnancy_guidance_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Pregnancy Home Screen — redesigned with warm, immersive UI
// ═══════════════════════════════════════════════════════════════════════════

class PregnancyHomeScreen extends ConsumerStatefulWidget {
  const PregnancyHomeScreen({super.key});

  @override
  ConsumerState<PregnancyHomeScreen> createState() =>
      _PregnancyHomeScreenState();
}

class _PregnancyHomeScreenState extends ConsumerState<PregnancyHomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _heroCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _heroAnim;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _heroAnim = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Try loading immediately after first frame — baby may already be loaded
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfNeeded());
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _loadIfNeeded() {
    // Only load if guidance hasn't been fetched yet
    final pgState = ref.read(pregnancyProvider);
    if (pgState.guidance != null || pgState.isLoading) return;
    _loadCurrentWeek();
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

  void _changeWeek(int delta) {
    final current = ref.read(pregnancyProvider).currentWeek;
    final next = (current + delta).clamp(1, 40);
    if (next != current) {
      _heroCtrl.forward(from: 0);
      ref.read(pregnancyProvider.notifier).loadWeek(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pgState = ref.watch(pregnancyProvider);
    final baby = ref.watch(babyProvider).baby;
    final week = pgState.currentWeek;

    // If baby data arrives after mount and guidance still not loaded, load now
    ref.listen<BabyState>(babyProvider, (prev, next) {
      if (next.baby != null && !next.isLoading) {
        final pg = ref.read(pregnancyProvider);
        if (pg.guidance == null && !pg.isLoading) {
          _loadCurrentWeek();
        }
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero header ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _HeroHeader(
              week: week,
              babyName: baby?.name ?? 'Your Baby',
              dueDate: baby?.dueDate,
              guidance: pgState.guidance,
              heroAnim: _heroAnim,
              pulseAnim: _pulseAnim,
              onPrev: week > 1 ? () => _changeWeek(-1) : null,
              onNext: week < 40 ? () => _changeWeek(1) : null,
            ),
          ),
          // ── Quick stats row ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _QuickStats(week: week, guidance: pgState.guidance),
          ),
          // ── Content ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: pgState.isLoading
                ? const _LoadingShimmer()
                : pgState.guidance != null
                    ? _GuidanceSections(guidance: pgState.guidance!)
                    : _EmptyState(week: week),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ─── Hero Header ──────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final int week;
  final String babyName;
  final DateTime? dueDate;
  final PregnancyWeekGuidance? guidance;
  final Animation<double> heroAnim;
  final Animation<double> pulseAnim;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _HeroHeader({
    required this.week,
    required this.babyName,
    required this.dueDate,
    required this.guidance,
    required this.heroAnim,
    required this.pulseAnim,
    this.onPrev,
    this.onNext,
  });

  String get _trimester {
    if (week <= 13) return '1st Trimester';
    if (week <= 26) return '2nd Trimester';
    return '3rd Trimester';
  }

  int get _daysLeft {
    if (dueDate == null) return 0;
    return dueDate!.difference(DateTime.now()).inDays.clamp(0, 280);
  }

  String get _emoji {
    const emojis = {
      1: '🌱', 2: '🌱', 3: '🫐', 4: '🌱', 5: '🌿', 6: '🫛',
      7: '🫐', 8: '🫘', 9: '🍇', 10: '🍓', 11: '🍋', 12: '🍋',
      13: '🍑', 14: '🍋', 15: '🍎', 16: '🥑', 17: '🍐', 18: '🫑',
      19: '🥭', 20: '🍌', 21: '🥕', 22: '🌽', 23: '🍆', 24: '🌽',
      25: '🥦', 26: '🥬', 27: '🥦', 28: '🍆', 29: '🎃', 30: '🥥',
      31: '🍍', 32: '🥦', 33: '🍍', 34: '🎃', 35: '🥥', 36: '🥬',
      37: '🍉', 38: '🎃', 39: '🍉', 40: '🍉',
    };
    return guidance?.babySizeEmoji ?? emojis[week] ?? '🌱';
  }

  String get _sizeObject {
    return guidance?.babySizeObject ?? 'growing';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B2D8B), Color(0xFFFF8FAB), Color(0xFFFFB3C6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${babyName.split(' ').first} 💜',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        _trimester,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (dueDate != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${_daysLeft}d',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'to go',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Womb illustration + baby emoji
            FadeTransition(
              opacity: heroAnim,
              child: _WombIllustration(
                emoji: _emoji,
                pulseAnim: pulseAnim,
                week: week,
              ),
            ),

            const SizedBox(height: 16),

            // Size label
            FadeTransition(
              opacity: heroAnim,
              child: Text(
                'Size of a $_sizeObject',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Week navigator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _WeekNavigatorBar(
                week: week,
                onPrev: onPrev,
                onNext: onNext,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Womb Illustration ────────────────────────────────────────────────────────

class _WombIllustration extends StatelessWidget {
  final String emoji;
  final Animation<double> pulseAnim;
  final int week;

  const _WombIllustration({
    required this.emoji,
    required this.pulseAnim,
    required this.week,
  });

  @override
  Widget build(BuildContext context) {
    // Baby size grows from 20% to 80% of the circle as weeks progress
    final babyScale = 0.20 + (week / 40) * 0.55;

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring — pulses softly
          ScaleTransition(
            scale: pulseAnim,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Womb circle — warm pinkish-red, pulses organically
          ScaleTransition(
            scale: pulseAnim,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFF6B8A), Color(0xFFE8405A)],
                  center: Alignment(-0.3, -0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8405A).withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
          // Inner amniotic fluid effect
          ScaleTransition(
            scale: pulseAnim,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFF8FAB).withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                  center: Alignment(0.2, 0.2),
                ),
              ),
            ),
          ),
          // Umbilical cord hint (custom painter)
          ScaleTransition(
            scale: pulseAnim,
            child: CustomPaint(
              size: const Size(160, 160),
              painter: _CordPainter(),
            ),
          ),
          // Baby emoji — pulsing
          ScaleTransition(
            scale: pulseAnim,
            child: Text(
              emoji,
              style: TextStyle(fontSize: 180 * babyScale * 0.45),
            ),
          ),
          // Sparkle dots
          ..._buildSparkles(),
        ],
      ),
    );
  }

  List<Widget> _buildSparkles() {
    final positions = [
      const Offset(20, 30),
      const Offset(185, 50),
      const Offset(30, 170),
      const Offset(175, 165),
      const Offset(110, 15),
    ];
    return positions.map((pos) {
      return Positioned(
        left: pos.dx,
        top: pos.dy,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
        ),
      );
    }).toList();
  }
}

// ─── Umbilical cord painter ───────────────────────────────────────────────────

class _CordPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.55);
    path.cubicTo(
      size.width * 0.15, size.height * 0.45,
      size.width * 0.10, size.height * 0.35,
      size.width * 0.05, size.height * 0.30,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CordPainter old) => false;
}

// ─── Week Navigator Bar ───────────────────────────────────────────────────────

class _WeekNavigatorBar extends StatelessWidget {
  final int week;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _WeekNavigatorBar({
    required this.week,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ArrowBtn(
            icon: Icons.chevron_left_rounded,
            enabled: onPrev != null,
            onTap: onPrev,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Week $week',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: week / 40,
                    minHeight: 5,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${((week / 40) * 100).toInt()}% of journey',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          _ArrowBtn(
            icon: Icons.chevron_right_rounded,
            enabled: onNext != null,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _ArrowBtn({
    required this.icon,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: enabled
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: enabled
              ? Colors.white
              : Colors.white.withValues(alpha: 0.3),
          size: 24,
        ),
      ),
    );
  }
}

// ─── Quick Stats Row ──────────────────────────────────────────────────────────

class _QuickStats extends StatelessWidget {
  final int week;
  final PregnancyWeekGuidance? guidance;

  const _QuickStats({required this.week, this.guidance});

  @override
  Widget build(BuildContext context) {
    final length = guidance?.babyLengthCm;
    final weight = guidance?.babyWeightG;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        children: [
          _StatChip(
            emoji: '📅',
            label: 'Week',
            value: '$week / 40',
            color: const Color(0xFFFFE4EC),
            accent: const Color(0xFFE8405A),
          ),
          const SizedBox(width: 10),
          _StatChip(
            emoji: '📏',
            label: 'Length',
            value: length != null
                ? (length < 1
                    ? '${(length * 10).toStringAsFixed(1)} mm'
                    : '${length.toStringAsFixed(1)} cm')
                : '—',
            color: const Color(0xFFE8F5E9),
            accent: const Color(0xFF2E7D32),
          ),
          const SizedBox(width: 10),
          _StatChip(
            emoji: '⚖️',
            label: 'Weight',
            value: weight != null
                ? (weight < 1000
                    ? '${weight.toStringAsFixed(0)} g'
                    : '${(weight / 1000).toStringAsFixed(2)} kg')
                : '—',
            color: const Color(0xFFE3F2FD),
            accent: const Color(0xFF1565C0),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;
  final Color accent;

  const _StatChip({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(
                color: accent,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: accent.withValues(alpha: 0.7),
              ),
            ),
          ],
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week\'s Guide',
            style: AppTextStyles.headlineSmall.copyWith(
              color: const Color(0xFF3D0020),
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            emoji: '👶',
            title: 'Baby This Week',
            content: guidance.babyThisWeek,
            gradientColors: [const Color(0xFFFFE4EC), const Color(0xFFFFF0F3)],
            accentColor: const Color(0xFFE8405A),
            initiallyExpanded: true,
          ),
          _SectionCard(
            emoji: '🤰',
            title: 'Your Body',
            content: guidance.yourBodyThisWeek,
            gradientColors: [const Color(0xFFF3E5F5), const Color(0xFFFAF0FF)],
            accentColor: AppColors.primary,
          ),
          _SectionCard(
            emoji: '💫',
            title: 'Symptoms & Changes',
            content: guidance.symptomsAndChanges,
            gradientColors: [const Color(0xFFFFF3E0), const Color(0xFFFFFBF0)],
            accentColor: const Color(0xFFE65100),
          ),
          _SectionCard(
            emoji: '🥗',
            title: 'Nutrition Guide',
            content: guidance.nutritionGuide,
            gradientColors: [const Color(0xFFE8F5E9), const Color(0xFFF1FBF2)],
            accentColor: const Color(0xFF2E7D32),
          ),
          _SectionCard(
            emoji: '🧘',
            title: 'Self-care & Activities',
            content: guidance.selfcareActivities,
            gradientColors: [const Color(0xFFE3F2FD), const Color(0xFFF0F8FF)],
            accentColor: const Color(0xFF1565C0),
          ),
          _SectionCard(
            emoji: '💜',
            title: 'Emotional Wellness',
            content: guidance.emotionalWellness,
            gradientColors: [const Color(0xFFFCE4EC), const Color(0xFFFFF0F5)],
            accentColor: const Color(0xFFAD1457),
          ),
          _SectionCard(
            emoji: '✅',
            title: "What's Usually Normal",
            content: guidance.whatsUsuallyNormal,
            gradientColors: [const Color(0xFFF1F8E9), const Color(0xFFF8FFF0)],
            accentColor: const Color(0xFF558B2F),
          ),
          _ChecklistCard(content: guidance.checklistThisWeek),
          _SectionCard(
            emoji: '🏥',
            title: 'When To Contact Doctor',
            content: guidance.whenToContactDoctor,
            gradientColors: [const Color(0xFFFFEBEE), const Color(0xFFFFF5F5)],
            accentColor: const Color(0xFFC62828),
          ),
          _SectionCard(
            emoji: '🤝',
            title: 'Partner Support',
            content: guidance.partnerSupport,
            gradientColors: [const Color(0xFFFCE4EC), const Color(0xFFFFF0F5)],
            accentColor: const Color(0xFFAD1457),
          ),
          _EncouragementCard(content: guidance.weeklyEncouragement),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Section Card (expandable) ────────────────────────────────────────────────

class _SectionCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String content;
  final List<Color> gradientColors;
  final Color accentColor;
  final bool initiallyExpanded;

  const _SectionCard({
    required this.emoji,
    required this.title,
    required this.content,
    required this.gradientColors,
    required this.accentColor,
    this.initiallyExpanded = false,
  });

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late final AnimationController _ctrl;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: _expanded ? 1.0 : 0.0,
    );
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        widget.emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: widget.accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: widget.accentColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _ContentRenderer(
                content: widget.content,
                accentColor: widget.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Checklist Card ───────────────────────────────────────────────────────────

class _ChecklistCard extends StatefulWidget {
  final String content;
  const _ChecklistCard({required this.content});

  @override
  State<_ChecklistCard> createState() => _ChecklistCardState();
}

class _ChecklistCardState extends State<_ChecklistCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  final Set<int> _checked = {};

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<String> get _items {
    return widget.content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .map((l) => l.replaceFirst(RegExp(r'^[-•*✅]\s*'), '').trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final done = _checked.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFF1FBF2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() => _expanded = !_expanded);
              _expanded ? _ctrl.forward() : _ctrl.reverse();
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text('📋', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Checklist This Week',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: const Color(0xFF2E7D32),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (items.isNotEmpty)
                          Text(
                            '$done / ${items.length} done',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFF2E7D32).withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF2E7D32),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _anim,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: items.asMap().entries.map((e) {
                  final idx = e.key;
                  final text = e.value;
                  final isChecked = _checked.contains(idx);
                  return GestureDetector(
                    onTap: () => setState(() {
                      isChecked ? _checked.remove(idx) : _checked.add(idx);
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isChecked
                            ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isChecked
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF2E7D32).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isChecked
                                  ? const Color(0xFF2E7D32)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF2E7D32),
                                width: 1.5,
                              ),
                            ),
                            child: isChecked
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              text,
                              style: AppTextStyles.bodyMedium.copyWith(
                                decoration: isChecked
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isChecked
                                    ? const Color(0xFF2E7D32)
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Encouragement Card ───────────────────────────────────────────────────────

class _EncouragementCard extends StatelessWidget {
  final String content;
  const _EncouragementCard({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8FAB), Color(0xFFE8405A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8405A).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('💜', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Weekly Encouragement',
                style: AppTextStyles.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Content Renderer ─────────────────────────────────────────────────────────

class _ContentRenderer extends StatelessWidget {
  final String content;
  final Color accentColor;

  const _ContentRenderer({
    required this.content,
    required this.accentColor,
  });

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
        final isBullet = line.startsWith('-') ||
            line.startsWith('•') ||
            line.startsWith('*');
        final text =
            isBullet ? line.replaceFirst(RegExp(r'^[-•*]\s*'), '') : line;

        if (isBullet) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(top: 6, right: 10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.6),
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

        final isHeading = line.endsWith(':') ||
            (line == line.toUpperCase() && line.length > 3);
        if (isHeading) {
          return Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 5),
            child: Text(
              text,
              style: AppTextStyles.titleMedium.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Loading Shimmer ──────────────────────────────────────────────────────────

class _LoadingShimmer extends StatefulWidget {
  const _LoadingShimmer();

  @override
  State<_LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<_LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final opacity = 0.3 + 0.4 * math.sin(_anim.value * math.pi);
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: List.generate(
              4,
              (i) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB3C6).withValues(alpha: opacity),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final int week;
  const _EmptyState({required this.week});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Text('🌸', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(
            'Week $week guide coming soon',
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
