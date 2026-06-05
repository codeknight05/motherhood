import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/notifications_sheet.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/baby_avatar.dart';
import '../../../core/providers/baby_provider.dart';
import '../../../models/baby_model.dart';
import '../../../models/recipe_model.dart';
import 'recipe_detail_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import 'weekly_meal_plan_screen.dart';
import 'bookmarked_recipes_screen.dart';
import 'ai_recipes_screen.dart';
import 'allergy_guide_screen.dart';

class FoodMenuScreen extends ConsumerStatefulWidget {
  final String role;
  const FoodMenuScreen({super.key, this.role = 'parent'});

  @override
  ConsumerState<FoodMenuScreen> createState() => _FoodMenuScreenState();
}

class _FoodMenuScreenState extends ConsumerState<FoodMenuScreen> {
  int _selectedAgeGroup = 0;

  final List<Map<String, String>> _ageGroups = [
    {'label': '6\nMonths', 'emoji': '🍼'},
    {'label': '6–8\nMonths', 'emoji': '🥣'},
    {'label': '8–10\nMonths', 'emoji': '🥑'},
    {'label': '10–12\nMonths', 'emoji': '🍱'},
    {'label': '1–2\nYears', 'emoji': '🧒'},
  ];

  final List<Map<String, dynamic>> _quickCategories = [
    {'icon': Icons.calendar_today_rounded, 'label': 'Weekly\nMeal Plan', 'subtitle': 'Plan a week of healthy meals', 'color': AppColors.primaryLight, 'iconColor': AppColors.primary, 'route': 'meal_plan'},
    {'icon': Icons.bookmark_rounded, 'label': 'Saved\nRecipes', 'subtitle': 'Your bookmarked recipes', 'color': AppColors.accentOrangeLight, 'iconColor': AppColors.accentOrange, 'route': 'bookmarks'},
    {'icon': Icons.track_changes_rounded, 'label': 'Foods by\nGoal', 'subtitle': 'Weight gain, immunity & more', 'color': AppColors.accentPinkLight, 'iconColor': AppColors.accentPink, 'route': 'ai_recipes'},
    {'icon': Icons.shield_rounded, 'label': 'Allergy\nGuide', 'subtitle': 'Foods to avoid & be careful', 'color': AppColors.accentBlueLight, 'iconColor': AppColors.accentBlue, 'route': 'allergy_guide'},
  ];

  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final List<Map<String, String>> _popularCategories = [
    {'label': 'Iron Rich Foods', 'emoji': '🥬', 'color': 'green'},
    {'label': 'Brain Development', 'emoji': '🧠', 'color': 'pink'},
    {'label': 'Immunity Booster', 'emoji': '🛡️', 'color': 'orange'},
    {'label': 'Weight Gain', 'emoji': '📈', 'color': 'blue'},
  ];

  @override
  Widget build(BuildContext context) {
    final baby = ref.watch(babyProvider).baby ?? sampleBaby;

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
                _buildBabyCard(baby),
                const SizedBox(height: AppConstants.paddingL),
                _buildAgeGroupSelector(),
                const SizedBox(height: AppConstants.paddingL),
                _buildAiRecipesBanner(),
                const SizedBox(height: AppConstants.paddingXL),
                _buildQuickCategories(),
                const SizedBox(height: AppConstants.paddingXL),
                _buildTodaysPicks(),
                const SizedBox(height: AppConstants.paddingXL),
                _buildWeeklyMealPlan(),
                const SizedBox(height: AppConstants.paddingL),
                _buildNutritionTip(),
                const SizedBox(height: AppConstants.paddingXL),
                _buildPopularCategories(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: AppConstants.paddingL,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Nutrition', style: AppTextStyles.headlineLarge),
              const SizedBox(width: 6),
              const Text('🍽️', style: TextStyle(fontSize: 20)),
            ],
          ),
          Text(
            'Healthy food for every age & stage 💚',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary, size: 24),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Search feature coming soon!'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
            ));
          },
        ),
        const NotificationBell(),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildBabyCard(BabyModel baby) {
    return AppCard(
      child: Row(
        children: [
          BabyAvatar(name: baby.name, size: 52),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baby.name, style: AppTextStyles.headlineSmall),
                Text(
                  baby.ageString,
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.accentGreen),
                ),
                const SizedBox(height: 2),
                Text(
                  baby.isBorn
                      ? 'Introduce variety of foods & textures.'
                      : 'Preparing nutritious meals for your arrival.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => ProfileScreen.showEditBabySheet(context, ref, baby),
            child: Row(
              children: [
                Text(
                  'Change Child',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.accentGreen),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.edit_rounded, size: 14, color: AppColors.accentGreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiRecipesBanner() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AiRecipesScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'AI Daily Recipes',
                        style: AppTextStyles.headlineSmall.copyWith(color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                        ),
                        child: const Text(
                          'Mumma ✨',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.role == 'pregnant'
                        ? 'Fresh, innovative recipes generated daily\njust for your pregnancy needs'
                        : 'Fresh, innovative recipes generated daily\njust for your baby\'s age & needs',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Text(
                      'See Today\'s Recipes →',
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text('🤖', style: TextStyle(fontSize: 48)),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeGroupSelector() {
    if (widget.role == 'pregnant') return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _ageGroups.asMap().entries.map((entry) {
          final index = entry.key;
          final isSelected = _selectedAgeGroup == index;
          return Padding(
            padding: EdgeInsets.only(right: index < _ageGroups.length - 1 ? AppConstants.paddingS : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedAgeGroup = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentGreenLight : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: isSelected ? AppColors.accentGreen : AppColors.divider,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_ageGroups[index]['emoji']!, style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 3),
                    Text(
                      _ageGroups[index]['label']!,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSelected ? AppColors.accentGreen : AppColors.textSecondary,
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

  Widget _buildQuickCategories() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 450;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: AppConstants.paddingM,
        mainAxisSpacing: AppConstants.paddingM,
        childAspectRatio: isSmallScreen ? 0.82 : 0.68,
      ),
      itemCount: _quickCategories.length,
      itemBuilder: (context, index) {
        final cat = _quickCategories[index];
        return GestureDetector(
          onTap: () => _handleCategoryTap(cat['route'] as String?),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: cat['color'] as Color,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Icon(cat['icon'] as IconData, color: cat['iconColor'] as Color, size: 24),
              ),
              const SizedBox(height: 5),
              Text(
                cat['label'] as String,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isSmallScreen) ...[
                const SizedBox(height: 2),
                Text(
                  cat['subtitle'] as String,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, fontSize: 9),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _handleCategoryTap(String? route) {
    if (route == null) return;
    switch (route) {
      case 'meal_plan':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WeeklyMealPlanScreen(
              ageGroup: widget.role == 'pregnant' ? 'Pregnancy' : _ageGroups[_selectedAgeGroup]['label']!.replaceAll('\n', ' '),
              role: widget.role,
            ),
          ),
        );
        break;
      case 'bookmarks':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookmarkedRecipesScreen()),
        );
        break;
      case 'ai_recipes':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiRecipesScreen()),
        );
        break;
      case 'allergy_guide':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AllergyGuideScreen()),
        );
        break;
    }
  }

  String? _mapCategoryToTheme(String categoryLabel) {
    switch (categoryLabel) {
      case 'Iron Rich Foods':     return 'Iron Rich';
      case 'Brain Development':   return 'Brain Boost';
      case 'Immunity Booster':    return 'Immunity';
      case 'Weight Gain':         return 'Weight Gain';
      default:                    return null;
    }
  }

  Widget _buildTodaysPicks() {
    final picks = sampleRecipes
        .where((r) => widget.role == 'pregnant'
            ? r.ageGroups.contains('pregnant')
            : !r.ageGroups.contains('pregnant'))
        .take(4)
        .toList();
    final tagColors = [AppColors.accentGreen, AppColors.accentOrange, AppColors.primary, AppColors.accentPink];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: "Today's Picks", actionLabel: 'View all', onAction: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookmarkedRecipesScreen()),
          );
        }),
        const SizedBox(height: AppConstants.paddingM),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: picks.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppConstants.paddingM),
            itemBuilder: (context, index) {
              final recipe = picks[index];
              final tagColor = tagColors[index % tagColors.length];
              return SizedBox(
                width: 148,
                child: AppCard(
                  padding: EdgeInsets.zero,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(AppConstants.radiusL),
                              topRight: Radius.circular(AppConstants.radiusL),
                            ),
                            child: Image.network(
                              recipe.imageUrl,
                              height: 108,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 108,
                                color: AppColors.primaryLight,
                                child: const Center(child: Text('🍲', style: TextStyle(fontSize: 36))),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 7, left: 7,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: tagColor,
                                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                              ),
                              child: Text(
                                recipe.category.label,
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 7, right: 7,
                            child: Container(
                              width: 24, height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.favorite_border_rounded, size: 13, color: AppColors.accentPink),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.paddingS),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(recipe.name, style: AppTextStyles.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                              const Spacer(),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 10, color: AppColors.textSecondary),
                                  const SizedBox(width: 2),
                                  Text('${recipe.cookTimeMinutes} min', style: AppTextStyles.labelSmall),
                                  const SizedBox(width: 3),
                                  const Text('·', style: TextStyle(color: AppColors.textHint, fontSize: 10)),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      recipe.tag,
                                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentGreen),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              Text(recipe.benefit, style: AppTextStyles.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyMealPlan() {
    final bool isPregnant = widget.role == 'pregnant';
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isPregnant ? 'Weekly Meal Plan (Pregnancy)' : 'Weekly Meal Plan (${_ageGroups[_selectedAgeGroup]['label']!.replaceAll('\n', ' ')})',
                      style: AppTextStyles.titleLarge,
                    ),
                    Text(
                      isPregnant ? 'Balanced nutrition for your pregnancy' : 'Balanced nutrition for your baby',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WeeklyMealPlanScreen(
                      ageGroup: isPregnant ? 'Pregnancy' : _ageGroups[_selectedAgeGroup]['label']!.replaceAll('\n', ' '),
                      role: widget.role,
                    ),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentOrange,
                  side: const BorderSide(color: AppColors.accentOrange),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: AppTextStyles.labelSmall,
                ),
                child: const Text('View Full Plan'),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weekDays.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              final isWeekend = day == 'Fri' || day == 'Sat' || day == 'Sun';
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WeeklyMealPlanScreen(
                        ageGroup: isPregnant ? 'Pregnancy' : _ageGroups[_selectedAgeGroup]['label']!.replaceAll('\n', ' '),
                        initialDay: index,
                        role: widget.role,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        day,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isWeekend ? AppColors.accentGreen : AppColors.textSecondary,
                          fontWeight: isWeekend ? FontWeight.w700 : FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Center(child: Text('🍲', style: TextStyle(fontSize: 16))),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '4 Meals',
                        style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionTip() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.accentGreenLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_rounded, color: AppColors.accentGreen, size: 20),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nutrition Tip',
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.accentGreen),
                ),
                const SizedBox(height: 2),
                Text(
                  'Introduce one new food at a time and wait 2–3 days to check for any allergies.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const Text('🥦', style: TextStyle(fontSize: 28)),
        ],
      ),
    );
  }

  Widget _buildPopularCategories() {
    final colors = [AppColors.accentGreenLight, AppColors.accentPinkLight, AppColors.accentOrangeLight, AppColors.accentBlueLight];
    final textColors = [AppColors.accentGreen, AppColors.accentPink, AppColors.accentOrange, AppColors.accentBlue];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Popular Categories',
          actionLabel: 'View all',
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiRecipesScreen()),
          ),
        ),
        const SizedBox(height: AppConstants.paddingM),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_popularCategories.length, (index) {
              final cat = _popularCategories[index];
              return Padding(
                padding: EdgeInsets.only(right: index < _popularCategories.length - 1 ? AppConstants.paddingS : 0),
                child: GestureDetector(
                  onTap: () {
                    final theme = _mapCategoryToTheme(cat['label']!);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AiRecipesScreen(initialTheme: theme),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors[index],
                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                    ),
                    child: Row(
                      children: [
                        Text(cat['emoji']!, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          cat['label']!,
                          style: AppTextStyles.labelMedium.copyWith(color: textColors[index]),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
