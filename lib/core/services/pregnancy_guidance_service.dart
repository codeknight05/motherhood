import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model for one week of pregnancy guidance fetched from Supabase.
class PregnancyWeekGuidance {
  final int week;
  final String babyThisWeek;
  final String yourBodyThisWeek;
  final String symptomsAndChanges;
  final String nutritionGuide;
  final String selfcareActivities;
  final String emotionalWellness;
  final String whatsUsuallyNormal;
  final String checklistThisWeek;
  final String whenToContactDoctor;
  final String partnerSupport;
  final String weeklyEncouragement;

  // Baby size fields (may be null for early weeks)
  final String? babySizeEmoji;
  final String? babySizeObject;
  final double? babyLengthCm;
  final double? babyWeightG;

  const PregnancyWeekGuidance({
    required this.week,
    required this.babyThisWeek,
    required this.yourBodyThisWeek,
    required this.symptomsAndChanges,
    required this.nutritionGuide,
    required this.selfcareActivities,
    required this.emotionalWellness,
    required this.whatsUsuallyNormal,
    required this.checklistThisWeek,
    required this.whenToContactDoctor,
    required this.partnerSupport,
    required this.weeklyEncouragement,
    this.babySizeEmoji,
    this.babySizeObject,
    this.babyLengthCm,
    this.babyWeightG,
  });

  factory PregnancyWeekGuidance.fromJson(Map<String, dynamic> json) {
    return PregnancyWeekGuidance(
      week: json['week'] as int,
      babyThisWeek: json['baby_this_week'] as String? ?? '',
      yourBodyThisWeek: json['your_body_this_week'] as String? ?? '',
      symptomsAndChanges: json['symptoms_and_changes'] as String? ?? '',
      nutritionGuide: json['nutrition_guide'] as String? ?? '',
      selfcareActivities: json['selfcare_activities'] as String? ?? '',
      emotionalWellness: json['emotional_wellness'] as String? ?? '',
      whatsUsuallyNormal: json['whats_usually_normal'] as String? ?? '',
      checklistThisWeek: json['checklist_this_week'] as String? ?? '',
      whenToContactDoctor: json['when_to_contact_doctor'] as String? ?? '',
      partnerSupport: json['partner_support'] as String? ?? '',
      weeklyEncouragement: json['weekly_encouragement'] as String? ?? '',
      babySizeEmoji: json['baby_size_emoji'] as String?,
      babySizeObject: json['baby_size_object'] as String?,
      babyLengthCm: (json['baby_length_cm'] as num?)?.toDouble(),
      babyWeightG: (json['baby_weight_g'] as num?)?.toDouble(),
    );
  }
}

/// Fetches pregnancy guidance from Supabase `pregnancy_guidance` table.
class PregnancyGuidanceService {
  PregnancyGuidanceService._();

  static final _client = Supabase.instance.client;

  // In-memory cache: week → guidance
  static final Map<int, PregnancyWeekGuidance> _cache = {};

  /// Returns guidance for [week] (1–40), from cache → Supabase.
  static Future<PregnancyWeekGuidance?> getGuidance(int week) async {
    final w = week.clamp(1, 40);

    if (_cache.containsKey(w)) return _cache[w];

    try {
      final row = await _client
          .from('pregnancy_guidance')
          .select()
          .eq('week', w)
          .maybeSingle();

      if (row != null) {
        final guidance = PregnancyWeekGuidance.fromJson(row);
        _cache[w] = guidance;
        return guidance;
      }
    } catch (e) {
      debugPrint('[PregnancyGuidanceService] Supabase fetch failed: $e');
    }

    return null;
  }

  /// Pre-fetches adjacent weeks (current ± 1) for smooth navigation.
  static Future<void> prefetchAround(int week) async {
    final weeks = [week - 1, week, week + 1].where((w) => w >= 1 && w <= 40);
    await Future.wait(weeks.map(getGuidance));
  }

  static void clearCache() => _cache.clear();
}
