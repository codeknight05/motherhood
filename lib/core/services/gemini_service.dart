import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'secrets.dart';

/// Gemini REST API service — calls v1 endpoint directly.
/// Avoids the deprecated google_generative_ai SDK which uses v1beta.
class GeminiService {
  GeminiService._();

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  /// Generate [count] AI recipes for a baby of [ageInMonths].
  static Future<List<Map<String, dynamic>>> generateRecipes({
    required int ageInMonths,
    int count = 5,
    String? focus,
  }) async {
    final ageLabel = _ageLabel(ageInMonths);
    final focusLine = focus != null ? 'Focus theme: $focus.' : '';

    final prompt = '''
You are a certified paediatric nutritionist. Generate $count innovative, nutritious, and delicious baby food recipes for a $ageLabel old baby ($ageInMonths months).
$focusLine

Each recipe must be age-appropriate, made with easily available Indian ingredients, nutritious and tasty.

Return ONLY a valid JSON array with exactly $count objects. No markdown, no explanation, no code fences. Just the raw JSON array starting with [ and ending with ].

Each object must have exactly these fields:
{
  "id": "ai_XXXXXX",
  "name": "Recipe Name",
  "description": "2-3 sentence description",
  "cookTimeMinutes": 20,
  "calories": 120,
  "tag": "High Iron",
  "benefit": "Supports brain development",
  "ageGroups": ["$ageLabel"],
  "category": "breakfast",
  "howToServe": "Serve warm. Blend smooth for younger babies.",
  "ingredients": [
    { "name": "Rice", "quantity": "2 tbsp" }
  ],
  "steps": [
    { "stepNumber": 1, "title": "Wash and soak", "description": "Wash rice and soak for 15 minutes." }
  ]
}

category must be one of: breakfast, midMorning, lunch, eveningSnack, dinner, bedtime
''';

    final url = Uri.parse('$_baseUrl?key=${Secrets.geminiApiKey}');

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 4096,
      },
    });

    debugPrint('[Gemini] POST $url');
    debugPrint('[Gemini] Requesting $count recipes for $ageInMonths months, focus: $focus');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 45));

      debugPrint('[Gemini] HTTP status: ${response.statusCode}');

      if (response.statusCode != 200) {
        final errorBody = response.body.length > 300
            ? response.body.substring(0, 300)
            : response.body;
        debugPrint('[Gemini] Error body: $errorBody');
        throw Exception('Gemini API error ${response.statusCode}: $errorBody');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = decoded['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('No candidates in Gemini response');
      }

      final content = candidates[0]['content'] as Map<String, dynamic>;
      final parts = content['parts'] as List<dynamic>;
      final text = (parts[0]['text'] as String).trim();

      debugPrint('[Gemini] Response length: ${text.length}');
      debugPrint('[Gemini] First 200 chars: ${text.substring(0, text.length.clamp(0, 200))}');

      // Extract JSON array — strip any accidental markdown fences
      String cleaned = text;
      if (cleaned.contains('```')) {
        cleaned = cleaned
            .replaceAll(RegExp(r'```json\s*'), '')
            .replaceAll(RegExp(r'```\s*'), '')
            .trim();
      }

      final startIdx = cleaned.indexOf('[');
      final endIdx = cleaned.lastIndexOf(']');
      if (startIdx == -1 || endIdx == -1 || endIdx <= startIdx) {
        debugPrint('[Gemini] Could not find JSON array. Raw: $cleaned');
        throw Exception('Response did not contain a JSON array');
      }
      cleaned = cleaned.substring(startIdx, endIdx + 1);

      final list = jsonDecode(cleaned) as List<dynamic>;
      debugPrint('[Gemini] Successfully parsed ${list.length} recipes');
      return list.cast<Map<String, dynamic>>();
    } catch (e, stack) {
      debugPrint('[Gemini] ERROR: $e');
      debugPrint('[Gemini] Stack: $stack');
      rethrow;
    }
  }

  static String _ageLabel(int months) {
    if (months < 6) return '0-6 months';
    if (months <= 8) return '6-8 months';
    if (months <= 12) return '9-12 months';
    if (months <= 24) return '1-2 years';
    if (months <= 48) return '2-4 years';
    return '4-6 years';
  }
}
