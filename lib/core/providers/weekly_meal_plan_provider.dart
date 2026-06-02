import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/recipe_model.dart';

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
  WeeklyMealPlanNotifier() : super(_initialState);

  static Map<int, List<MealPlanSlot>> get _initialState => {
        0: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: sampleRecipes[0]),
          MealPlanSlot(mealName: 'Mid Morning', time: '10:30 AM', emoji: '🍎', recipe: sampleRecipes[4]),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: sampleRecipes[1]),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:00 PM', emoji: '🌤️', recipe: sampleRecipes[2]),
          MealPlanSlot(mealName: 'Dinner', time: '7:00 PM', emoji: '🌙', recipe: sampleRecipes[5]),
          const MealPlanSlot(mealName: 'Bedtime', time: '8:30 PM', emoji: '🍼', recipe: null),
        ],
        1: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: sampleRecipes[2]),
          MealPlanSlot(mealName: 'Mid Morning', time: '10:30 AM', emoji: '🍎', recipe: sampleRecipes[4]),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: sampleRecipes[0]),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:00 PM', emoji: '🌤️', recipe: sampleRecipes[1]),
          MealPlanSlot(mealName: 'Dinner', time: '7:00 PM', emoji: '🌙', recipe: sampleRecipes[5]),
          const MealPlanSlot(mealName: 'Bedtime', time: '8:30 PM', emoji: '🍼', recipe: null),
        ],
        2: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: sampleRecipes[0]),
          MealPlanSlot(mealName: 'Mid Morning', time: '10:30 AM', emoji: '🍎', recipe: sampleRecipes[4]),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: sampleRecipes[5]),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:00 PM', emoji: '🌤️', recipe: sampleRecipes[2]),
          MealPlanSlot(mealName: 'Dinner', time: '7:00 PM', emoji: '🌙', recipe: sampleRecipes[1]),
          const MealPlanSlot(mealName: 'Bedtime', time: '8:30 PM', emoji: '🍼', recipe: null),
        ],
        3: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: sampleRecipes[2]),
          MealPlanSlot(mealName: 'Mid Morning', time: '10:30 AM', emoji: '🍎', recipe: sampleRecipes[4]),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: sampleRecipes[1]),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:00 PM', emoji: '🌤️', recipe: sampleRecipes[0]),
          MealPlanSlot(mealName: 'Dinner', time: '7:00 PM', emoji: '🌙', recipe: sampleRecipes[5]),
          const MealPlanSlot(mealName: 'Bedtime', time: '8:30 PM', emoji: '🍼', recipe: null),
        ],
        4: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: sampleRecipes[0]),
          MealPlanSlot(mealName: 'Mid Morning', time: '10:30 AM', emoji: '🍎', recipe: sampleRecipes[4]),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: sampleRecipes[2]),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:00 PM', emoji: '🌤️', recipe: sampleRecipes[1]),
          MealPlanSlot(mealName: 'Dinner', time: '7:00 PM', emoji: '🌙', recipe: sampleRecipes[5]),
          const MealPlanSlot(mealName: 'Bedtime', time: '8:30 PM', emoji: '🍼', recipe: null),
        ],
        5: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: sampleRecipes[2]),
          MealPlanSlot(mealName: 'Mid Morning', time: '10:30 AM', emoji: '🍎', recipe: sampleRecipes[4]),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: sampleRecipes[0]),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:00 PM', emoji: '🌤️', recipe: sampleRecipes[1]),
          MealPlanSlot(mealName: 'Dinner', time: '7:00 PM', emoji: '🌙', recipe: sampleRecipes[5]),
          const MealPlanSlot(mealName: 'Bedtime', time: '8:30 PM', emoji: '🍼', recipe: null),
        ],
        6: [
          MealPlanSlot(mealName: 'Breakfast', time: '8:00 AM', emoji: '🌅', recipe: sampleRecipes[2]),
          MealPlanSlot(mealName: 'Mid Morning', time: '10:30 AM', emoji: '🍎', recipe: sampleRecipes[2]),
          MealPlanSlot(mealName: 'Lunch', time: '1:00 PM', emoji: '☀️', recipe: sampleRecipes[1]),
          MealPlanSlot(mealName: 'Evening Snack', time: '4:00 PM', emoji: '🌤️', recipe: sampleRecipes[2]),
          MealPlanSlot(mealName: 'Dinner', time: '7:00 PM', emoji: '🌙', recipe: sampleRecipes[5]),
          const MealPlanSlot(mealName: 'Bedtime', time: '8:30 PM', emoji: '🍼', recipe: null),
        ],
      };

  void updateSlot(int dayIndex, int slotIndex, RecipeModel? recipe) {
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
  }
}

final weeklyMealPlanProvider =
    StateNotifierProvider<WeeklyMealPlanNotifier, Map<int, List<MealPlanSlot>>>(
  (ref) => WeeklyMealPlanNotifier(),
);
