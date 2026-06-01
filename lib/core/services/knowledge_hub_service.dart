import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/knowledge_resource_model.dart';

class KnowledgeHubService {
  KnowledgeHubService._();

  static final _client = Supabase.instance.client;
  static List<KnowledgeResource>? _cache;

  static Future<List<KnowledgeResource>> fetchResources({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cache != null) return _cache!;

    try {
      final res = await _client
          .from('knowledge_resources')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true)
          .order('title', ascending: true);

      final resources = (res as List)
          .map((row) => KnowledgeResource.fromJson(row as Map<String, dynamic>))
          .toList();

      if (resources.isNotEmpty) {
        _cache = resources;
        return resources;
      }
    } catch (e) {
      debugPrint('[KnowledgeHubService] fetchResources fallback: $e');
    }

    _cache = fallbackKnowledgeResources;
    return fallbackKnowledgeResources;
  }

  static void clearCache() => _cache = null;
}
