import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  static final List<Map<String, dynamic>> _categories = [
    {'label': 'Pregnancy', 'count': '56 Articles', 'emoji': '🤰', 'color': AppColors.accentPinkLight},
    {'label': 'Newborn Care', 'count': '82 Articles', 'emoji': '🍼', 'color': AppColors.accentOrangeLight},
    {'label': 'Feeding & Nutrition', 'count': '71 Articles', 'emoji': '🥗', 'color': AppColors.accentGreenLight},
    {'label': 'Sleep', 'count': '45 Articles', 'emoji': '🌙', 'color': AppColors.primaryLight},
    {'label': 'Child Development', 'count': '67 Articles', 'emoji': '🧠', 'color': AppColors.accentBlueLight},
    {'label': 'Parenting & Wellbeing', 'count': '53 Articles', 'emoji': '💗', 'color': AppColors.accentPinkLight},
  ];

  static final List<Map<String, dynamic>> _featuredArticles = [
    {
      'title': 'Umbilical Cord Care: A Complete Guide',
      'category': 'Newborn Care',
      'categoryColor': AppColors.accentOrange,
      'description': "Learn how to keep your baby's navel clean and prevent infections.",
      'readTime': '5 min read',
      'image': 'https://images.unsplash.com/photo-1519340241574-2cec6aef0c01?w=400',
    },
    {
      'title': '9 Healthy Breakfast Ideas for Toddlers',
      'category': 'Nutrition',
      'categoryColor': AppColors.accentGreen,
      'description': 'Nutritious, quick and easy breakfast recipes your toddler will love.',
      'readTime': '6 min read',
      'image': 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=400',
    },
    {
      'title': 'How to Improve Baby Sleep Naturally',
      'category': 'Sleep',
      'categoryColor': AppColors.primary,
      'description': 'Simple tips and routines to help your baby sleep better at night.',
      'readTime': '7 min read',
      'image': 'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=400',
    },
  ];

  static final List<Map<String, dynamic>> _expertVideos = [
    {
      'title': 'Understanding Growth Spurts in Babies',
      'expert': 'Dr. Neha Sharma',
      'role': 'Pediatrician',
      'duration': '04:35',
      'image': 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400',
      'bgColor': AppColors.primaryLight,
    },
    {
      'title': 'Balanced Diet for 1-3 Year Old Kids',
      'expert': 'Dr. Priya Mehta',
      'role': 'Nutritionist',
      'duration': '06:12',
      'image': 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=400',
      'bgColor': AppColors.accentGreenLight,
    },
    {
      'title': 'Managing Toddler Tantrums Calmly',
      'expert': 'Dr. Ritu Verma',
      'role': 'Child Psychologist',
      'duration': '05:08',
      'image': 'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=400',
      'bgColor': AppColors.accentPinkLight,
    },
  ];

  static final List<Map<String, String>> _trending = [
    {'title': 'When will my baby start speaking?'},
    {'title': "Screen time for toddlers: What's right?"},
    {'title': 'Signs your baby is ready for solid foods'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppConstants.paddingL),
                _buildSearchBar(),
                const SizedBox(height: AppConstants.paddingXL),
                _buildCategories(),
                const SizedBox(height: AppConstants.paddingXL),
                _buildFeaturedArticles(),
                const SizedBox(height: AppConstants.paddingXL),
                _buildExpertPicks(),
                const SizedBox(height: AppConstants.paddingXL),
                _buildTrending(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: AppConstants.paddingL,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Learn', style: AppTextStyles.headlineLarge),
          Text(
            'Trusted knowledge for every step of your parenting journey 💜',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 24),
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                  child: const Center(child: Text('2', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700))),
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppConstants.paddingM),
          const Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
          const SizedBox(width: AppConstants.paddingS),
          Expanded(
            child: Text(
              'Search articles, videos, topics...',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Browse by Categories', actionLabel: 'View All', onAction: () {}),
        const SizedBox(height: AppConstants.paddingM),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _categories.asMap().entries.map((entry) {
              final i = entry.key;
              final cat = entry.value;
              return Padding(
                padding: EdgeInsets.only(right: i < _categories.length - 1 ? AppConstants.paddingL : 0),
                child: GestureDetector(
                  onTap: () {},
                  child: SizedBox(
                    width: 70,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: cat['color'] as Color,
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          ),
                          child: Center(child: Text(cat['emoji'] as String, style: const TextStyle(fontSize: 24))),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          cat['label'] as String,
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          cat['count'] as String,
                          style: AppTextStyles.labelSmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedArticles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Featured Articles', actionLabel: 'View All', onAction: () {}),
        const SizedBox(height: AppConstants.paddingM),
        // No fixed height — cards size themselves naturally
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _featuredArticles.asMap().entries.map((entry) {
              final i = entry.key;
              final article = entry.value;
              return Padding(
                padding: EdgeInsets.only(right: i < _featuredArticles.length - 1 ? AppConstants.paddingM : 0),
                child: SizedBox(
                  width: 200,
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    onTap: () {},
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(AppConstants.radiusL),
                                topRight: Radius.circular(AppConstants.radiusL),
                              ),
                              child: Image.network(
                                article['image'] as String,
                                height: 115,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 115,
                                  color: AppColors.primaryLight,
                                  child: const Center(child: Icon(Icons.article_rounded, color: AppColors.primaryMid, size: 36)),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: article['categoryColor'] as Color,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                                ),
                                child: Text(
                                  article['category'] as String,
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppConstants.paddingM),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                article['title'] as String,
                                style: AppTextStyles.titleMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                article['description'] as String,
                                style: AppTextStyles.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 11, color: AppColors.textSecondary),
                                  const SizedBox(width: 3),
                                  Text(article['readTime'] as String, style: AppTextStyles.labelSmall),
                                  const Spacer(),
                                  const Icon(Icons.bookmark_border_rounded, size: 14, color: AppColors.textHint),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildExpertPicks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Expert Picks', actionLabel: 'View All', onAction: () {}),
        const SizedBox(height: AppConstants.paddingM),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _expertVideos.asMap().entries.map((entry) {
              final i = entry.key;
              final video = entry.value;
              return Padding(
                padding: EdgeInsets.only(right: i < _expertVideos.length - 1 ? AppConstants.paddingM : 0),
                child: SizedBox(
                  width: 178,
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    onTap: () {},
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(AppConstants.radiusL),
                                topRight: Radius.circular(AppConstants.radiusL),
                              ),
                              child: Image.network(
                                video['image'] as String,
                                height: 108,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 108,
                                  color: video['bgColor'] as Color,
                                  child: const Center(child: Icon(Icons.play_circle_rounded, color: AppColors.primary, size: 40)),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  video['duration'] as String,
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 22),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppConstants.paddingS),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                video['title'] as String,
                                style: AppTextStyles.titleMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(video['expert'] as String, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
                                        Text(video['role'] as String, style: AppTextStyles.labelSmall),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.more_vert_rounded, size: 16, color: AppColors.textHint),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTrending() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Trending Now', actionLabel: 'View All', onAction: () {}),
        const SizedBox(height: AppConstants.paddingM),
        ..._trending.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
              child: AppCard(
                onTap: () {},
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                      child: const Icon(Icons.trending_up_rounded, color: AppColors.primary, size: 16),
                    ),
                    const SizedBox(width: AppConstants.paddingM),
                    Expanded(child: Text(item['title']!, style: AppTextStyles.titleMedium)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                      ),
                      child: Text(
                        'Trending',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 18),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
