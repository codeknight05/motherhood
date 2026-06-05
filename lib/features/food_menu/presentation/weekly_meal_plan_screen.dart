import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/recipe_model.dart';
import '../../../core/providers/weekly_meal_plan_provider.dart';
import '../../../core/providers/recipe_provider.dart';
import 'recipe_detail_screen.dart';
import 'allergy_guide_screen.dart';

class WeeklyMealPlanScreen extends ConsumerStatefulWidget {
  final String ageGroup;
  final int initialDay;
  final String role;
  const WeeklyMealPlanScreen({
    super.key,
    this.ageGroup = '6–8 Months',
    this.initialDay = 0,
    this.role = 'parent',
  });

  @override
  ConsumerState<WeeklyMealPlanScreen> createState() => _WeeklyMealPlanScreenState();
}

class _WeeklyMealPlanScreenState extends ConsumerState<WeeklyMealPlanScreen> {
  int _selectedDay = 0;
  final ScrollController _scrollController = ScrollController();
  bool _copied = false;
  final Set<String> _checkedIngredients = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDay;
    Future.microtask(() {
      ref.read(weeklyMealPlanProvider.notifier).loadWeeklyMealPlan(
            role: widget.role,
            ageGroup: widget.ageGroup,
          );
    });
  }

  List<Map<String, dynamic>> get _days {
    final int today = DateTime.now().weekday;
    return [
      {'label': 'Mon', 'dot': AppColors.accentGreen, 'isToday': today == DateTime.monday},
      {'label': 'Tue', 'dot': AppColors.accentPink, 'isToday': today == DateTime.tuesday},
      {'label': 'Wed', 'dot': AppColors.primary, 'isToday': today == DateTime.wednesday},
      {'label': 'Thu', 'dot': AppColors.accentOrange, 'isToday': today == DateTime.thursday},
      {'label': 'Fri', 'dot': AppColors.accentBlue, 'isToday': today == DateTime.friday},
      {'label': 'Sat', 'dot': AppColors.accentGreen, 'isToday': today == DateTime.saturday},
      {'label': 'Sun', 'dot': AppColors.accentPink, 'isToday': today == DateTime.sunday},
    ];
  }

  Map<String, List<Map<String, dynamic>>> _compileShoppingList(
    Map<int, List<MealPlanSlot>> weeklyMeals,
  ) {
    final Map<String, List<Map<String, dynamic>>> list = {
      'Produce & Veggies 🥕': [],
      'Grains & Pulses 🌾': [],
      'Pantry & Staples 🍯': [],
    };

    final Map<String, List<String>> ingredientQuantities = {};
    final Map<String, String> ingredientNames = {};

    for (final dayMeals in weeklyMeals.values) {
      for (final slot in dayMeals) {
        final recipe = slot.recipe;
        if (recipe == null) continue;

        for (final ingredient in recipe.ingredients) {
          final name = ingredient.name.trim();
          final nameLower = name.toLowerCase();

          if (!ingredientQuantities.containsKey(nameLower)) {
            ingredientQuantities[nameLower] = [];
            ingredientNames[nameLower] = name;
          }
          ingredientQuantities[nameLower]!.add(ingredient.quantity.trim());
        }
      }
    }

    ingredientQuantities.forEach((nameLower, rawQuantities) {
      final combinedQty = _combineQuantities(rawQuantities);
      final originalName = ingredientNames[nameLower]!;
      final category = _categorizeIngredient(originalName);

      list[category]!.add({
        'name': originalName,
        'qty': combinedQty,
      });
    });

    return list;
  }

  String _combineQuantities(List<String> rawQuantities) {
    if (rawQuantities.isEmpty) return '';
    if (rawQuantities.length == 1) return rawQuantities.first;

    final Map<String, double> numericSums = {};
    final List<String> notes = [];

    for (final raw in rawQuantities) {
      final parsed = _parseQuantity(raw);
      if (parsed.value > 0.0) {
        String unit = parsed.unit.trim().toLowerCase();
        if (unit == 'cups') unit = 'cup';
        if (unit == 'pinches') unit = 'pinch';
        if (unit == 'pieces') unit = 'piece';
        if (unit == 'grams') unit = 'g';

        numericSums[unit] = (numericSums[unit] ?? 0.0) + parsed.value;
      } else {
        if (raw.isNotEmpty) {
          notes.add(raw);
        }
      }
    }

    final List<String> parts = [];

    numericSums.forEach((unit, sum) {
      String sumStr;
      final intPart = sum.truncate();
      final fracPart = sum - intPart;

      if (fracPart == 0.0) {
        sumStr = intPart.toString();
      } else if ((fracPart - 0.5).abs() < 0.05) {
        sumStr = intPart > 0 ? '$intPart ½' : '½';
      } else if ((fracPart - 0.25).abs() < 0.05) {
        sumStr = intPart > 0 ? '$intPart ¼' : '¼';
      } else if ((fracPart - 0.75).abs() < 0.05) {
        sumStr = intPart > 0 ? '$intPart ¾' : '¾';
      } else {
        sumStr = sum.toStringAsFixed(1);
        if (sumStr.endsWith('.0')) {
          sumStr = sumStr.substring(0, sumStr.length - 2);
        }
      }

      if (unit.isNotEmpty) {
        String displayUnit = unit;
        if (sum > 1.0) {
          if (unit == 'cup') displayUnit = 'cups';
          if (unit == 'pinch') displayUnit = 'pinches';
          if (unit == 'piece') displayUnit = 'pieces';
        }
        parts.add('$sumStr $displayUnit');
      } else {
        parts.add(sumStr);
      }
    });

    for (final note in notes) {
      final lowerNote = note.toLowerCase();
      if (!parts.any((p) => p.toLowerCase().contains(lowerNote))) {
        parts.add(note);
      }
    }

    return parts.join(' + ');
  }

  _ParsedQuantity _parseQuantity(String raw) {
    final clean = raw.trim().toLowerCase();
    if (clean.isEmpty) {
      return const _ParsedQuantity(value: 0, unit: '');
    }

    double val = 0.0;
    String remaining = clean;

    if (remaining.startsWith('½')) {
      val = 0.5;
      remaining = remaining.substring(1).trim();
    } else if (remaining.startsWith('¼')) {
      val = 0.25;
      remaining = remaining.substring(1).trim();
    } else if (remaining.startsWith('¾')) {
      val = 0.75;
      remaining = remaining.substring(1).trim();
    } else if (remaining.startsWith('⅓')) {
      val = 0.33;
      remaining = remaining.substring(1).trim();
    } else if (remaining.startsWith('⅔')) {
      val = 0.67;
      remaining = remaining.substring(1).trim();
    } else {
      final match = RegExp(r'^([0-9]+(?:\.[0-9]+)?)\s*(.*)$').firstMatch(remaining);
      if (match != null) {
        val = double.tryParse(match.group(1)!) ?? 0.0;
        remaining = match.group(2)!.trim();

        if (remaining.startsWith('½')) {
          val += 0.5;
          remaining = remaining.substring(1).trim();
        } else if (remaining.startsWith('¼')) {
          val += 0.25;
          remaining = remaining.substring(1).trim();
        } else if (remaining.startsWith('¾')) {
          val += 0.75;
          remaining = remaining.substring(1).trim();
        }
      } else {
        return _ParsedQuantity(value: 0.0, unit: '', note: raw);
      }
    }

    final units = ['tbsp', 'tsp', 'cups', 'cup', 'medium', 'small', 'pinch', 'pinches', 'piece', 'pieces', 'g', 'grams', 'kg', 'ml'];
    String unit = '';
    String note = '';

    for (final u in units) {
      if (remaining.startsWith(u)) {
        unit = u;
        note = remaining.substring(u.length).trim();
        break;
      }
    }

    if (unit.isEmpty) {
      unit = remaining;
    }

    return _ParsedQuantity(value: val, unit: unit, note: note);
  }

  String _categorizeIngredient(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('carrot') ||
        lower.contains('potato') ||
        lower.contains('banana') ||
        lower.contains('lauki') ||
        lower.contains('gourd') ||
        lower.contains('apple') ||
        lower.contains('fruit') ||
        lower.contains('vegetable') ||
        lower.contains('veg') ||
        lower.contains('onion') ||
        lower.contains('tomato') ||
        lower.contains('spinach') ||
        lower.contains('ginger') ||
        lower.contains('garlic') ||
        lower.contains('almond') ||
        lower.contains('cashew') ||
        lower.contains('nut')) {
      return 'Produce & Veggies 🥕';
    } else if (lower.contains('rice') ||
        lower.contains('dal') ||
        lower.contains('flour') ||
        lower.contains('ragi') ||
        lower.contains('millet') ||
        lower.contains('wheat') ||
        lower.contains('grain') ||
        lower.contains('pulse') ||
        lower.contains('oat') ||
        lower.contains('suji') ||
        lower.contains('semolina')) {
      return 'Grains & Pulses 🌾';
    } else {
      return 'Pantry & Staples 🍯';
    }
  }

  void _showRecipeSelectorSheet(
    BuildContext context,
    int dayIndex,
    int slotIndex,
    MealPlanSlot slot,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _RecipeSelectorSheet(
          mealName: slot.mealName,
          currentRecipe: slot.recipe,
          onSelect: (recipe) {
            ref.read(weeklyMealPlanProvider.notifier).updateSlot(dayIndex, slotIndex, recipe);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  recipe != null
                      ? 'Updated ${slot.mealName} to ${recipe.name}'
                      : 'Cleared recipe for ${slot.mealName}',
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.primary,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
              ),
            );
          },
        );
      },
    );
  }

  final List<Map<String, String>> _highlights = [
    {'emoji': '🛡️', 'label': 'Immunity Booster', 'desc': 'Helps build strong immunity'},
    {'emoji': '🧠', 'label': 'Brain Development', 'desc': 'Supports cognitive growth'},
    {'emoji': '🦴', 'label': 'Strong Bones', 'desc': 'Rich in calcium & minerals'},
    {'emoji': '🫃', 'label': 'Easy Digestion', 'desc': "Gentle on baby's tummy"},
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToShoppingList() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent * 0.5,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToSharePanel() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
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
                const SizedBox(height: AppConstants.paddingXL),
                _buildShoppingListSection(),
                const SizedBox(height: AppConstants.paddingXL),
                _buildSharePanel(),
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
        // Shopping List Link
        GestureDetector(
          onTap: _scrollToShoppingList,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart_outlined, size: 20, color: AppColors.textPrimary),
                Text('Shopping List', style: AppTextStyles.labelSmall.copyWith(fontSize: 8)),
              ],
            ),
          ),
        ),
        // Share Plan Link
        GestureDetector(
          onTap: _scrollToSharePanel,
          child: Padding(
            padding: const EdgeInsets.only(left: 4, right: 12, top: 8, bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.ios_share_rounded, size: 20, color: AppColors.textPrimary),
                Text('Share Plan', style: AppTextStyles.labelSmall.copyWith(fontSize: 8)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionBanner() {
    final isPregnant = widget.role == 'pregnant';
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.accentGreenLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Row(
        children: [
          const Text('🥗', style: TextStyle(fontSize: 32)),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isPregnant ? 'Balanced nutrition for your pregnancy' : 'Balanced nutrition for your baby',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  isPregnant
                      ? 'This plan includes nutrient-rich, wholesome recipes with the right mix of vitamins and minerals for a healthy pregnancy.'
                      : 'This plan includes easy, wholesome recipes with the right mix of nutrients for healthy growth.',
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

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
                          fontSize: isSmallScreen ? 11 : 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      Opacity(
                        opacity: day['isToday'] == true ? 1.0 : 0.0,
                        child: Text(
                          'Today',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected ? Colors.white70 : AppColors.accentGreen,
                            fontSize: isSmallScreen ? 7 : 8,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
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
    final weeklyMeals = ref.watch(weeklyMealPlanProvider);
    if (weeklyMeals.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    final dayMeals = weeklyMeals[_selectedDay] ?? weeklyMeals[0]!;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

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
                const SizedBox(width: AppConstants.paddingS),
                Expanded(child: Text('Recipe', style: AppTextStyles.labelMedium)),
                if (!isSmallScreen) ...[
                  const SizedBox(width: AppConstants.paddingS),
                  SizedBox(width: 110, child: Text('Ingredients & Benefits', style: AppTextStyles.labelSmall)),
                ],
                const SizedBox(width: AppConstants.paddingS),
                const SizedBox(width: 24),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          // Meal rows
          ...dayMeals.asMap().entries.map((entry) {
            final i = entry.key;
            final slot = entry.value;
            final recipe = slot.recipe;
            return Column(
              children: [
                _MealRow(
                  mealLabel: slot.mealName,
                  mealTime: slot.time,
                  emoji: slot.emoji,
                  recipe: recipe,
                  onTap: recipe != null
                      ? () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => RecipeDetailScreen(recipe: recipe),
                          ))
                      : null,
                  onEdit: () => _showRecipeSelectorSheet(context, _selectedDay, i, slot),
                ),
                if (i < dayMeals.length - 1)
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
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllergyGuideScreen())),
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
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppConstants.paddingS,
          crossAxisSpacing: AppConstants.paddingS,
          childAspectRatio: 2.3,
          children: _highlights.map((h) {
            return Container(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Text(h['emoji']!, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: AppConstants.paddingS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          h['label']!,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          h['desc']!,
                          style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildShoppingListSection() {
    final weeklyMeals = ref.watch(weeklyMealPlanProvider);
    if (weeklyMeals.isEmpty) return const SizedBox.shrink();
    final shoppingList = _compileShoppingList(weeklyMeals);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Weekly Shopping List', style: AppTextStyles.headlineSmall),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _checkedIngredients.clear();
                });
              },
              icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.accentPink),
              label: Text('Reset', style: AppTextStyles.labelMedium.copyWith(color: AppColors.accentPink)),
            )
          ],
        ),
        const SizedBox(height: AppConstants.paddingM),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: shoppingList.entries.where((e) => e.value.isNotEmpty).map((category) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL, vertical: 10),
                    color: AppColors.background,
                    child: Text(
                      category.key,
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  ...category.value.map((item) {
                    final itemName = item['name'] as String;
                    final isChecked = _checkedIngredients.contains(itemName);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isChecked) {
                            _checkedIngredients.remove(itemName);
                          } else {
                            _checkedIngredients.add(itemName);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL, vertical: 12),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: isChecked ? AppColors.accentGreen : Colors.transparent,
                                border: Border.all(
                                  color: isChecked ? AppColors.accentGreen : AppColors.textHint,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: isChecked
                                  ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: AppConstants.paddingM),
                            Expanded(
                              child: Text(
                                itemName,
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: isChecked ? AppColors.textHint : AppColors.textPrimary,
                                  decoration: isChecked ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                            Text(
                              item['qty'] as String,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isChecked ? AppColors.textHint : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const Divider(height: 1, color: AppColors.divider),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSharePanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Share Meal Plan', style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppConstants.paddingM),
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryLight, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(color: AppColors.primaryMid),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('📱', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: AppConstants.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Share this plan with family', style: AppTextStyles.titleLarge),
                        Text(
                          'Send the weekly schedule and ingredients list directly to your partner, family, or caregiver.',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingL),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _copyPlanToClipboard,
                      icon: Icon(
                        _copied ? Icons.check_circle_rounded : Icons.copy_rounded,
                        size: 18,
                        color: _copied ? Colors.white : AppColors.primary,
                      ),
                      label: Text(
                        _copied ? 'Copied!' : 'Copy Plan',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: _copied ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _copied ? AppColors.accentGreen : AppColors.surface,
                        foregroundColor: _copied ? Colors.white : AppColors.primary,
                        elevation: 0,
                        side: BorderSide(
                          color: _copied ? AppColors.accentGreen : AppColors.primaryMid,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingM),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _shareToWhatsApp,
                      icon: const Icon(Icons.share_rounded, size: 18, color: Colors.white),
                      label: Text(
                        'WhatsApp',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getShareText() {
    final buffer = StringBuffer();
    buffer.writeln('🌸 MOTHERHOOD WEEKLY MEAL PLAN (${widget.ageGroup}) 🌸\n');
    
    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final weeklyMeals = ref.read(weeklyMealPlanProvider);
    if (weeklyMeals.isEmpty) return 'No meal plan loaded yet.';
    for (int dayIdx = 0; dayIdx < 7; dayIdx++) {
      buffer.writeln('📅 ${daysOfWeek[dayIdx]}:');
      final meals = weeklyMeals[dayIdx] ?? weeklyMeals[0]!;
      for (var meal in meals) {
        final recipe = meal.recipe;
        buffer.writeln('  - ${meal.mealName} (${meal.time}): ${recipe?.name ?? "Breast Milk / Formula"}');
      }
      buffer.writeln();
    }

    buffer.writeln('🛒 SHOPPING LIST:');
    final shoppingList = _compileShoppingList(weeklyMeals);
    shoppingList.forEach((category, items) {
      if (items.isEmpty) return;
      buffer.writeln('🔹 $category:');
      for (var item in items) {
        buffer.writeln('  [ ] ${item['name']} - ${item['qty']}');
      }
    });

    return buffer.toString();
  }

  void _copyPlanToClipboard() {
    final text = _getShareText();
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meal plan & shopping list copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _copied = false);
      }
    });
  }

  void _shareToWhatsApp() async {
    final text = _getShareText();
    final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open WhatsApp. Copying plan to clipboard instead.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _copyPlanToClipboard();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching WhatsApp: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _MealRow extends StatelessWidget {
  final String mealLabel;
  final String mealTime;
  final String emoji;
  final RecipeModel? recipe;
  final VoidCallback? onTap;
  final VoidCallback onEdit;

  const _MealRow({
    required this.mealLabel,
    required this.mealTime,
    required this.emoji,
    this.recipe,
    this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL, vertical: AppConstants.paddingM),
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
            const SizedBox(width: AppConstants.paddingS),
            // Recipe column
            Expanded(
              child: recipe != null
                  ? Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                          child: recipe!.imageUrl.isNotEmpty
                              ? Image.network(
                                  recipe!.imageUrl,
                                  width: 52, height: 52,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 52, height: 52,
                                    color: AppColors.primaryLight,
                                    child: const Center(child: Text('🍲', style: TextStyle(fontSize: 22))),
                                  ),
                                )
                              : Container(
                                  width: 52, height: 52,
                                  color: AppColors.primaryLight,
                                  child: const Center(child: Text('🍲', style: TextStyle(fontSize: 22))),
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
                              if (isSmallScreen) ...[
                                const SizedBox(height: 2),
                                Text(
                                  recipe!.ingredients.take(2).map((i) => i.name).join(', '),
                                  style: AppTextStyles.labelSmall.copyWith(fontSize: 9, color: AppColors.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    )
                  : Text('Breast Milk / Formula\nAs needed', style: AppTextStyles.bodySmall),
            ),
            if (!isSmallScreen) ...[
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
                )
              else
                const SizedBox(width: 110),
            ],
            const SizedBox(width: AppConstants.paddingS),
            // Edit / Add button
            SizedBox(
              width: 24,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  recipe != null ? Icons.edit_outlined : Icons.add_circle_outline_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                onPressed: onEdit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recipe Selector Bottom Sheet ──────────────────────────────────────────────

class _RecipeSelectorSheet extends ConsumerStatefulWidget {
  final String mealName;
  final RecipeModel? currentRecipe;
  final ValueChanged<RecipeModel?> onSelect;

  const _RecipeSelectorSheet({
    required this.mealName,
    this.currentRecipe,
    required this.onSelect,
  });

  @override
  ConsumerState<_RecipeSelectorSheet> createState() => _RecipeSelectorSheetState();
}

class _RecipeSelectorSheetState extends ConsumerState<_RecipeSelectorSheet> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks',
    'AI Generated',
    'Bookmarked'
  ];

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(recipeLibraryProvider);
    final bookmarkedIds = ref.watch(bookmarksProvider);

    final filteredRecipes = library.where((recipe) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = recipe.name.toLowerCase().contains(query);
        final descMatch = recipe.description.toLowerCase().contains(query);
        final tagMatch = recipe.tag.toLowerCase().contains(query);
        final ingredientMatch = recipe.ingredients.any((i) => i.name.toLowerCase().contains(query));
        if (!nameMatch && !descMatch && !tagMatch && !ingredientMatch) {
          return false;
        }
      }

      if (_selectedCategory == 'All') return true;
      if (_selectedCategory == 'Breakfast') return recipe.category == RecipeCategory.breakfast;
      if (_selectedCategory == 'Lunch') return recipe.category == RecipeCategory.lunch;
      if (_selectedCategory == 'Dinner') return recipe.category == RecipeCategory.dinner;
      if (_selectedCategory == 'Snacks') {
        return recipe.category == RecipeCategory.eveningSnack || 
               recipe.category == RecipeCategory.midMorning;
      }
      if (_selectedCategory == 'AI Generated') {
        return recipe.id.startsWith('ai_');
      }
      if (_selectedCategory == 'Bookmarked') {
        return bookmarkedIds.contains(recipe.id);
      }
      return true;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppConstants.radiusXL),
          topRight: Radius.circular(AppConstants.radiusXL),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.textHint.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select ${widget.mealName} Recipe',
                        style: AppTextStyles.headlineMedium.copyWith(fontSize: 20),
                      ),
                      Text(
                        'Choose a recipe from your library',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(color: AppColors.divider),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search by name, ingredients, tags...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: AppColors.textHint),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = cat);
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          if (widget.currentRecipe != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
              child: ListTile(
                onTap: () => widget.onSelect(null),
                tileColor: AppColors.accentPinkLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  side: const BorderSide(color: AppColors.accentPink),
                ),
                leading: const Text('🍼', style: TextStyle(fontSize: 22)),
                title: Text(
                  'Reset to Breast Milk / Formula',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.accentPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text('Remove recipe and show default infant feeding option'),
                trailing: const Icon(Icons.clear_rounded, color: AppColors.accentPink),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: filteredRecipes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text('No recipes found', style: AppTextStyles.headlineSmall),
                        Text(
                          'Try searching for something else or change filters',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      final isSelected = widget.currentRecipe?.id == recipe.id;
                      final isAi = recipe.id.startsWith('ai_');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => widget.onSelect(recipe),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryLight : AppColors.surface,
                              borderRadius: BorderRadius.circular(AppConstants.radiusL),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.divider,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: isAi ? AppColors.softPurpleGradient : AppColors.softGreenGradient,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(AppConstants.radiusL),
                                      bottomLeft: Radius.circular(AppConstants.radiusL),
                                    ),
                                  ),
                                  child: Center(
                                    child: recipe.imageUrl.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(AppConstants.radiusL),
                                              bottomLeft: Radius.circular(AppConstants.radiusL),
                                            ),
                                            child: Image.network(
                                              recipe.imageUrl,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => const Text('🍲', style: TextStyle(fontSize: 32)),
                                            ),
                                          )
                                        : const Text('🍲', style: TextStyle(fontSize: 32)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            if (isAi) ...[
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                decoration: BoxDecoration(
                                                  gradient: AppColors.primaryGradient,
                                                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                                                ),
                                                child: const Text(
                                                  'AI',
                                                  style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                            ],
                                            Text(
                                              recipe.category.label,
                                              style: AppTextStyles.labelSmall.copyWith(
                                                color: AppColors.textSecondary,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          recipe.name,
                                          style: AppTextStyles.titleMedium.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          recipe.benefit,
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: AppColors.accentGreen,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 16),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  )
                                else
                                  const Padding(
                                    padding: EdgeInsets.only(right: 16),
                                    child: Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ParsedQuantity {
  final double value;
  final String unit;
  final String note;

  const _ParsedQuantity({
    required this.value,
    required this.unit,
    this.note = '',
  });
}
