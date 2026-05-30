import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'secrets.dart';

/// AI Recipe Service — uses Groq (free tier: 30 RPM, 14,400 RPD).
/// Model: llama-3.3-70b-versatile — excellent at structured JSON output.
/// Groq API is OpenAI-compatible, extremely fast (~300 tokens/sec).
class GeminiService {
  GeminiService._();

  static const String _groqUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  /// Generate [count] AI recipes for a baby of [ageInMonths].
  static Future<List<Map<String, dynamic>>> generateRecipes({
    required int ageInMonths,
    int count = 5,
    String? focus,
  }) async {
    final ageLabel = _ageLabel(ageInMonths);
    final focusLine = focus != null ? 'Focus theme: $focus.' : '';

    final systemPrompt =
        'You are a certified paediatric nutritionist. '
        'You always respond with valid JSON only — no markdown, no explanation, no code fences. '
        'Just the raw JSON array starting with [ and ending with ].';

    final userPrompt = '''
Generate $count innovative, nutritious, and delicious baby food recipes for a $ageLabel old baby ($ageInMonths months).
$focusLine

Each recipe must be age-appropriate, made with easily available Indian ingredients.

Return ONLY a valid JSON array with exactly $count objects. No markdown, no explanation, no code fences.

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

    final url = Uri.parse(_groqUrl);
    final body = jsonEncode({
      'model': _model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPrompt},
      ],
      'temperature': 0.7,
      'max_tokens': 4096,
      // Ask Groq for JSON output mode
      'response_format': {'type': 'json_object'},
    });

    debugPrint('[GroqAI] Requesting $count recipes for $ageInMonths months');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${Secrets.groqApiKey}',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 45));

      debugPrint('[GroqAI] HTTP status: ${response.statusCode}');

      if (response.statusCode != 200) {
        final errorBody = response.body.length > 400
            ? response.body.substring(0, 400)
            : response.body;
        debugPrint('[GroqAI] Error body: $errorBody');
        throw Exception('Groq API error ${response.statusCode}: $errorBody');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = decoded['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw Exception('No choices in Groq response');
      }

      final message = choices[0]['message'] as Map<String, dynamic>;
      String text = (message['content'] as String).trim();

      debugPrint('[GroqAI] Response length: ${text.length}');
      debugPrint('[GroqAI] First 200 chars: ${text.substring(0, text.length.clamp(0, 200))}');

      // json_object mode wraps in an object — unwrap if needed
      // e.g. {"recipes": [...]} or just [...]
      String cleaned = text;
      if (cleaned.contains('```')) {
        cleaned = cleaned
            .replaceAll(RegExp(r'```json\s*'), '')
            .replaceAll(RegExp(r'```\s*'), '')
            .trim();
      }

      // Try to find a JSON array first
      final startIdx = cleaned.indexOf('[');
      final endIdx = cleaned.lastIndexOf(']');

      if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
        // Direct array
        cleaned = cleaned.substring(startIdx, endIdx + 1);
      } else {
        // json_object mode — look for a key containing the array
        final obj = jsonDecode(cleaned) as Map<String, dynamic>;
        final arrayKey = obj.keys.firstWhere(
          (k) => obj[k] is List,
          orElse: () => '',
        );
        if (arrayKey.isEmpty) {
          throw Exception('Could not find recipe array in response: $cleaned');
        }
        return (obj[arrayKey] as List).cast<Map<String, dynamic>>();
      }

      final list = jsonDecode(cleaned) as List<dynamic>;
      debugPrint('[GroqAI] Successfully parsed ${list.length} recipes');
      return list.cast<Map<String, dynamic>>();
    } catch (e, stack) {
      debugPrint('[GroqAI] ERROR: $e');
      debugPrint('[GroqAI] Stack: $stack');
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
