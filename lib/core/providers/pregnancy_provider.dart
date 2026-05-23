import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/pregnancy_guidance_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class PregnancyState {
  final int currentWeek;
  final PregnancyWeekGuidance? guidance;
  final bool isLoading;
  final String? error;

  const PregnancyState({
    this.currentWeek = 1,
    this.guidance,
    this.isLoading = false,
    this.error,
  });

  PregnancyState copyWith({
    int? currentWeek,
    PregnancyWeekGuidance? guidance,
    bool? isLoading,
    String? error,
  }) {
    return PregnancyState(
      currentWeek: currentWeek ?? this.currentWeek,
      guidance: guidance ?? this.guidance,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class PregnancyNotifier extends StateNotifier<PregnancyState> {
  PregnancyNotifier() : super(const PregnancyState());

  /// Load guidance for [week]. Calculates week from [dueDate] if provided.
  Future<void> loadWeek(int week) async {
    final w = week.clamp(1, 40);
    state = state.copyWith(currentWeek: w, isLoading: true, error: null);

    try {
      final guidance = await PregnancyGuidanceService.getGuidance(w);
      state = state.copyWith(guidance: guidance, isLoading: false);
      // Pre-fetch neighbours in background
      PregnancyGuidanceService.prefetchAround(w);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Calculate pregnancy week from due date and load it.
  /// Due date = LMP + 280 days, so LMP = dueDate - 280 days.
  Future<void> loadFromDueDate(DateTime dueDate) async {
    final lmp = dueDate.subtract(const Duration(days: 280));
    final daysPregnant = DateTime.now().difference(lmp).inDays.clamp(0, 280);
    final week = (daysPregnant / 7).ceil().clamp(1, 40);
    await loadWeek(week);
  }
}

final pregnancyProvider =
    StateNotifierProvider<PregnancyNotifier, PregnancyState>(
  (_) => PregnancyNotifier(),
);
