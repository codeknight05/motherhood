import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum DietaryPreference {
  both,
  veg,
}

extension DietaryPreferenceExt on DietaryPreference {
  String get label {
    switch (this) {
      case DietaryPreference.both:
        return 'Both Veg & Non-Veg';
      case DietaryPreference.veg:
        return 'Veg Only';
    }
  }

  String get dbValue {
    switch (this) {
      case DietaryPreference.both:
        return 'both';
      case DietaryPreference.veg:
        return 'veg';
    }
  }
}

class DietaryPreferenceNotifier extends StateNotifier<DietaryPreference> {
  static const _storage = FlutterSecureStorage();
  static const _key = 'dietary_preference';

  DietaryPreferenceNotifier() : super(DietaryPreference.both) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      final val = await _storage.read(key: _key);
      if (val == 'veg') {
        state = DietaryPreference.veg;
      } else {
        state = DietaryPreference.both;
      }
    } catch (_) {
      // Fallback to both
    }
  }

  Future<void> setPreference(DietaryPreference preference) async {
    state = preference;
    try {
      await _storage.write(key: _key, value: preference.dbValue);
    } catch (_) {}
  }
}

final dietaryPreferenceProvider =
    StateNotifierProvider<DietaryPreferenceNotifier, DietaryPreference>((ref) {
  return DietaryPreferenceNotifier();
});
