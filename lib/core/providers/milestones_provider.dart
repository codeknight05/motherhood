import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/milestone_model.dart';
import '../../models/milestone_library.dart';
import '../services/milestone_guidance_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class MilestonesState {
  final List<CategoryGuidance> guidance;   // 6 categories for selected age band
  final int selectedBandIndex;
  final bool isLoading;
  final String? error;

  const MilestonesState({
    this.guidance = const [],
    this.selectedBandIndex = 10, // default: 6-9 months
    this.isLoading = false,
    this.error,
  });

  // Backward-compat: home screen ring uses MilestoneCategoryProgress
  List<MilestoneCategoryProgress> get categories =>
      guidance.map(MilestoneCategoryProgress.fromGuidance).toList();

  int get totalAchieved => guidance.fold(0, (s, g) => s + g.achieved);
  int get totalItems    => guidance.fold(0, (s, g) => s + g.totalMilestones);
  int get totalInProgress => guidance.fold(0, (s, g) => s + g.inProgress);
  int get totalNotStarted => totalItems - totalAchieved - totalInProgress;
  double get overallPercent => totalItems == 0 ? 0.0 : totalAchieved / totalItems;

  MilestonesState copyWith({
    List<CategoryGuidance>? guidance,
    int? selectedBandIndex,
    bool? isLoading,
    String? error,
  }) {
    return MilestonesState(
      guidance: guidance ?? this.guidance,
      selectedBandIndex: selectedBandIndex ?? this.selectedBandIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class MilestonesNotifier extends StateNotifier<MilestonesState> {
  MilestonesNotifier() : super(const MilestonesState());

  final _client = Supabase.instance.client;

  /// Load guidance for [bandIndex]. If null, derives from [ageInMonths].
  Future<void> loadMilestones(
    String babyId,
    int ageInMonths, {
    int? bandIndex,
  }) async {
    final band = bandIndex ?? ageBandFromMonths(ageInMonths);
    state = state.copyWith(isLoading: true, error: null, selectedBandIndex: band);

    // 1. Fetch guidance content (Supabase → local library fallback)
    final libraryGuidance = await MilestoneGuidanceService.getGuidance(band);

    try {
      // 2. Fetch user's milestone statuses from Supabase
      final rows = await _client
          .from('milestones')
          .select('title, category, status, achieved_at')
          .eq('baby_id', babyId);

      // Build lookup: title_lower → (status, achievedDate)
      final Map<String, (MilestoneStatus, String?)> statusMap = {};
      for (final row in (rows as List)) {
        final title = (row['title'] as String).toLowerCase();
        final status = _statusFromDb(row['status'] as String? ?? 'not_started');
        final date = row['achieved_at'] as String?;
        statusMap[title] = (status, date);
      }

      // 3. Overlay Supabase statuses onto guidance content
      final enriched = libraryGuidance
          .map((g) => enrichGuidance(g, statusMap))
          .toList();

      state = state.copyWith(guidance: enriched, isLoading: false);
    } catch (e) {
      // Fall back to library defaults on error
      state = state.copyWith(
        guidance: libraryGuidance,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update a single milestone's status (persists to Supabase).
  Future<void> updateMilestoneStatus(
    String milestoneId,
    MilestoneStatus newStatus,
  ) async {
    // Update local state immediately
    final updated = state.guidance.map((g) {
      final idx = g.milestones.indexWhere((m) => m.id == milestoneId);
      if (idx == -1) return g;
      return g.withUpdatedMilestone(milestoneId, newStatus);
    }).toList();
    state = state.copyWith(guidance: updated);

    // Persist to Supabase (best-effort — local state already updated)
    try {
      await _client.from('milestones').upsert({
        'id': milestoneId,
        'status': _statusToDb(newStatus),
        if (newStatus == MilestoneStatus.achieved)
          'achieved_at': DateTime.now().toIso8601String().split('T').first,
      });
    } catch (_) {
      // Silently fail — UI already updated
    }
  }

  void clear() => state = const MilestonesState();

  MilestoneStatus _statusFromDb(String v) {
    switch (v) {
      case 'achieved':    return MilestoneStatus.achieved;
      case 'in_progress': return MilestoneStatus.inProgress;
      default:            return MilestoneStatus.notStarted;
    }
  }

  String _statusToDb(MilestoneStatus s) {
    switch (s) {
      case MilestoneStatus.achieved:   return 'achieved';
      case MilestoneStatus.inProgress: return 'in_progress';
      case MilestoneStatus.notStarted: return 'not_started';
    }
  }
}

final milestonesProvider =
    StateNotifierProvider<MilestonesNotifier, MilestonesState>(
  (_) => MilestonesNotifier(),
);
