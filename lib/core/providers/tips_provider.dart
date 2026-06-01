import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../services/secrets.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class DailyTip {
  final String text;
  final String emoji;
  final String category; // 'nutrition', 'development', 'wellness', 'safety'

  const DailyTip({
    required this.text,
    required this.emoji,
    required this.category,
  });
}

// ── State ─────────────────────────────────────────────────────────────────────

class TipsState {
  final List<DailyTip> tips;
  final bool isLoading;

  const TipsState({this.tips = const [], this.isLoading = false});

  TipsState copyWith({List<DailyTip>? tips, bool? isLoading}) =>
      TipsState(tips: tips ?? this.tips, isLoading: isLoading ?? this.isLoading);
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class TipsNotifier extends StateNotifier<TipsState> {
  TipsNotifier() : super(const TipsState());

  static const _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';

  Future<void> loadTips({required int ageInMonths, bool isPregnant = false, int pregnancyWeek = 1}) async {
    // Return cached tips if already loaded
    if (state.tips.isNotEmpty) return;

    state = state.copyWith(isLoading: true);

    final context = isPregnant
        ? 'a pregnant woman at week $pregnancyWeek of pregnancy'
        : 'a parent with a baby aged $ageInMonths months';

    final prompt = '''
Generate 3 helpful, practical daily tips for $context.
Return ONLY a valid JSON array with exactly 3 objects. No markdown, no explanation.
Each object must have: "text" (1-2 sentences, practical tip), "emoji" (single relevant emoji), "category" (one of: nutrition, development, wellness, safety).
Example: [{"text":"Tummy time for 5 minutes helps strengthen neck muscles.","emoji":"💪","category":"development"}]
''';

    try {
      final response = await http.post(
        Uri.parse(_groqUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Secrets.groqApiKey}',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'system', 'content': 'You respond with valid JSON only.'},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.8,
          'max_tokens': 512,
          'response_format': {'type': 'json_object'},
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final content = (decoded['choices'] as List)[0]['message']['content'] as String;
        final obj = jsonDecode(content) as Map<String, dynamic>;
        // Find the array key
        final arrayKey = obj.keys.firstWhere(
          (k) => obj[k] is List,
          orElse: () => '',
        );
        if (arrayKey.isNotEmpty) {
          final list = obj[arrayKey] as List;
          final tips = list.map((t) {
            final m = t as Map<String, dynamic>;
            return DailyTip(
              text: m['text'] as String? ?? '',
              emoji: m['emoji'] as String? ?? '💡',
              category: m['category'] as String? ?? 'wellness',
            );
          }).toList();
          state = state.copyWith(tips: tips, isLoading: false);
          return;
        }
      }
    } catch (e) {
      debugPrint('[TipsProvider] Failed to load AI tips: $e');
    }

    // Fallback to static tips
    state = state.copyWith(
      tips: isPregnant ? _pregnancyFallback(pregnancyWeek) : _parentFallback(ageInMonths),
      isLoading: false,
    );
  }

  List<DailyTip> _parentFallback(int months) => [
    DailyTip(
      text: months < 6
          ? 'Tummy time for 5 minutes helps strengthen your baby\'s neck and shoulder muscles.'
          : months < 12
              ? 'Introduce one new food at a time and wait 2–3 days to check for allergies.'
              : 'Reading to your baby every day builds language skills and strengthens your bond.',
      emoji: '💡',
      category: 'development',
    ),
    DailyTip(
      text: 'Skin-to-skin contact releases oxytocin and helps regulate your baby\'s temperature and heart rate.',
      emoji: '🤱',
      category: 'wellness',
    ),
    DailyTip(
      text: 'Respond to your baby\'s cries promptly — you cannot spoil a baby under 6 months.',
      emoji: '💜',
      category: 'development',
    ),
  ];

  List<DailyTip> _pregnancyFallback(int week) => [
    DailyTip(
      text: 'Stay hydrated — aim for 8–10 glasses of water daily to support amniotic fluid levels.',
      emoji: '💧',
      category: 'nutrition',
    ),
    DailyTip(
      text: 'Gentle walking for 20–30 minutes daily can ease pregnancy discomfort and boost mood.',
      emoji: '🚶',
      category: 'wellness',
    ),
    DailyTip(
      text: week < 13
          ? 'Folic acid in the first trimester is essential for your baby\'s neural tube development.'
          : 'Iron-rich foods like lentils and leafy greens help prevent anaemia during pregnancy.',
      emoji: '🥗',
      category: 'nutrition',
    ),
  ];
}

final tipsProvider = StateNotifierProvider<TipsNotifier, TipsState>(
  (_) => TipsNotifier(),
);
