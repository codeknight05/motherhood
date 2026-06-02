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

// ── Recipe Library provider ───────────────────────────────────────────────────

class RecipeLibraryNotifier extends StateNotifier<List<RecipeModel>> {
  RecipeLibraryNotifier() : super([...sampleRecipes]);

  void addRecipe(RecipeModel recipe) {
    if (!state.any((r) => r.id == recipe.id)) {
      state = [...state, recipe];
    }
  }

  void addRecipes(List<RecipeModel> recipes) {
    final updated = [...state];
    bool changed = false;
    for (final recipe in recipes) {
      if (!updated.any((r) => r.id == recipe.id)) {
        updated.add(recipe);
        changed = true;
      }
    }
    if (changed) {
      state = updated;
    }
  }
}

final recipeLibraryProvider =
    StateNotifierProvider<RecipeLibraryNotifier, List<RecipeModel>>(
  (_) => RecipeLibraryNotifier(),
);

/// Returns all bookmarked recipes — combines sample recipes + AI recipes from library.
final bookmarkedRecipesProvider = Provider<List<RecipeModel>>((ref) {
  final bookmarkedIds = ref.watch(bookmarksProvider);
  final library = ref.watch(recipeLibraryProvider);

  return library.where((r) => bookmarkedIds.contains(r.id)).toList();
});

// ── Daily recommendation provider ─────────────────────────────────────────────

final dailyRecipeProvider = Provider<RecipeModel>((ref) {
  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
  final index = dayOfYear % sampleRecipes.length;
  return sampleRecipes[index];
});
