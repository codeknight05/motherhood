import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/recipe_model.dart';
import '../services/supabase_service.dart';

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
  WeeklyMealPlanNotifier() : super(_getFallbackInitialState('parent', '6–8 Months'));

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String _currentRole = 'parent';
  String _currentAgeGroup = '6–8 Months';

  Future<void> loadWeeklyMealPlan({String? role, String? ageGroup}) async {
    _isLoading = true;
    state = {}; // Clear state to trigger loading indicator in UI
    String activeRole = role ?? 'parent';
    String activeAgeGroup = ageGroup ?? '6–8 Months';

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
        state = _getFallbackInitialState(activeRole, activeAgeGroup);
      } else {
        state = newPlan;
      }
    } catch (e) {
      // Fallback on error
      state = _getFallbackInitialState(activeRole, activeAgeGroup);
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

  static RecipeModel? _getRecipeById(String id) {
    try {
      return sampleRecipes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  static Map<int, List<MealPlanSlot>> _getFallbackInitialState(String role, String ageGroup) {
    if (role == 'pregnant') {
      return {
        0: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('101')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('102')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('103')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('104')),
        ],
        1: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('105')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('106')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('107')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('108')),
        ],
        2: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('109')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('110')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('111')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('112')),
        ],
        3: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('113')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('114')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('115')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('116')),
        ],
        4: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('117')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('118')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('119')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('120')),
        ],
        5: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('121')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('122')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('123')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('124')),
        ],
        6: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('125')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('126')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('127')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('128')),
        ],
      };
    }

    // Determine target age group fallbacks
    if (ageGroup.contains('6 Months')) {
      return {
        0: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('301')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('302')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('303')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('304')),
        ],
        1: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('305')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('306')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('303')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('307')),
        ],
        2: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('308')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('309')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('303')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('310')),
        ],
        3: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('311')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('312')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('303')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('313')),
        ],
        4: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('305')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('314')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('303')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('304')),
        ],
        5: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('308')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('315')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('303')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('316')),
        ],
        6: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('301')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('317')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('303')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('318')),
        ],
      };
    } else if (ageGroup.contains('6–8 Months')) {
      return {
        0: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('305')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('319')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('304')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('309')),
        ],
        1: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('301')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('313')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('307')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('308')),
        ],
        2: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('320')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('306')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('318')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('321')),
        ],
        3: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('322')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('323')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('304')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('324')),
        ],
        4: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('305')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('325')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('326')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('327')),
        ],
        5: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('301')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('328')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('316')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('319')),
        ],
        6: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('308')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('317')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('318')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('325')),
        ],
      };
    } else if (ageGroup.contains('8–10 Months')) {
      return {
        0: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('329')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('330')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('331')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('317')),
        ],
        1: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('305')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('332')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('333')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('308')),
        ],
        2: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('334')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('335')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('336')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('337')),
        ],
        3: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('338')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('339')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('340')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('341')),
        ],
        4: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('342')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('343')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('344')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('324')),
        ],
        5: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('345')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('346')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('312')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('319')),
        ],
        6: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('305')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('347')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('348')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('325')),
        ],
      };
    } else if (ageGroup.contains('10–12 Months')) {
      return {
        0: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('349')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('350')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('351')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('352')),
        ],
        1: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('353')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('323')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('336')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('355')),
        ],
        2: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('356')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('357')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('331')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('358')),
        ],
        3: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('359')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('360')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('361')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('319')),
        ],
        4: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('362')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('363')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('364')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('365')),
        ],
        5: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('366')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('367')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('340')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('368')),
        ],
        6: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('369')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('370')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('348')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('352')),
        ],
      };
    } else {
      // Default to 1-2 Years fallback
      return {
        0: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('371')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('372')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('373')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('374')),
        ],
        1: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('375')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('376')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('377')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('378')),
        ],
        2: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('379')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('380')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('381')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('382')),
        ],
        3: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('359')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('363')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('383')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('319')),
        ],
        4: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('384')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('385')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('386')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('368')),
        ],
        5: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('356')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('387')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('388')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('389')),
        ],
        6: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: _getRecipeById('390')),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: _getRecipeById('391')),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:30 PM', emoji: '🌤️', recipe: _getRecipeById('392')),
          MealPlanSlot(mealName: 'Dinner', time: '7:30 PM', emoji: '🌙', recipe: _getRecipeById('393')),
        ],
      };
    }
  }
}

final weeklyMealPlanProvider =
    StateNotifierProvider<WeeklyMealPlanNotifier, Map<int, List<MealPlanSlot>>>(
  (ref) => WeeklyMealPlanNotifier(),
);
