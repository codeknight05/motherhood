import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../services/secrets.dart';
import '../theme/app_colors.dart';
import '../../models/article_model.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class DailyTip {
  final String title;
  final String text;
  final String emoji;
  final String category; // 'nutrition', 'development', 'wellness', 'safety'

  const DailyTip({
    required this.title,
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
Each object must have: "title" (2-4 words catchphrase title), "text" (1-2 sentences, practical tip), "emoji" (single relevant emoji), "category" (one of: nutrition, development, wellness, safety).
Example: [{"title":"Tummy Time","text":"Tummy time for 5 minutes helps strengthen neck muscles.","emoji":"💪","category":"development"}]
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
              title: m['title'] as String? ?? 'Daily Tip',
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'nutrition':
        return AppColors.accentGreen;
      case 'development':
        return AppColors.primary;
      case 'wellness':
        return AppColors.accentPink;
      case 'safety':
        return AppColors.accentOrange;
      default:
        return AppColors.primary;
    }
  }

  Color _getCategoryColorLight(String category) {
    switch (category.toLowerCase()) {
      case 'nutrition':
        return AppColors.accentGreenLight;
      case 'development':
        return AppColors.primaryLight;
      case 'wellness':
        return AppColors.accentPinkLight;
      case 'safety':
        return AppColors.accentOrangeLight;
      default:
        return AppColors.primaryLight;
    }
  }

  String _getCategoryImage(String category) {
    switch (category.toLowerCase()) {
      case 'nutrition':
        return 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=600';
      case 'development':
        return 'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=600';
      case 'wellness':
        return 'https://images.unsplash.com/photo-1519340241574-2cec6aef0c01?w=600';
      case 'safety':
        return 'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=600';
      default:
        return 'https://images.unsplash.com/photo-1519340241574-2cec6aef0c01?w=600';
    }
  }

  Future<ArticleModel> generateArticleForTip(DailyTip tip) async {
    final prompt = '''
Generate a comprehensive, engaging parenting/maternal article based on this tip: "${tip.text}".
Return ONLY a valid JSON object matching the following structure. No markdown, no wrapper, no explanation.
{
  "title": "Short, catchy title related to the tip (max 8 words)",
  "subtitle": "An interesting 1-sentence summary/hook",
  "readTime": "3 min read",
  "rememberText": "A powerful 1-2 sentence key takeaway for the parent",
  "sections": [
    {
      "number": 1,
      "title": "Short section header explaining why this is important",
      "body": "Detailed paragraph explaining the science/reasoning behind this tip (3-4 sentences)",
      "type": "text",
      "emoji": "💡"
    },
    {
      "number": 2,
      "title": "Practical Steps",
      "bullets": [
        "First practical action item (1 sentence)",
        "Second practical action item (1 sentence)",
        "Third practical action item (1 sentence)",
        "Fourth practical action item (1 sentence)"
      ],
      "type": "bulletList",
      "emoji": "🛠️"
    },
    {
      "number": 3,
      "title": "Common Mistakes to Avoid",
      "bullets": [
        "First mistake to avoid",
        "Second mistake to avoid"
      ],
      "type": "bulletList",
      "emoji": "⚠️"
    }
  ]
}
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
          'temperature': 0.7,
          'max_tokens': 1024,
          'response_format': {'type': 'json_object'},
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final content = (decoded['choices'] as List)[0]['message']['content'] as String;
        final obj = jsonDecode(content) as Map<String, dynamic>;

        final sections = (obj['sections'] as List).map((s) {
          final m = s as Map<String, dynamic>;
          final typeStr = m['type'] as String? ?? 'text';
          final type = typeStr == 'bulletList'
              ? ArticleSectionType.bulletList
              : ArticleSectionType.text;

          return ArticleSection(
            number: m['number'] as int? ?? 1,
            title: m['title'] as String? ?? '',
            body: m['body'] as String?,
            bullets: (m['bullets'] as List?)?.map((b) => b as String).toList() ?? const [],
            type: type,
            emoji: m['emoji'] as String? ?? '💡',
            color: _getCategoryColor(tip.category),
            colorLight: _getCategoryColorLight(tip.category),
          );
        }).toList();

        return ArticleModel(
          id: 'ai_article_${tip.category}_${tip.text.hashCode}',
          title: obj['title'] as String? ?? 'Parenting Guide',
          subtitle: obj['subtitle'] as String? ?? tip.text,
          category: tip.category.toUpperCase(),
          categoryColor: _getCategoryColor(tip.category),
          imageUrl: _getCategoryImage(tip.category),
          readTime: obj['readTime'] as String? ?? '3 min read',
          rememberText: obj['rememberText'] as String? ?? 'Every small effort counts in parenting.',
          sections: sections,
        );
      }
    } catch (e) {
      debugPrint('[TipsProvider] Failed to generate AI article: $e');
    }

    return createFallbackArticle(tip);
  }

  ArticleModel createFallbackArticle(DailyTip tip) {
    final catColor = _getCategoryColor(tip.category);
    final catColorLight = _getCategoryColorLight(tip.category);
    final catImage = _getCategoryImage(tip.category);

    List<String> genericBullets = [];
    switch (tip.category.toLowerCase()) {
      case 'nutrition':
        genericBullets = [
          'Introduce new foods slowly and look out for digestive changes.',
          'Focus on whole, nutrient-dense foods customized to baby\'s age.',
          'Keep mealtimes positive and avoid force-feeding.'
        ];
        break;
      case 'development':
        genericBullets = [
          'Give your baby plenty of safe floor play time.',
          'Talk, sing, and read to your baby daily to boost brain development.',
          'Celebrate their unique timeline — all babies grow differently.'
        ];
        break;
      case 'wellness':
        genericBullets = [
          'Ensure routine checkups and immunizations are up to date.',
          'Establish a soothing bedtime routine for healthy sleep.',
          'Trust your maternal instincts — you know your baby best.'
        ];
        break;
      case 'safety':
        genericBullets = [
          'Always supervise your baby during playtime and bathing.',
          'Keep small objects, chemicals, and hot liquids completely out of reach.',
          'Ensure sleeping environments are free of loose bedding.'
        ];
        break;
      default:
        genericBullets = [
          'Take care of yourself — a happy parent makes a happy baby.',
          'Reach out to family or professionals when you need support.',
          'Enjoy these precious moments as they grow.'
        ];
    }

    return ArticleModel(
      id: 'fallback_article_${tip.category}_${tip.text.hashCode}',
      title: 'Guide to Baby ${tip.category[0].toUpperCase()}${tip.category.substring(1)}',
      subtitle: tip.text,
      category: tip.category.toUpperCase(),
      categoryColor: catColor,
      imageUrl: catImage,
      readTime: '2 min read',
      rememberText: 'Every baby progresses at their own pace. Trust the journey.',
      sections: [
        ArticleSection(
          number: 1,
          title: 'Understanding This Advice',
          body: tip.text,
          emoji: tip.emoji,
          color: catColor,
          colorLight: catColorLight,
        ),
        ArticleSection(
          number: 2,
          title: 'Best Practices',
          type: ArticleSectionType.bulletList,
          bullets: genericBullets,
          emoji: '📋',
          color: catColor,
          colorLight: catColorLight,
        ),
      ],
    );
  }

  List<DailyTip> _parentFallback(int months) => [
    DailyTip(
      title: months < 6
          ? 'Tummy Time'
          : months < 12
              ? 'New Foods'
              : 'Daily Reading',
      text: months < 6
          ? 'Tummy time for 5 minutes helps strengthen your baby\'s neck and shoulder muscles.'
          : months < 12
              ? 'Introduce one new food at a time and wait 2–3 days to check for allergies.'
              : 'Reading to your baby every day builds language skills and strengthens your bond.',
      emoji: '💡',
      category: 'development',
    ),
    DailyTip(
      title: 'Skin-to-Skin Bonding',
      text: 'Skin-to-skin contact releases oxytocin and helps regulate your baby\'s temperature and heart rate.',
      emoji: '🤱',
      category: 'wellness',
    ),
    DailyTip(
      title: 'Comforting Baby',
      text: 'Respond to your baby\'s cries promptly — you cannot spoil a baby under 6 months.',
      emoji: '💜',
      category: 'development',
    ),
  ];

  List<DailyTip> _pregnancyFallback(int week) => [
    DailyTip(
      title: 'Hydration Goal',
      text: 'Stay hydrated — aim for 8–10 glasses of water daily to support amniotic fluid levels.',
      emoji: '💧',
      category: 'nutrition',
    ),
    DailyTip(
      title: 'Gentle Movement',
      text: 'Gentle walking for 20–30 minutes daily can ease pregnancy discomfort and boost mood.',
      emoji: '🚶',
      category: 'wellness',
    ),
    DailyTip(
      title: week < 13 ? 'Folic Acid Support' : 'Iron Intake',
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
