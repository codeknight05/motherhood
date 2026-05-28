import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

// ── Baby size data (fallback when Supabase row has no size data) ──────────────

class _BabySizeInfo {
  final String emoji;
  final String object;
  final double? lengthCm;
  final double? weightG;
  const _BabySizeInfo(this.emoji, this.object, {this.lengthCm, this.weightG});
}

const _sizeByWeek = <int, _BabySizeInfo>{
  1:  _BabySizeInfo('🌱', 'Poppy seed',       lengthCm: 0.1),
  2:  _BabySizeInfo('🌱', 'Sesame seed',      lengthCm: 0.2),
  3:  _BabySizeInfo('🫐', 'Blueberry',        lengthCm: 0.3),
  4:  _BabySizeInfo('🫐', 'Blueberry',        lengthCm: 0.4),
  5:  _BabySizeInfo('🌿', 'Orange seed',      lengthCm: 0.5),
  6:  _BabySizeInfo('🫛', 'Sweet pea',        lengthCm: 0.6),
  7:  _BabySizeInfo('🫐', 'Blueberry',        lengthCm: 1.0),
  8:  _BabySizeInfo('🫘', 'Kidney bean',      lengthCm: 1.6,  weightG: 1),
  9:  _BabySizeInfo('🍇', 'Grape',            lengthCm: 2.3,  weightG: 2),
  10: _BabySizeInfo('🍓', 'Strawberry',       lengthCm: 3.1,  weightG: 4),
  11: _BabySizeInfo('🍋', 'Lime',             lengthCm: 4.1,  weightG: 7),
  12: _BabySizeInfo('🍋', 'Lemon',            lengthCm: 5.4,  weightG: 14),
  13: _BabySizeInfo('🍑', 'Peach',            lengthCm: 7.4,  weightG: 23),
  14: _BabySizeInfo('🍋', 'Lemon',            lengthCm: 8.7,  weightG: 43),
  15: _BabySizeInfo('🍎', 'Apple',            lengthCm: 10.1, weightG: 70),
  16: _BabySizeInfo('🥑', 'Avocado',          lengthCm: 11.6, weightG: 100),
  17: _BabySizeInfo('🍐', 'Pear',             lengthCm: 13.0, weightG: 140),
  18: _BabySizeInfo('🫑', 'Bell pepper',      lengthCm: 14.2, weightG: 190),
  19: _BabySizeInfo('🥭', 'Mango',            lengthCm: 15.3, weightG: 240),
  20: _BabySizeInfo('🍌', 'Banana',           lengthCm: 16.4, weightG: 300),
  21: _BabySizeInfo('🥕', 'Carrot',           lengthCm: 26.7, weightG: 360),
  22: _BabySizeInfo('🌽', 'Corn',             lengthCm: 27.8, weightG: 430),
  23: _BabySizeInfo('🍆', 'Eggplant',         lengthCm: 28.9, weightG: 500),
  24: _BabySizeInfo('🌽', 'Corn on the cob',  lengthCm: 30.0, weightG: 600),
  25: _BabySizeInfo('🥦', 'Cauliflower',      lengthCm: 34.6, weightG: 660),
  26: _BabySizeInfo('🥬', 'Lettuce head',     lengthCm: 35.6, weightG: 760),
  27: _BabySizeInfo('🥦', 'Broccoli',         lengthCm: 36.6, weightG: 875),
  28: _BabySizeInfo('🍆', 'Large eggplant',   lengthCm: 37.6, weightG: 1005),
  29: _BabySizeInfo('🎃', 'Butternut squash', lengthCm: 38.6, weightG: 1153),
  30: _BabySizeInfo('🥥', 'Coconut',          lengthCm: 39.9, weightG: 1319),
  31: _BabySizeInfo('🍍', 'Pineapple',        lengthCm: 41.1, weightG: 1502),
  32: _BabySizeInfo('🥦', 'Large broccoli',   lengthCm: 42.4, weightG: 1702),
  33: _BabySizeInfo('🍍', 'Large pineapple',  lengthCm: 43.7, weightG: 1918),
  34: _BabySizeInfo('🎃', 'Cantaloupe',       lengthCm: 45.0, weightG: 2146),
  35: _BabySizeInfo('🥥', 'Honeydew melon',   lengthCm: 46.2, weightG: 2383),
  36: _BabySizeInfo('🥬', 'Romaine lettuce',  lengthCm: 47.4, weightG: 2622),
  37: _BabySizeInfo('🍉', 'Small watermelon', lengthCm: 48.6, weightG: 2859),
  38: _BabySizeInfo('🎃', 'Pumpkin',          lengthCm: 49.8, weightG: 3083),
  39: _BabySizeInfo('🍉', 'Watermelon',       lengthCm: 50.7, weightG: 3288),
  40: _BabySizeInfo('🍉', 'Large watermelon', lengthCm: 51.2, weightG: 3462),
};

// ── Widget ────────────────────────────────────────────────────────────────────

class BabySizeCard extends StatefulWidget {
  final int pregnancyWeek;
  final String? emojiOverride;
  final String? objectOverride;
  final double? lengthCmOverride;
  final double? weightGOverride;

  const BabySizeCard({
    super.key,
    required this.pregnancyWeek,
    this.emojiOverride,
    this.objectOverride,
    this.lengthCmOverride,
    this.weightGOverride,
  });

  @override
  State<BabySizeCard> createState() => _BabySizeCardState();
}

class _BabySizeCardState extends State<BabySizeCard>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _scaleCtrl;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    // Gentle continuous pulse on the emoji
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Scale-in animation when card first appears
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
  }

  @override
  void didUpdateWidget(BabySizeCard old) {
    super.didUpdateWidget(old);
    // Re-trigger scale animation when week changes
    if (old.pregnancyWeek != widget.pregnancyWeek) {
      _scaleCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final week = widget.pregnancyWeek.clamp(1, 40);
    final info = _sizeByWeek[week] ?? _sizeByWeek[1]!;

    final emoji  = widget.emojiOverride  ?? info.emoji;
    final object = widget.objectOverride ?? info.object;
    final length = widget.lengthCmOverride ?? info.lengthCm;
    final weight = widget.weightGOverride  ?? info.weightG;

    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
        padding: const EdgeInsets.all(AppConstants.paddingL),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF3EEFF), Color(0xFFEDE7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          border: Border.all(color: AppColors.primaryMid.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Animated emoji
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 42)),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.paddingL),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Week $week',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your baby is the size of a',
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    object,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingS),
                  // Size metrics
                  Wrap(
                    spacing: AppConstants.paddingM,
                    children: [
                      if (length != null)
                        _Metric(
                          icon: '📏',
                          label: length < 1
                              ? '${(length * 10).toStringAsFixed(1)} mm'
                              : '${length.toStringAsFixed(1)} cm',
                        ),
                      if (weight != null)
                        _Metric(
                          icon: '⚖️',
                          label: weight < 1000
                              ? '${weight.toStringAsFixed(0)} g'
                              : '${(weight / 1000).toStringAsFixed(2)} kg',
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

class _Metric extends StatelessWidget {
  final String icon;
  final String label;
  const _Metric({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(color: AppColors.primaryMid.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
