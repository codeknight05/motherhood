import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Safely converts a DB value to a plain String.
/// Handles: `String`, `List<dynamic>` (JSON array → bullet lines), null.
String _asText(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is List) {
    return value.map((e) => '- ${e.toString().trim()}').join('\n');
  }
  return value.toString();
}

// ── Model ─────────────────────────────────────────────────────────────────────

/// One week of pregnancy guidance fetched from Supabase.
class PregnancyWeekGuidance {
  final int week;

  // 11 content sections
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

  // Baby size fields
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
    // The DB schema uses different column names than the raw data format.
    // Some columns are plain text, others are JSON arrays — _asText handles both.
    return PregnancyWeekGuidance(
      week: json['week'] as int,

      // Plain text columns
      babyThisWeek: _asText(
        json['baby_this_week'] ?? json['baby_this_week'],
      ),
      yourBodyThisWeek: _asText(
        json['your_body_this_week'] ?? json['your_body'],
      ),
      emotionalWellness: _asText(
        json['emotional_wellness'] ?? json['emotional_wellness'],
      ),
      weeklyEncouragement: _asText(
        json['weekly_encouragement'] ?? json['encouragement'],
      ),
      partnerSupport: _asText(
        json['partner_support'],
      ),

      // Columns that may be JSON arrays
      symptomsAndChanges: _asText(
        json['symptoms_and_changes'] ?? json['symptoms'],
      ),
      nutritionGuide: _buildNutrition(json),
      selfcareActivities: _buildSelfcare(json),
      whatsUsuallyNormal: _asText(
        json['whats_usually_normal'] ?? json['whats_normal'],
      ),
      checklistThisWeek: _asText(
        json['checklist_this_week'] ?? json['checklist'],
      ),
      whenToContactDoctor: _asText(
        json['when_to_contact_doctor'] ?? json['contact_doctor'],
      ),

      // Size fields
      babySizeEmoji: json['baby_size_emoji'] as String?,
      babySizeObject: json['baby_size_object'] as String?,
      babyLengthCm: (json['baby_length_cm'] as num?)?.toDouble(),
      babyWeightG: (json['baby_weight_g'] as num?)?.toDouble(),
    );
  }

  /// Combines important_nutrients + helpful_foods + things_to_limit into one
  /// readable nutrition section.
  static String _buildNutrition(Map<String, dynamic> json) {
    // If the new unified column exists, use it directly
    if (json['nutrition_guide'] != null) {
      return _asText(json['nutrition_guide']);
    }

    final parts = <String>[];

    final nutrients = json['important_nutrients'];
    if (nutrients != null) {
      parts.add('Important Nutrients:');
      parts.add(_asText(nutrients));
    }

    final foods = json['helpful_foods'];
    if (foods != null) {
      parts.add('\nHelpful Foods:');
      parts.add(_asText(foods));
    }

    final limit = json['things_to_limit'];
    if (limit != null) {
      parts.add('\nThings To Limit:');
      parts.add(_asText(limit));
    }

    return parts.join('\n');
  }

  /// Combines helpful_practices + good_habits into one self-care section.
  static String _buildSelfcare(Map<String, dynamic> json) {
    if (json['selfcare_activities'] != null) {
      return _asText(json['selfcare_activities']);
    }

    final parts = <String>[];

    final practices = json['helpful_practices'];
    if (practices != null) {
      parts.add('Helpful Practices:');
      parts.add(_asText(practices));
    }

    final habits = json['good_habits'];
    if (habits != null) {
      parts.add('\nGood Habits To Start:');
      parts.add(_asText(habits));
    }

    return parts.join('\n');
  }
}

// ── Service ───────────────────────────────────────────────────────────────────

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
