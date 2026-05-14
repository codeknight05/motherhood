import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/recipe_model.dart';
import 'recipe_detail_screen.dart';

class WeeklyMealPlanScreen extends StatefulWidget {
  final String ageGroup;
  const WeeklyMealPlanScreen({super.key, this.ageGroup = '6-8 Months'});

  @override
  State<WeeklyMealPlanScreen> createState() => _WeeklyMealPlanScreenState();
}

class _WeeklyMealPlanScreenState extends State<WeeklyMealPlanScreen> {
  int _selectedDay = 0;

  final List<Map<String, dynamic>> _days = [
    {'label': 'Mon', 'dot': AppColors.accentGreen, 'isToday': true},
    {'label': 'Tue', 'dot': AppColors.accentPink, 'isToday': false},
    {'label': 'Wed', 'dot': AppColors.primary, 'isToday': false},
    {'label': 'Thu', 'dot': AppColors.accentOrange, 'isToday': false},
    {'label': 'Fri', 'dot': AppColors.accentBlue, 'isToday': false},
    {'label': 'Sat', 'dot': AppColors.accentGreen, 'isToday': false},
    {'label': 'Sun', 'dot': AppColors.accentPink, 'isToday': false},
  ];

  final List<Map<String, dynamic>> _meals = [
    {'meal': 'Breakfast', 'time': '8:00 AM', 'emoji': '🌅', 'recipe': sampleRecipes[0]},
    {'meal': 'Mid Morning', 'time': '10:30 AM', 'emoji': '🍎', 'recipe': sampleRecipes[4]},
    {'meal': 'Lunch', 'time': '1:00 PM', 'emoji': '☀️', 'recipe': sampleRecipes[1]},
    {'meal': 'Evening Snack', 'time': '4:00 PM', 'emoji': '🌤️', 'recipe': sampleRecipes[2]},
    {'meal': 'Dinner', 'time': '7:00 PM', 'emoji': '🌙', 'recipe': sampleRecipes[5]},
    {'meal': 'Bedtime', 'time': '8:30 PM', 'emoji': '🍼', 'recipe': null},
  ];

  final List<Map<String, String>> _highlights = [
    {'emoji': '🛡️', 'label': 'Immunity Booster', 'desc': 'Helps build strong immunity'},
    {'emoji': '🧠', 'label': 'Brain Development', 'desc': 'Supports cognitive growth'},
    {'emoji': '🦴', 'label': 'Strong Bones', 'desc': 'Rich in calcium & minerals'},
    {'emoji': '🫃', 'label': 'Easy Digestion', 'desc': "Gentle on baby's tummy"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppConstants.paddingL),
                _buildNutritionBanner(),
                const SizedBox(height: AppConstants.paddingL),
                _buildDaySelector(),
                const SizedBox(height: AppConstants.paddingL),
                _buildMealTable(),
                const SizedBox(height: AppConstants.paddingL),
                _buildNutritionTip(),
                const SizedBox(height: AppConstants.paddingXL),
                _buildHighlights(),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Weekly Meal Plan', style: AppTextStyles.headlineMedium),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.ageGroup, style: AppTextStyles.bodySmall.copyWith(color: AppColors.accentGreen)),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.accentGreen),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.shopping_cart_outlined, size: 22), onPressed: () {}),
        IconButton(icon: const Icon(Icons.ios_share_rounded, size: 20), onPressed: () {}),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildNutritionBanner() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.accentGreenLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Row(
        children: [
          const Text('��', style: TextStyle(fontSize: 32)),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Balanced nutrition for your baby', style: AppTextStyles.titleLarge),
                const SizedBox(height: 2),
                Text(
                  'This plan includes easy, wholesome recipes with the right mix of nutrients for healthy growth.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.paddingS),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(color: AppColors.accentGreen, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book_outlined, size: 13, color: AppColors.accentGreen),
                const SizedBox(width: 4),
                Text('Nutrition\nGuide', style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentGreen), textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Row(
      children: _days.asMap().entries.map((entry) {
        final i = entry.key;
        final day = entry.value;
        final isSelected = _selectedDay == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDay = i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accentGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        day['label'] as String,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (day['isToday'] == true)
                        Text('Today', style: AppTextStyles.labelSmall.copyWith(
                          color: isSelected ? Colors.white70 : AppColors.accentGreen,
                          fontSize: 8,
                        )),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accentGreen : (day['dot'] as Color).withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMealTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // Table header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL, vertical: AppConstants.paddingM),
            child: Row(
              children: [
                SizedBox(width: 80, child: Text('Meal', style: AppTextStyles.labelMedium)),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(child: Text('Recipe', style: AppTextStyles.labelMedium)),
                const SizedBox(width: AppConstants.paddingM),
                SizedBox(width: 110, child: Text('Ingredients & Benefits', style: AppTextStyles.labelSmall)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          // Meal rows
          ..._meals.asMap().entries.map((entry) {
            final i = entry.key;
            final meal = entry.value;
            final recipe = meal['recipe'] as RecipeModel?;
            return Column(
              children: [
                _MealRow(
                  mealLabel: meal['meal'] as String,
                  mealTime: meal['time'] as String,
                  emoji: meal['emoji'] as String,
                  recipe: recipe,
                  onTap: recipe != null
                      ? () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => RecipeDetailScreen(recipe: recipe),
                          ))
                      : null,
                ),
                if (i < _meals.length - 1)
                  const Divider(height: 1, color: AppColors.divider),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNutritionTip() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.accentOrangeLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Row(
        children: [
          const Text('🥕', style: TextStyle(fontSize: 28)),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nutrition Tip', style: AppTextStyles.titleMedium.copyWith(color: AppColors.accentOrange)),
                const SizedBox(height: 2),
                Text(
                  'Introduce one new food at a time and wait 2–3 days to check for any allergies.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Text('Read More >', style: AppTextStyles.labelMedium.copyWith(color: AppColors.accentOrange)),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("This Week's Highlights", style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppConstants.paddingM),
        Row(
          children: _highlights.map((h) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: _highlights.indexOf(h) < _highlights.length - 1 ? 8 : 0),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(h['emoji']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text(h['label']!, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary), textAlign: TextAlign.center),
                      const SizedBox(height: 2),
                      Text(h['desc']!, style: AppTextStyles.labelSmall, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _MealRow extends StatelessWidget {
  final String mealLabel;
  final String mealTime;
  final String emoji;
  final RecipeModel? recipe;
  final VoidCallback? onTap;

  const _MealRow({
    required this.mealLabel,
    required this.mealTime,
    required this.emoji,
    this.recipe,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Meal time column
            SizedBox(
              width: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 2),
                  Text(mealLabel, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
                  Text(mealTime, style: AppTextStyles.labelSmall),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.paddingM),
            // Recipe column
            Expanded(
              child: recipe != null
                  ? Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                          child: Image.network(
                            recipe!.imageUrl,
                            width: 52, height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 52, height: 52,
                              color: AppColors.primaryLight,
                              child: const Center(child: Text('🍲', style: TextStyle(fontSize: 22))),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingS),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(recipe!.name, style: AppTextStyles.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                              Row(
                                children: [
                                  const Icon(Icons.timer_outlined, size: 11, color: AppColors.textSecondary),
                                  const SizedBox(width: 2),
                                  Text('${recipe!.cookTimeMinutes} min', style: AppTextStyles.labelSmall),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Text('Breast Milk / Formula\nAs needed', style: AppTextStyles.bodySmall),
            ),
            const SizedBox(width: AppConstants.paddingS),
            // Benefits column
            if (recipe != null)
              SizedBox(
                width: 110,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      recipe!.ingredients.take(3).map((i) => i.name).join(', '),
                      style: AppTextStyles.labelSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.eco_rounded, size: 10, color: AppColors.accentGreen),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            recipe!.benefit,
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentGreen),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
