import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

// ── Article section types ─────────────────────────────────────────────────────

enum ArticleSectionType { text, bulletList }

class ArticleSection {
  final int number;
  final String title;
  final String? body;
  final List<String> bullets;
  final ArticleSectionType type;
  final String emoji;
  final Color color;
  final Color colorLight;

  const ArticleSection({
    required this.number,
    required this.title,
    this.body,
    this.bullets = const [],
    this.type = ArticleSectionType.text,
    this.emoji = '💡',
    required this.color,
    required this.colorLight,
  });
}

// ── Article model ─────────────────────────────────────────────────────────────

class ArticleModel {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String secondaryCategory;
  final Color categoryColor;
  final String imageUrl;
  final String readTime;
  final String updatedLabel;
  final List<ArticleSection> sections;
  final String rememberText;
  final int helpfulCount;

  const ArticleModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.secondaryCategory = '',
    required this.categoryColor,
    required this.imageUrl,
    required this.readTime,
    this.updatedLabel = 'Updated today',
    required this.sections,
    required this.rememberText,
    this.helpfulCount = 0,
  });
}

// ── Sample articles ───────────────────────────────────────────────────────────

final sampleArticles = <ArticleModel>[
  ArticleModel(
    id: 'toddler_tantrums',
    title: 'How to manage toddler tantrums with calm',
    subtitle: 'Tantrums are normal! Learn calm, effective ways to handle big emotions and help your toddler feel understood.',
    category: 'Toddler',
    secondaryCategory: 'Behavior',
    categoryColor: AppColors.accentOrange,
    imageUrl: 'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=600',
    readTime: '6 min read',
    updatedLabel: 'Updated today',
    helpfulCount: 34,
    rememberText: 'Tantrums are not bad behavior.\nThey are big feelings your toddler needs help managing.',
    sections: [
      ArticleSection(
        number: 1, title: 'Why do toddlers have tantrums?',
        body: 'Toddlers have big feelings but limited words. Tantrums are their way of expressing frustration, fatigue, hunger, or when they feel something is unfair.',
        emoji: '🧠', color: AppColors.primary, colorLight: AppColors.primaryLight,
      ),
      ArticleSection(
        number: 2, title: 'Stay calm first',
        body: 'Your calm helps your child calm down. Take a deep breath, remind yourself it\'s a phase, and respond — don\'t react.',
        emoji: '🫁', color: AppColors.accentPink, colorLight: AppColors.accentPinkLight,
      ),
      ArticleSection(
        number: 3, title: 'What you can do',
        type: ArticleSectionType.bulletList,
        bullets: [
          'Get down to their level and acknowledge their feelings.',
          'Use short, simple and calm words.',
          'Offer choices whenever possible.',
          'Distract gently if they are overwhelmed.',
          'Comfort after the storm.',
        ],
        emoji: '🤗', color: AppColors.accentOrange, colorLight: AppColors.accentOrangeLight,
      ),
      ArticleSection(
        number: 4, title: 'What to avoid',
        type: ArticleSectionType.bulletList,
        bullets: [
          'Shouting or raising your voice',
          'Giving in to stop the tantrum',
          'Comparing with other children',
          'Ignoring for too long',
        ],
        emoji: '🚫', color: AppColors.error, colorLight: Color(0xFFFFEBEE),
      ),
      ArticleSection(
        number: 5, title: 'When to seek help',
        body: 'If tantrums are very frequent, intense, or affecting daily life, it\'s always good to talk to your pediatrician.',
        emoji: '👩‍⚕️', color: AppColors.accentGreen, colorLight: AppColors.accentGreenLight,
      ),
    ],
  ),
  ArticleModel(
    id: 'umbilical_cord',
    title: 'Umbilical Cord Care: A Complete Guide',
    subtitle: 'Learn how to keep your baby\'s navel clean and prevent infections during the first weeks.',
    category: 'Newborn Care',
    categoryColor: AppColors.accentOrange,
    imageUrl: 'https://images.unsplash.com/photo-1519340241574-2cec6aef0c01?w=600',
    readTime: '5 min read',
    helpfulCount: 52,
    rememberText: 'The cord stump will fall off on its own in 1-3 weeks.\nNever pull it — let it dry and detach naturally.',
    sections: [
      ArticleSection(number: 1, title: 'What is the umbilical cord stump?', body: 'After birth, a small stump of the umbilical cord remains attached to your baby\'s belly button. It will dry out and fall off within 1-3 weeks.', emoji: '🍼', color: AppColors.accentOrange, colorLight: AppColors.accentOrangeLight),
      ArticleSection(number: 2, title: 'How to clean it', type: ArticleSectionType.bulletList, bullets: ['Keep it dry and clean.', 'Fold the nappy below the stump.', 'Sponge bathe only until it falls off.', 'Let air reach it as much as possible.'], emoji: '🧼', color: AppColors.accentBlue, colorLight: AppColors.accentBlueLight),
      ArticleSection(number: 3, title: 'Signs of infection', type: ArticleSectionType.bulletList, bullets: ['Redness or swelling around the base.', 'Yellow or green discharge.', 'Foul smell.', 'Baby seems in pain when you touch it.'], emoji: '⚠️', color: AppColors.error, colorLight: Color(0xFFFFEBEE)),
      ArticleSection(number: 4, title: 'When to call your doctor', body: 'If you notice any signs of infection, or if the stump hasn\'t fallen off after 3 weeks, contact your paediatrician.', emoji: '👩‍⚕️', color: AppColors.accentGreen, colorLight: AppColors.accentGreenLight),
    ],
  ),
  ArticleModel(
    id: 'baby_sleep',
    title: 'How to Improve Baby Sleep Naturally',
    subtitle: 'Simple tips and routines to help your baby sleep better at night without sleep training.',
    category: 'Sleep',
    categoryColor: AppColors.primary,
    imageUrl: 'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=600',
    readTime: '7 min read',
    helpfulCount: 89,
    rememberText: 'Every baby is different.\nWhat works for one may not work for another — be patient with yourself.',
    sections: [
      ArticleSection(number: 1, title: 'Why babies wake at night', body: 'Babies have shorter sleep cycles than adults and naturally wake between cycles. This is normal and not a problem to be fixed.', emoji: '🌙', color: AppColors.primary, colorLight: AppColors.primaryLight),
      ArticleSection(number: 2, title: 'Create a bedtime routine', type: ArticleSectionType.bulletList, bullets: ['Bath, feed, book, song — in the same order.', 'Keep it to 20-30 minutes.', 'Same time every night.', 'Dim lights and reduce noise.'], emoji: '🛁', color: AppColors.accentBlue, colorLight: AppColors.accentBlueLight),
      ArticleSection(number: 3, title: 'Drowsy but awake', body: 'Put baby down when drowsy but still awake. This teaches them to fall asleep independently, which means they can resettle themselves when they wake.', emoji: '😴', color: AppColors.accentPink, colorLight: AppColors.accentPinkLight),
      ArticleSection(number: 4, title: 'Watch for tired cues', type: ArticleSectionType.bulletList, bullets: ['Yawning', 'Rubbing eyes', 'Looking away or losing interest', 'Fussiness'], emoji: '👀', color: AppColors.accentOrange, colorLight: AppColors.accentOrangeLight),
      ArticleSection(number: 5, title: 'When to seek help', body: 'If sleep problems are significantly affecting your family\'s wellbeing, speak to your health visitor or paediatrician about sleep support options.', emoji: '👩‍⚕️', color: AppColors.accentGreen, colorLight: AppColors.accentGreenLight),
    ],
  ),
  ArticleModel(
    id: 'toddler_breakfast',
    title: '9 Healthy Breakfast Ideas for Toddlers',
    subtitle: 'Nutritious, quick and easy breakfast recipes your toddler will love.',
    category: 'Nutrition',
    categoryColor: AppColors.accentGreen,
    imageUrl: 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=600',
    readTime: '6 min read',
    helpfulCount: 61,
    rememberText: 'Toddlers need variety, not perfection.\nOffer new foods alongside accepted ones — it takes 10-15 tries.',
    sections: [
      ArticleSection(number: 1, title: 'Why breakfast matters for toddlers', body: 'After a night\'s sleep, toddlers need fuel for their growing brains and bodies. A good breakfast sets the tone for the whole day.', emoji: '🌅', color: AppColors.accentOrange, colorLight: AppColors.accentOrangeLight),
      ArticleSection(number: 2, title: 'Quick and easy ideas', type: ArticleSectionType.bulletList, bullets: ['Banana oat pancakes', 'Scrambled eggs with toast soldiers', 'Greek yoghurt with berries', 'Avocado on wholegrain toast', 'Porridge with fruit and nut butter', 'Cheese and veggie omelette', 'Smoothie bowl with granola', 'Whole grain cereal with milk', 'Mini vegetable frittatas'], emoji: '🥞', color: AppColors.accentGreen, colorLight: AppColors.accentGreenLight),
      ArticleSection(number: 3, title: 'What to include', type: ArticleSectionType.bulletList, bullets: ['Protein (eggs, yoghurt, nut butter)', 'Whole grains (oats, wholegrain bread)', 'Fruit or vegetables', 'Healthy fats (avocado, nuts)'], emoji: '🥗', color: AppColors.accentBlue, colorLight: AppColors.accentBlueLight),
      ArticleSection(number: 4, title: 'What to limit', type: ArticleSectionType.bulletList, bullets: ['Added sugar (sweetened cereals, flavoured yoghurt)', 'Processed meats', 'Fruit juice (offer whole fruit instead)', 'White bread and refined grains'], emoji: '⚠️', color: AppColors.error, colorLight: Color(0xFFFFEBEE)),
    ],
  ),
];

/// Returns the article matching a title, or null.
ArticleModel? articleForTitle(String title) {
  try {
    return sampleArticles.firstWhere(
      (a) => a.title.toLowerCase() == title.toLowerCase(),
    );
  } catch (_) {
    return null;
  }
}
