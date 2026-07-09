import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/recipe_model.dart';
import '../services/supabase_service.dart';
import 'dietary_preference_provider.dart';

class MealPlanSlot {
  final String mealName;
  final String time;
  final String emoji;
  final RecipeModel? recipe;

  const MealPlanSlot({
    required this.mealName,
    required this.time,
    required this.emoji,
    this.recipe,
  });

  MealPlanSlot copyWith({
    String? mealName,
    String? time,
    String? emoji,
    RecipeModel? recipe,
    bool clearRecipe = false,
  }) {
    return MealPlanSlot(
      mealName: mealName ?? this.mealName,
      time: time ?? this.time,
      emoji: emoji ?? this.emoji,
      recipe: clearRecipe ? null : (recipe ?? this.recipe),
    );
  }
}

class WeeklyMealPlanNotifier extends StateNotifier<Map<int, List<MealPlanSlot>>> {
  final Ref _ref;
  WeeklyMealPlanNotifier(this._ref) : super(const {}) {
    // Load initial meal plan asynchronously
    loadWeeklyMealPlan(role: 'parent', ageGroup: '6–8 Months');
    
    _ref.listen<DietaryPreference>(dietaryPreferenceProvider, (previous, next) {
      loadWeeklyMealPlan(role: _currentRole, ageGroup: _currentAgeGroup);
    });
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String _currentRole = 'parent';
  String _currentAgeGroup = '6–8 Months';

  Future<void> loadWeeklyMealPlan({String? role, String? ageGroup}) async {
    _isLoading = true;
    state = {}; // Clear state to trigger loading indicator in UI
    String activeRole = role ?? 'parent';
    String activeAgeGroup = ageGroup ?? '6–8 Months';
    final dietaryPref = _ref.read(dietaryPreferenceProvider);

    if (role == null) {
      final user = SupabaseService.currentUser;
      if (user != null) {
        activeRole = await SupabaseService.fetchUserRole(user.id);
      }
    }
    _currentRole = activeRole;
    _currentAgeGroup = activeAgeGroup;

    try {
      var query = SupabaseService.client
          .from('weekly_meal_plans')
          .select('*, recipes:recipes(*)');

      if (activeRole == 'pregnant') {
        query = query.eq('role', 'pregnant');
      } else {
        query = query.eq('role', 'parent').eq('age_group', activeAgeGroup);
      }

      final response = await query
          .order('day_index', ascending: true)
          .order('slot_index', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      final Map<int, List<MealPlanSlot>> newPlan = {
        0: [],
        1: [],
        2: [],
        3: [],
        4: [],
        5: [],
        6: [],
      };

      for (final item in data) {
        final mapItem = Map<String, dynamic>.from(item as Map);
        final dayIndex = mapItem['day_index'] as int;
        final recipeMap = mapItem['recipes'] != null
            ? Map<String, dynamic>.from(mapItem['recipes'] as Map)
            : null;

        final recipe = recipeMap != null ? RecipeModel.fromMap(recipeMap) : null;

        final slot = MealPlanSlot(
          mealName: mapItem['meal_name'] as String,
          time: mapItem['time_label'] as String,
          emoji: mapItem['emoji'] as String,
          recipe: recipe,
        );

        if (newPlan.containsKey(dayIndex)) {
          newPlan[dayIndex]!.add(slot);
        }
      }

      // Check if we retrieved a complete weekly menu from Supabase
      if (newPlan.values.every((list) => list.isEmpty)) {
        state = _getFallbackInitialState(activeRole, activeAgeGroup, dietaryPref: dietaryPref);
      } else {
        state = newPlan;
      }
    } catch (e) {
      // Fallback on error
      state = _getFallbackInitialState(activeRole, activeAgeGroup, dietaryPref: dietaryPref);
    } finally {
      _isLoading = false;
    }
  }

  void updateSlot(int dayIndex, int slotIndex, RecipeModel? recipe) async {
    final daySlots = state[dayIndex];
    if (daySlots == null || slotIndex < 0 || slotIndex >= daySlots.length) return;

    final updatedSlots = List<MealPlanSlot>.from(daySlots);
    updatedSlots[slotIndex] = updatedSlots[slotIndex].copyWith(
      recipe: recipe,
      clearRecipe: recipe == null,
    );

    state = {
      ...state,
      dayIndex: updatedSlots,
    };

    // Asynchronously write changes to Supabase in the background
    try {
      var query = SupabaseService.client
          .from('weekly_meal_plans')
          .update({'recipe_id': recipe?.id})
          .eq('role', _currentRole)
          .eq('day_index', dayIndex)
          .eq('slot_index', slotIndex);

      if (_currentRole == 'parent') {
        query = query.eq('age_group', _currentAgeGroup);
      }

      await query;
    } catch (e) {
      // Log error but keep local state modified
      // (This ensures offline or policy failures do not crash the app)
      debugPrint('Failed to sync weekly meal plan update to Supabase: $e');
    }
  }

  static bool _recipeMatchesAgeGroup(RecipeModel recipe, String selectedLabel) {
    final label = selectedLabel.toLowerCase().replaceAll('–', '-').replaceAll('\n', ' ').trim();
    for (final group in recipe.ageGroups) {
      final gNorm = group.toLowerCase().replaceAll('–', '-').trim();
      if (gNorm == label) return true;
      if (label.contains('6 months') && (gNorm.contains('6 months') || gNorm.contains('6-8 months'))) return true;
      if (label.contains('6-8 months') && gNorm.contains('6-8 months')) return true;
      if (label.contains('8-10 months') && (gNorm.contains('9-12 months') || gNorm.contains('6-8 months') || gNorm.contains('8-10 months'))) return true;
      if (label.contains('10-12 months') && (gNorm.contains('10-12 months') || gNorm.contains('9-12 months'))) return true;
      if (label.contains('1-2 years') && gNorm.contains('1-2 years')) return true;
    }
    return false;
  }

  static Map<int, List<MealPlanSlot>> _getFallbackInitialState(
    String role,
    String ageGroup, {
    DietaryPreference dietaryPref = DietaryPreference.both,
  }) {
    final candidates = sampleRecipes.where((r) {
      final matchesRole = role == 'pregnant'
          ? r.ageGroups.contains('pregnant')
          : _recipeMatchesAgeGroup(r, ageGroup);
      final matchesDiet = dietaryPref == DietaryPreference.both || r.isVeg;
      return matchesRole && matchesDiet;
    }).toList();

    RecipeModel? getRecipeForCategory(RecipeCategory category, int dayIndex) {
      final categoryRecipes = candidates.where((r) {
        if (category == RecipeCategory.eveningSnack) {
          return r.category == RecipeCategory.eveningSnack || r.category == RecipeCategory.midMorning;
        }
        return r.category == category;
      }).toList();

      if (categoryRecipes.isEmpty) {
        final fallbackList = sampleRecipes.where((r) => dietaryPref == DietaryPreference.both || r.isVeg).toList();
        if (fallbackList.isEmpty) return null;
        return fallbackList[(dayIndex) % fallbackList.length];
      }
      return categoryRecipes[(dayIndex) % categoryRecipes.length];
    }

    final Map<int, List<MealPlanSlot>> plan = {};
    for (int day = 0; day < 7; day++) {
      plan[day] = [
        MealPlanSlot(
          mealName: 'Breakfast',
          time: '8:00 AM',
          emoji: '🌅',
          recipe: getRecipeForCategory(RecipeCategory.breakfast, day),
        ),
        MealPlanSlot(
          mealName: 'Lunch',
          time: '1:00 PM',
          emoji: '☀️',
          recipe: getRecipeForCategory(RecipeCategory.lunch, day),
        ),
        MealPlanSlot(
          mealName: 'Evening Snack',
          time: '4:30 PM',
          emoji: '🌤️',
          recipe: getRecipeForCategory(RecipeCategory.eveningSnack, day),
        ),
        MealPlanSlot(
          mealName: 'Dinner',
          time: '7:30 PM',
          emoji: '🌙',
          recipe: getRecipeForCategory(RecipeCategory.dinner, day),
        ),
      ];
    }
    return plan;
  }
}

final weeklyMealPlanProvider =
    StateNotifierProvider<WeeklyMealPlanNotifier, Map<int, List<MealPlanSlot>>>(
  (ref) => WeeklyMealPlanNotifier(ref),
);
