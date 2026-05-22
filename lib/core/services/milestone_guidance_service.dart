import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/milestone_model.dart';
import '../../models/milestone_library.dart';

/// Fetches milestone guidance from Supabase.
/// Falls back to the local Dart library if offline or table is empty.
class MilestoneGuidanceService {
  MilestoneGuidanceService._();

  static final _client = Supabase.instance.client;

  // In-memory cache: audience:bandIndex → list of 6 CategoryGuidance objects
  static final Map<String, List<CategoryGuidance>> _cache = {};

  /// Returns guidance for [bandIndex], from cache → Supabase → local library.
  static Future<List<CategoryGuidance>> getGuidance(
    int bandIndex, {
    String audience = 'parent',
  }) async {
    final cacheKey = '$audience:$bandIndex';

    // 1. Return from cache if available
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    // 2. Try Supabase
    try {
      final rows = await _client
          .from('milestone_guidance')
          .select()
          .eq('audience', audience)
          .eq('band_index', bandIndex)
          .order('category');

      if ((rows as List).isNotEmpty) {
        final guidance = (rows as List)
            .map((r) => CategoryGuidance.fromJson(r as Map<String, dynamic>))
            .toList();
        _cache[cacheKey] = guidance;
        return guidance;
      }
    } catch (e) {
      debugPrint('[MilestoneGuidanceService] Supabase fetch failed: $e');
    }

    // 3. Fall back to local Dart library
    final fallback = guidanceForAgeBand(bandIndex);
    _cache[cacheKey] = fallback;
    return fallback;
  }

  /// Clears the in-memory cache (call after content updates).
  static void clearCache() => _cache.clear();

  /// Seeds one age band into Supabase and updates the in-memory cache.
  static Future<int> seedBand(
    int bandIndex, {
    String audience = 'parent',
  }) async {
    final guidance = guidanceForAgeBand(bandIndex);
    for (final g in guidance) {
      await _client.from('milestone_guidance').upsert({
        ...g.toJson(),
        'audience': audience,
      }, onConflict: 'audience,band_index,category');
    }
    _cache['$audience:$bandIndex'] = guidance;
    return guidance.length;
  }

  /// Seeds the Supabase table with all local library data.
  /// Call this once from a dev/admin screen or a one-time migration script.
  static Future<void> seedFromLibrary() async {
    debugPrint(
      '[MilestoneGuidanceService] Seeding Supabase from local library...',
    );
    int count = 0;
    for (int band = 0; band < 19; band++) {
      try {
        count += await seedBand(band);
      } catch (e) {
        debugPrint('[MilestoneGuidanceService] Failed to seed band=$band: $e');
      }
    }
    debugPrint('[MilestoneGuidanceService] Seeded $count rows.');
  }
}
