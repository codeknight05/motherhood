import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/milestone_model.dart';

// ── Milestone state ───────────────────────────────────────────────────────────

class MilestonesState {
  final List<MilestoneCategoryProgress> categories;
  final bool isLoading;
  final String? error;

  const MilestonesState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  int get totalAchieved => categories.fold(0, (s, c) => s + c.achieved);
  int get totalItems => categories.fold(0, (s, c) => s + c.total);
  int get totalInProgress => categories.fold(0, (s, c) => s + c.inProgress);
  int get totalNotStarted => totalItems - totalAchieved - totalInProgress;
  double get overallPercent => totalItems == 0 ? 0.0 : totalAchieved / totalItems;

  MilestonesState copyWith({
    List<MilestoneCategoryProgress>? categories,
    bool? isLoading,
    String? error,
  }) {
    return MilestonesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ── Milestone notifier ────────────────────────────────────────────────────────

class MilestonesNotifier extends StateNotifier<MilestonesState> {
  MilestonesNotifier() : super(const MilestonesState());

  final _client = Supabase.instance.client;

  /// Load milestones for the given baby from Supabase.
  /// If none exist yet, auto-populate from milestone_definitions.
  Future<void> loadMilestones(String babyId, int ageInMonths) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Check if milestones already exist for this baby
      final existing = await _client
          .from('milestones')
          .select()
          .eq('baby_id', babyId)
          .limit(1);

      if ((existing as List).isEmpty) {
        // First time — auto-populate from definitions
        await _client.rpc('populate_milestones_for_baby', params: {
          'p_baby_id': babyId,
          'p_age_months': ageInMonths,
        });
      }

      // Fetch all milestones for this baby
      final rows = await _client
          .from('milestones')
          .select()
          .eq('baby_id', babyId)
          .order('category')
          .order('created_at');

      final categories = _groupByCategory(rows as List<dynamic>);
      state = state.copyWith(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update a single milestone's status.
  Future<void> updateMilestoneStatus(
    String milestoneId,
    MilestoneStatus newStatus,
  ) async {
    try {
      await _client.from('milestones').update({
        'status': _statusToDb(newStatus),
        if (newStatus == MilestoneStatus.achieved)
          'achieved_at': DateTime.now().toIso8601String().split('T').first,
      }).eq('id', milestoneId);

      // Update local state immediately for instant UI feedback
      final updated = state.categories.map((cat) {
        final updatedItems = cat.items.map((item) {
          if (item.id == milestoneId) {
            return MilestoneItem(
              id: item.id,
              title: item.title,
              category: item.category,
              status: newStatus,
              achievedDate: newStatus == MilestoneStatus.achieved
                  ? DateTime.now().toIso8601String().split('T').first
                  : null,
            );
          }
          return item;
        }).toList();

        final achieved = updatedItems.where((i) => i.status == MilestoneStatus.achieved).length;
        final inProgress = updatedItems.where((i) => i.status == MilestoneStatus.inProgress).length;

        return MilestoneCategoryProgress(
          category: cat.category,
          total: cat.total,
          achieved: achieved,
          inProgress: inProgress,
          items: updatedItems,
        );
      }).toList();

      state = state.copyWith(categories: updated);
    } catch (e) {
      // Silently fail — UI already updated, will sync on next load
    }
  }

  void clear() => state = const MilestonesState();

  // ── Helpers ─────────────────────────────────────────────────────────────────

  List<MilestoneCategoryProgress> _groupByCategory(List<dynamic> rows) {
    final Map<MilestoneCategory, List<MilestoneItem>> grouped = {};

    for (final row in rows) {
      final category = _categoryFromDb(row['category'] as String);
      final item = MilestoneItem(
        id: row['id'] as String,
        title: row['title'] as String,
        category: category,
        status: _statusFromDb(row['status'] as String? ?? 'not_started'),
        achievedDate: row['achieved_at'] as String?,
      );
      grouped.putIfAbsent(category, () => []).add(item);
    }

    // Return in a consistent order
    return MilestoneCategory.values
        .where((c) => grouped.containsKey(c))
        .map((c) {
          final items = grouped[c]!;
          final achieved = items.where((i) => i.status == MilestoneStatus.achieved).length;
          final inProgress = items.where((i) => i.status == MilestoneStatus.inProgress).length;
          return MilestoneCategoryProgress(
            category: c,
            total: items.length,
            achieved: achieved,
            inProgress: inProgress,
            items: items,
          );
        })
        .toList();
  }

  MilestoneCategory _categoryFromDb(String value) {
    switch (value) {
      case 'gross_motor':       return MilestoneCategory.grossMotor;
      case 'fine_motor':        return MilestoneCategory.fineMotor;
      case 'language':          return MilestoneCategory.language;
      case 'social_emotional':  return MilestoneCategory.socialEmotional;
      default:                  return MilestoneCategory.cognitive;
    }
  }

  MilestoneStatus _statusFromDb(String value) {
    switch (value) {
      case 'achieved':    return MilestoneStatus.achieved;
      case 'in_progress': return MilestoneStatus.inProgress;
      default:            return MilestoneStatus.notStarted;
    }
  }

  String _statusToDb(MilestoneStatus status) {
    switch (status) {
      case MilestoneStatus.achieved:    return 'achieved';
      case MilestoneStatus.inProgress:  return 'in_progress';
      case MilestoneStatus.notStarted:  return 'not_started';
    }
  }
}

final milestonesProvider =
    StateNotifierProvider<MilestonesNotifier, MilestonesState>(
  (_) => MilestonesNotifier(),
);
