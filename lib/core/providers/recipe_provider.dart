import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/recipe_model.dart';

// ── Bookmarks provider ────────────────────────────────────────────────────────

class BookmarksNotifier extends StateNotifier<Set<String>> {
  BookmarksNotifier() : super({});

  void toggle(String recipeId) {
    if (state.contains(recipeId)) {
      state = {...state}..remove(recipeId);
    } else {
      state = {...state, recipeId};
    }
  }

  bool isBookmarked(String recipeId) => state.contains(recipeId);
}

final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, Set<String>>(
  (_) => BookmarksNotifier(),
);

// ── AI recipe store ───────────────────────────────────────────────────────────
// Holds AI-generated recipes in memory so they can be shown in bookmarks.

class AiBookmarkedRecipesNotifier extends StateNotifier<Map<String, RecipeModel>> {
  AiBookmarkedRecipesNotifier() : super({});

  /// Insert or update an AI recipe in the store.
  void upsert(RecipeModel recipe) {
    state = {...state, recipe.id: recipe};
  }

  void remove(String id) {
    final updated = Map<String, RecipeModel>.from(state);
    updated.remove(id);
    state = updated;
  }
}

final aiBookmarkedRecipesProvider =
    StateNotifierProvider<AiBookmarkedRecipesNotifier, Map<String, RecipeModel>>(
  (_) => AiBookmarkedRecipesNotifier(),
);

/// Returns all bookmarked recipes — combines sample recipes + AI recipes.
final bookmarkedRecipesProvider = Provider<List<RecipeModel>>((ref) {
  final bookmarkedIds = ref.watch(bookmarksProvider);
  final aiStore = ref.watch(aiBookmarkedRecipesProvider);

  // Merge sample + AI recipes, then filter by bookmarked IDs
  final allRecipes = [
    ...sampleRecipes,
    ...aiStore.values,
  ];

  // Deduplicate by id, preserving order (sample first, then AI)
  final seen = <String>{};
  final unique = allRecipes.where((r) => seen.add(r.id)).toList();

  return unique.where((r) => bookmarkedIds.contains(r.id)).toList();
});

// ── Daily recommendation provider ─────────────────────────────────────────────

final dailyRecipeProvider = Provider<RecipeModel>((ref) {
  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
  final index = dayOfYear % sampleRecipes.length;
  return sampleRecipes[index];
});
