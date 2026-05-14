import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  static final List<Map<String, dynamic>> _communities = [
    {'name': 'January 2026 Moms', 'members': '2.4K Members', 'online': '24 online', 'emoji': '🍼', 'color': AppColors.primaryLight, 'joined': true},
    {'name': 'Breastfeeding Support', 'members': '1.8K Members', 'online': '18 online', 'emoji': '💗', 'color': AppColors.accentPinkLight, 'joined': true},
    {'name': 'Working Moms', 'members': '1.6K Members', 'online': '21 online', 'emoji': '💼', 'color': AppColors.accentGreenLight, 'joined': true},
  ];

  static final List<Map<String, dynamic>> _discussions = [
    {
      'avatar': 'https://i.pravatar.cc/150?img=47',
      'title': 'My 8 month old wakes 3-4 times at night. Is it normal?',
      'category': 'Sleep & Routine',
      'replies': '36 Replies',
      'views': '1.2K Views',
      'time': '2m ago',
    },
    {
      'avatar': 'https://i.pravatar.cc/150?img=32',
      'title': 'Easy and healthy dinner ideas for 1 year old babies?',
      'category': 'Food & Nutrition',
      'replies': '28 Replies',
      'views': '980 Views',
      'time': '1h ago',
    },
    {
      'avatar': 'https://i.pravatar.cc/150?img=25',
      'title': 'When did your baby start saying their first word?',
      'category': 'Development',
      'replies': '52 Replies',
      'views': '1.5K Views',
      'time': '3h ago',
    },
  ];

  static final List<Map<String, String>> _topics = [
    {'label': 'Pregnancy', 'members': '1.2K Members', 'emoji': '🤰'},
    {'label': 'Newborn Care', 'members': '2.1K Members', 'emoji': '🍼'},
    {'label': 'Food & Nutrition', 'members': '1.9K Members', 'emoji': '🥗'},
    {'label': 'Sleep & Routine', 'members': '1.7K Members', 'emoji': '🌙'},
    {'label': 'Parenting', 'members': '2.3K Members', 'emoji': '💗'},
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
                _buildHeroBanner(),
                const SizedBox(height: AppConstants.paddingXL),
                _buildMyCommunities(),
                const SizedBox(height: AppConstants.paddingXL),
                _buildPopularDiscussions(),
                const SizedBox(height: AppConstants.paddingXL),
                _buildBrowseByTopics(),
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
        children: [
          Text('Community', style: AppTextStyles.headlineLarge),
          Text(
            'Connect, share & grow together 💜',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary, size: 24),
          onPressed: () {},
        ),
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 24),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                  child: const Center(child: Text('3', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700))),
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

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        gradient: AppColors.softPurpleGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You're not alone,",
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
                ),
                Text(
                  "We're here with you 💗",
                  style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join conversations, ask questions and get support from other moms.',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Create Post'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                    textStyle: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text('👩‍👧‍👦', style: TextStyle(fontSize: 64)),
        ],
      ),
    );
  }

  Widget _buildMyCommunities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'My Communities', actionLabel: 'View All', onAction: () {}),
        const SizedBox(height: AppConstants.paddingM),
        ..._communities.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
              child: _CommunityCard(community: c),
            )),
      ],
    );
  }

  Widget _buildPopularDiscussions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Popular Discussions', actionLabel: 'See All', onAction: () {}),
        const SizedBox(height: AppConstants.paddingM),
        ..._discussions.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
              child: _DiscussionCard(discussion: d),
            )),
      ],
    );
  }

  Widget _buildBrowseByTopics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Browse by Topics', style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppConstants.paddingM),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _topics.asMap().entries.map((entry) {
              final i = entry.key;
              final topic = entry.value;
              return Padding(
                padding: EdgeInsets.only(right: i < _topics.length - 1 ? AppConstants.paddingL : 0),
                child: GestureDetector(
                  onTap: () {},
                  child: SizedBox(
                    width: 72,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(topic['emoji']!, style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          topic['label']!,
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          topic['members']!,
                          style: AppTextStyles.labelSmall,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
}

class _CommunityCard extends StatelessWidget {
  final Map<String, dynamic> community;

  const _CommunityCard({required this.community});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {},
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: community['color'] as Color,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Center(
              child: Text(community['emoji'] as String, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(community['name'] as String, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(community['members'] as String, style: AppTextStyles.bodySmall),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(color: AppColors.accentGreen, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text(community['online'] as String, style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentGreen)),
                  ],
                ),
              ],
            ),
          ),
          if (community['joined'] == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_rounded, size: 12, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('Joined', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DiscussionCard extends StatelessWidget {
  final Map<String, dynamic> discussion;

  const _DiscussionCard({required this.discussion});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {},
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: Image.network(
              discussion['avatar'] as String,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 40,
                height: 40,
                color: AppColors.primaryLight,
                child: const Center(child: Text('👩', style: TextStyle(fontSize: 20))),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        discussion['title'] as String,
                        style: AppTextStyles.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(discussion['time'] as String, style: AppTextStyles.labelSmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  discussion['category'] as String,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(discussion['replies'] as String, style: AppTextStyles.labelSmall),
                    const SizedBox(width: AppConstants.paddingM),
                    const Icon(Icons.remove_red_eye_outlined, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(discussion['views'] as String, style: AppTextStyles.labelSmall),
                    const Spacer(),
                    const Icon(Icons.bookmark_border_rounded, size: 16, color: AppColors.textHint),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
