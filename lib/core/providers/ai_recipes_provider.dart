import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/recipe_model.dart';
import '../services/gemini_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

enum AiRecipesStatus { idle, loading, success, error }

class AiRecipesState {
  final List<RecipeModel> recipes;
  final AiRecipesStatus status;
  final String? error;
  final int ageInMonths;
  final String? focusTheme;

  const AiRecipesState({
    this.recipes = const [],
    this.status = AiRecipesStatus.idle,
    this.error,
    this.ageInMonths = 8,
    this.focusTheme,
  });

  bool get isLoading => status == AiRecipesStatus.loading;
  bool get hasError => status == AiRecipesStatus.error;
  bool get hasRecipes => recipes.isNotEmpty;

  AiRecipesState copyWith({
    List<RecipeModel>? recipes,
    AiRecipesStatus? status,
    String? error,
    int? ageInMonths,
    String? focusTheme,
  }) {
    return AiRecipesState(
      recipes: recipes ?? this.recipes,
      status: status ?? this.status,
      error: error,
      ageInMonths: ageInMonths ?? this.ageInMonths,
      focusTheme: focusTheme ?? this.focusTheme,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class AiRecipesNotifier extends StateNotifier<AiRecipesState> {
  AiRecipesNotifier() : super(const AiRecipesState());

  /// Generate fresh AI recipes for the given baby age.
  Future<void> generate({
    required int ageInMonths,
    String? focusTheme,
    int count = 5,
  }) async {
    state = state.copyWith(
      status: AiRecipesStatus.loading,
      ageInMonths: ageInMonths,
      focusTheme: focusTheme,
      error: null,
    );

    // Retry up to 3 times with backoff for rate limit errors
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final raw = await GeminiService.generateRecipes(
          ageInMonths: ageInMonths,
          count: count,
          focus: focusTheme,
        );

        if (raw.isEmpty) {
          state = state.copyWith(
            status: AiRecipesStatus.error,
            error: 'No recipes returned. Please try again.',
          );
          return;
        }

        final recipes = raw.map(_parseRecipe).toList();
        state = state.copyWith(
          recipes: recipes,
          status: AiRecipesStatus.success,
        );
        return; // success — exit retry loop

      } catch (e) {
        final msg = e.toString();
        final isRateLimit = msg.contains('429') || msg.contains('quota') || msg.contains('QUOTA');

        if (isRateLimit && attempt < 3) {
          // Wait before retrying: 15s, then 30s
          final waitSeconds = attempt * 15;
          state = state.copyWith(
            status: AiRecipesStatus.loading,
            error: null,
          );
          await Future.delayed(Duration(seconds: waitSeconds));
          continue; // retry
        }

        // Final failure — show user-friendly error
        String userMsg;
        if (isRateLimit) {
          userMsg = 'API rate limit reached. Please wait a minute and try again.\n\nThe free Gemini tier allows 15 requests per minute.';
        } else if (msg.contains('API_KEY') || msg.contains('api key')) {
          userMsg = 'Invalid API key. Please check your Gemini API key.';
        } else if (msg.contains('TimeoutException') || msg.contains('timeout')) {
          userMsg = 'Request timed out. Check your internet connection and try again.';
        } else if (msg.contains('SocketException') || msg.contains('network')) {
          userMsg = 'No internet connection. Please check your network and try again.';
        } else {
          userMsg = 'Failed to generate recipes. Please try again.\n\nDetails: $msg';
        }

        state = state.copyWith(
          status: AiRecipesStatus.error,
          error: userMsg,
        );
        return;
      }
    }
  }

  void clear() => state = const AiRecipesState();

  // ── Parser ────────────────────────────────────────────────────────────────

  RecipeModel _parseRecipe(Map<String, dynamic> m) {
    final ingredients = (m['ingredients'] as List? ?? []).map((i) {
      final ing = i as Map<String, dynamic>;
      return RecipeIngredient(
        name: ing['name'] as String? ?? '',
        quantity: ing['quantity'] as String? ?? '',
      );
    }).toList();

    final steps = (m['steps'] as List? ?? []).map((s) {
      final step = s as Map<String, dynamic>;
      return RecipeStep(
        stepNumber: (step['stepNumber'] as num?)?.toInt() ?? 1,
        title: step['title'] as String? ?? '',
        description: step['description'] as String?,
      );
    }).toList();

    final categoryStr = m['category'] as String? ?? 'lunch';
    final category = _parseCategory(categoryStr);

    return RecipeModel(
      id: m['id'] as String? ?? 'ai_${DateTime.now().millisecondsSinceEpoch}',
      name: m['name'] as String? ?? 'AI Recipe',
      description: m['description'] as String? ?? '',
      imageUrl: '', // AI recipes use emoji placeholder
      cookTimeMinutes: (m['cookTimeMinutes'] as num?)?.toInt() ?? 20,
      calories: (m['calories'] as num?)?.toInt() ?? 100,
      tag: m['tag'] as String? ?? 'Nutritious',
      benefit: m['benefit'] as String? ?? 'Healthy & delicious',
      ageGroups: List<String>.from(m['ageGroups'] as List? ?? []),
      category: category,
      ingredients: ingredients,
      steps: steps,
      howToServe: m['howToServe'] as String? ?? 'Serve warm.',
    );
  }

  RecipeCategory _parseCategory(String value) {
    switch (value.toLowerCase()) {
      case 'breakfast':    return RecipeCategory.breakfast;
      case 'midmorning':   return RecipeCategory.midMorning;
      case 'lunch':        return RecipeCategory.lunch;
      case 'eveningsnack': return RecipeCategory.eveningSnack;
      case 'dinner':       return RecipeCategory.dinner;
      case 'bedtime':      return RecipeCategory.bedtime;
      default:             return RecipeCategory.lunch;
    }
  }
}

final aiRecipesProvider =
    StateNotifierProvider<AiRecipesNotifier, AiRecipesState>(
  (_) => AiRecipesNotifier(),
);
