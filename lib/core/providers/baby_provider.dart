import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../../models/baby_model.dart';

// ── Baby state ────────────────────────────────────────────────────────────────

class BabyState {
  final BabyModel? baby;
  final bool isLoading;
  final bool hasChecked; // true once we've queried the DB at least once
  final String? error;

  const BabyState({
    this.baby,
    this.isLoading = false,
    this.hasChecked = false,
    this.error,
  });

  bool get hasBaby => baby != null;

  BabyState copyWith({
    BabyModel? baby,
    bool? isLoading,
    bool? hasChecked,
    String? error,
  }) {
    return BabyState(
      baby: baby ?? this.baby,
      isLoading: isLoading ?? this.isLoading,
      hasChecked: hasChecked ?? this.hasChecked,
      error: error ?? this.error,
    );
  }
}

// ── Baby notifier ─────────────────────────────────────────────────────────────

class BabyNotifier extends StateNotifier<BabyState> {
  BabyNotifier() : super(const BabyState());

  /// Fetch the first baby for the current user from Supabase.
  Future<void> loadBaby() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final babies = await SupabaseService.fetchBabies(user.id);
      if (babies.isNotEmpty) {
        state = state.copyWith(
          baby: _fromMap(babies.first),
          isLoading: false,
          hasChecked: true,
        );
      } else {
        state = state.copyWith(baby: null, isLoading: false, hasChecked: true);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasChecked: true,
        error: e.toString(),
      );
    }
  }

  /// Save a new baby to Supabase and update local state.
  Future<bool> createBaby({
    required String name,
    required DateTime birthDate,
    required String gender,
    double? heightCm,
    double? weightKg,
    String? photoUrl,
    bool isDueDate = false,
    DateTime? dueDate,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    state = state.copyWith(isLoading: true);
    try {
      // For pregnant users, store due_date in the babies table
      final insertData = {
        'user_id': user.id,
        'name': name,
        if (!isDueDate)
          'birth_date': birthDate.toIso8601String().split('T').first,
        'gender': gender,
        if (heightCm != null) 'height_cm': heightCm,
        if (weightKg != null) 'weight_kg': weightKg,
        if (dueDate != null)
          'due_date': dueDate.toIso8601String().split('T').first,
      };

      final res = await Supabase.instance.client
          .from('babies')
          .insert(insertData)
          .select()
          .single();

      state = state.copyWith(
        baby: _fromMap(res),
        isLoading: false,
        hasChecked: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Update the current baby's details.
  Future<void> updateBaby(BabyModel updated) async {
    state = state.copyWith(baby: updated);
  }

  void clear() {
    state = const BabyState();
  }

  BabyModel _fromMap(Map<String, dynamic> map) {
    final dueDate = map['due_date'] != null
        ? DateTime.parse(map['due_date'] as String)
        : null;
    final rawBirthDate = map['birth_date'] != null
        ? DateTime.parse(map['birth_date'] as String)
        : null;
    final birthDate =
        dueDate != null &&
            rawBirthDate != null &&
            !rawBirthDate.isBefore(DateTime.now())
        ? null
        : rawBirthDate;

    return BabyModel(
      id: map['id'] as String,
      name: map['name'] as String? ?? 'My Baby',
      birthDate: birthDate,
      gender: map['gender'] as String? ?? 'girl',
      heightCm: (map['height_cm'] as num?)?.toDouble(),
      weightKg: (map['weight_kg'] as num?)?.toDouble(),
      photoUrl: map['photo_url'] as String?,
      dueDate: dueDate,
    );
  }
}

final babyProvider = StateNotifierProvider<BabyNotifier, BabyState>(
  (_) => BabyNotifier(),
);

/// Convenience: just the BabyModel or null
final currentBabyProvider = Provider<BabyModel?>((ref) {
  return ref.watch(babyProvider).baby;
});
