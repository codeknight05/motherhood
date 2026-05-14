import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/baby_avatar.dart';
import '../../../core/providers/baby_provider.dart';
import '../../../models/baby_model.dart';

class FoodMenuScreen extends ConsumerStatefulWidget {
  const FoodMenuScreen({super.key});

  @override
  ConsumerState<FoodMenuScreen> createState() => _FoodMenuScreenState();
}

class _FoodMenuScreenState extends ConsumerState<FoodMenuScreen> {
  int _selectedAgeGroup = 0;

  final List<Map<String, String>> _ageGroups = [
    {'label': '6–8\nMonths', 'emoji': '🍼'},
    {'label': '9–12\nMonths', 'emoji': '🥣'},
    {'label': '1–2\nYears', 'emoji': '🍱'},
    {'label': '2–4\nYears', 'emoji': '🧒'},
    {'label': '4–6\nYears', 'emoji': '👦'},
  ];

  final List<Map<String, dynamic>> _quickCategories = [
    {'icon': Icons.calendar_today_rounded, 'label': 'Weekly\nMeal Plan', 'subtitle': 'Plan a week of healthy meals', 'color': AppColors.primaryLight, 'iconColor': AppColors.primary},
    {'icon': Icons.restaurant_rounded, 'label': 'Recipes', 'subtitle': 'Simple & healthy recipes', 'color': AppColors.accentOrangeLight, 'iconColor': AppColors.accentOrange},
    {'icon': Icons.track_changes_rounded, 'label': 'Foods by\nGoal', 'subtitle': 'Weight gain, immunity & more', 'color': AppColors.accentPinkLight, 'iconColor': AppColors.accentPink},
    {'icon': Icons.shield_rounded, 'label': 'Allergy\nGuide', 'subtitle': 'Foods to avoid & be careful', 'color': AppColors.accentBlueLight, 'iconColor': AppColors.accentBlue},
  ];

  final List<Map<String, dynamic>> _todaysPicks = [
    {
      'name': 'Moong Dal Khichdi',
      'tag': 'Breakfast',
      'tagColor': AppColors.accentGreen,
      'time': '20 min',
      'badge': 'High Protein',
      'note': 'Good for weight gain',
      'image': 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=300',
    },
    {
      'name': 'Carrot & Potato Puree',
      'tag': 'Lunch',
      'tagColor': AppColors.accentOrange,
      'time': '15 min',
      'badge': 'Rich in Vit A',
      'note': 'Easy to digest',
      'image': 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=300',
    },
    {
      'name': 'Oats Veg Cheela',
      'tag': 'Snack',
      'tagColor': AppColors.primary,
      'time': '20 min',
      'badge': 'High Fiber',
      'note': 'Supports digestion',
      'image': 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=300',
    },
    {
      'name': 'Suji Apple Porridge',
      'tag': 'Dinner',
      'tagColor': AppColors.accentPink,
      'time': '15 min',
      'badge': 'Rich in Iron',
      'note': 'Support boost',
      'image': 'https://images.unsplash.com/photo-1517093157656-b9eccef91cb1?w=300',
    },
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
              Text('Food Menu', style: AppTextStyles.headlineLarge),
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
          onPressed: () {},
        ),
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 24),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                  child: const Center(child: Text('3', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700))),
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
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
            onTap: () {},
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

  Widget _buildAgeGroupSelector() {
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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: AppConstants.paddingM,
        mainAxisSpacing: AppConstants.paddingM,
        childAspectRatio: 0.68,
      ),
      itemCount: _quickCategories.length,
      itemBuilder: (context, index) {
        final cat = _quickCategories[index];
        return GestureDetector(
          onTap: () {},
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
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                cat['subtitle'] as String,
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, fontSize: 9),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodaysPicks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: "Today's Picks", actionLabel: 'View all', onAction: () {}),
        const SizedBox(height: AppConstants.paddingM),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _todaysPicks.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppConstants.paddingM),
            itemBuilder: (context, index) {
              final pick = _todaysPicks[index];
              return SizedBox(
                width: 148,
                child: AppCard(
                  padding: EdgeInsets.zero,
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
                              pick['image'] as String,
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
                            top: 7,
                            left: 7,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: pick['tagColor'] as Color,
                                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                              ),
                              child: Text(
                                pick['tag'] as String,
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 7,
                            right: 7,
                            child: Container(
                              width: 24,
                              height: 24,
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
                              Text(
                                pick['name'] as String,
                                style: AppTextStyles.titleMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 10, color: AppColors.textSecondary),
                                  const SizedBox(width: 2),
                                  Text(pick['time'] as String, style: AppTextStyles.labelSmall),
                                  const SizedBox(width: 3),
                                  const Text('·', style: TextStyle(color: AppColors.textHint, fontSize: 10)),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      pick['badge'] as String,
                                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentGreen),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                pick['note'] as String,
                                style: AppTextStyles.labelSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
                    Text('Weekly Meal Plan (6–8 Months)', style: AppTextStyles.titleLarge),
                    Text('Balanced nutrition for your baby', style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {},
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
            children: _weekDays.map((day) {
              final isWeekend = day == 'Fri' || day == 'Sat' || day == 'Sun';
              return Expanded(
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
                    Text('4 Meals', style: AppTextStyles.labelSmall.copyWith(fontSize: 9), textAlign: TextAlign.center),
                  ],
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
        SectionHeader(title: 'Popular Categories', actionLabel: 'View all', onAction: () {}),
        const SizedBox(height: AppConstants.paddingM),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_popularCategories.length, (index) {
              final cat = _popularCategories[index];
              return Padding(
                padding: EdgeInsets.only(right: index < _popularCategories.length - 1 ? AppConstants.paddingS : 0),
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
              );
            }),
          ),
        ),
      ],
    );
  }
}
