import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/baby_avatar.dart';
import '../../../core/providers/baby_provider.dart';
import '../../../core/providers/milestones_provider.dart';
import '../../../models/baby_model.dart';
import '../../../models/milestone_model.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../vaccination/presentation/vaccination_screen.dart';
import '../../food_menu/presentation/food_menu_screen.dart';
import '../../milestones/presentation/baby_journey_screen.dart';
import '../../community/presentation/communities_list_screen.dart';
import '../../learn/presentation/learn_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _tipController = PageController();

  final List<Map<String, String>> _tips = [
    {
      'text': 'Babies of 8 months may start crawling or pulling themselves up.',
      'image': 'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=400',
    },
    {
      'text': 'Introduce one new food at a time and wait 2–3 days to check for allergies.',
      'image': 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=400',
    },
    {
      'text': 'Reading to your baby every day builds language and bonding.',
      'image': 'https://images.unsplash.com/photo-1519340241574-2cec6aef0c01?w=400',
    },
  ];

  final List<Map<String, dynamic>> _quickActions = [
    {'icon': Icons.directions_walk_rounded,  'label': 'Milestone\nTracker',  'color': AppColors.primaryLight,      'iconColor': AppColors.primary,      'route': 'milestones'},
    {'icon': Icons.restaurant_menu_rounded,  'label': 'Menu &\nRecipes',     'color': AppColors.accentGreenLight,  'iconColor': AppColors.accentGreen,  'route': 'food'},
    {'icon': Icons.people_rounded,           'label': 'Communities',         'color': AppColors.accentPinkLight,   'iconColor': AppColors.accentPink,   'route': 'community'},
    {'icon': Icons.menu_book_rounded,        'label': 'Knowledge\nHub',      'color': AppColors.primaryLight,      'iconColor': AppColors.primary,      'route': 'learn'},
    {'icon': Icons.vaccines_rounded,         'label': 'Vaccination\nTracker','color': AppColors.accentOrangeLight, 'iconColor': AppColors.accentOrange, 'route': 'vaccination'},
  ];

  final List<Map<String, dynamic>> _recommendedItems = [
    {
      'title': 'How to introduce solids to your baby?',
      'duration': '5 min read',
      'image': 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=400',
      'color': AppColors.primaryLight,
    },
    {
      'title': '7 Healthy Recipes for 8M+ Babies',
      'duration': '10 min read',
      'image': 'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=400',
      'color': AppColors.accentPinkLight,
    },
  ];

  String _monthName(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[month - 1];
  }

  @override
  void dispose() {
    _tipController.dispose();
    super.dispose();
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  void _goToProfile() => Navigator.push(
        context, MaterialPageRoute(builder: (_) => const ProfileScreen()));

  void _goToLearn() => Navigator.push(
        context, MaterialPageRoute(builder: (_) => const LearnScreen()));

  void _goToMilestones() => Navigator.push(
        context, MaterialPageRoute(builder: (_) => const MilestonesScreen()));

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(AppConstants.paddingL),
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingL),
            Text('Notifications', style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppConstants.paddingL),
            _NotifTile(emoji: '🏆', title: 'Milestone achieved!', subtitle: 'Aarohi completed Social — 2/5 done', time: '2h ago'),
            _NotifTile(emoji: '💡', title: 'Daily tip', subtitle: 'Tummy time helps strengthen neck muscles.', time: '5h ago'),
            _NotifTile(emoji: '💉', title: 'Vaccination reminder', subtitle: 'Check upcoming vaccinations for Aarohi.', time: '1d ago'),
            const SizedBox(height: AppConstants.paddingM),
          ],
        ),
      ),
    );
  }

  void _handleQuickAction(String route) {
    switch (route) {
      case 'milestones':
        _goToMilestones();
      case 'food':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodMenuScreen()));
      case 'vaccination':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const VaccinationScreen()));
      case 'community':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunitiesListScreen()));
      case 'learn':
        _goToLearn();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final baby = ref.watch(babyProvider).baby ?? sampleBaby;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(baby),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppConstants.paddingL),
                _buildBabyCard(baby),
                const SizedBox(height: AppConstants.paddingXL),
                _buildTodayForYou(),
                const SizedBox(height: AppConstants.paddingXL),
                _buildQuickActions(),
                const SizedBox(height: AppConstants.paddingXL),
                _buildMilestoneProgress(),
                const SizedBox(height: AppConstants.paddingXL),
                _buildRecommendedSection(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar(BabyModel baby) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: AppConstants.paddingL,
      title: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppConstants.appName, style: AppTextStyles.headlineMedium),
              Text(AppConstants.appTagline,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
      actions: [
        // Notification bell
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 26),
              Positioned(
                right: -2, top: -2,
                child: Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                  child: const Center(
                    child: Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
          onPressed: _showNotificationsSheet,
        ),
        // Profile avatar
        Padding(
          padding: const EdgeInsets.only(right: AppConstants.paddingL),
          child: GestureDetector(
            onTap: _goToProfile,
            child: BabyAvatar(name: 'Mom', size: 34),
          ),
        ),
      ],
    );
  }

  // ── Baby card ─────────────────────────────────────────────────────────────

  Widget _buildBabyCard(BabyModel baby) {
    return GestureDetector(
      onTap: _goToProfile,
      child: AppCard(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BabyAvatar(name: baby.name, size: 60),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text('My Baby', style: AppTextStyles.bodySmall),
                      const SizedBox(width: 6),
                      const Icon(Icons.edit_rounded, size: 14, color: AppColors.primary),
                    ],
                  ),
                  Text(baby.name,
                      style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary)),
                  Text(baby.ageString,
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.accentPink)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10, runSpacing: 2,
                    children: [
                      if (baby.birthDate != null)
                        _BabyStatChip(
                          icon: Icons.cake_rounded,
                          label: 'Born',
                          value: '${baby.birthDate!.day} ${_monthName(baby.birthDate!.month)} ${baby.birthDate!.year}',
                        ),
                      if (baby.dueDate != null && baby.birthDate == null)
                        _BabyStatChip(
                          icon: Icons.calendar_today_rounded,
                          label: 'Due',
                          value: '${baby.dueDate!.day} ${_monthName(baby.dueDate!.month)}',
                        ),
                      if (baby.heightCm != null)
                        _BabyStatChip(icon: Icons.straighten_rounded, label: 'Height', value: '${baby.heightCm!.toInt()} cm'),
                      if (baby.weightKg != null)
                        _BabyStatChip(icon: Icons.monitor_weight_rounded, label: 'Weight', value: '${baby.weightKg} kg'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text('🐘', style: TextStyle(fontSize: 34)),
          ],
        ),
      ),
    );
  }

  // ── Today for you ─────────────────────────────────────────────────────────

  Widget _buildTodayForYou() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Today for you',
          actionLabel: 'See All',
          onAction: _goToLearn,
        ),
        const SizedBox(height: AppConstants.paddingM),
        AspectRatio(
          aspectRatio: 2.6,
          child: PageView.builder(
            controller: _tipController,
            itemCount: _tips.length,
            itemBuilder: (context, index) {
              final tip = _tips[index];
              return GestureDetector(
                onTap: _goToLearn,
                child: AppCard(
                  padding: EdgeInsets.zero,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.paddingM),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.accentOrangeLight,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: const Icon(Icons.lightbulb_rounded,
                                    color: AppColors.accentOrange, size: 15),
                              ),
                              const SizedBox(height: 5),
                              Text('Did you know?',
                                  style: AppTextStyles.labelMedium
                                      .copyWith(color: AppColors.textSecondary)),
                              const SizedBox(height: 3),
                              Flexible(
                                child: Text(
                                  tip['text']!,
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.textPrimary),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(AppConstants.radiusL),
                          bottomRight: Radius.circular(AppConstants.radiusL),
                        ),
                        child: AspectRatio(
                          aspectRatio: 0.75,
                          child: Image.network(
                            tip['image']!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.primaryLight,
                              child: const Center(
                                  child: Text('👶', style: TextStyle(fontSize: 32))),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: SmoothPageIndicator(
            controller: _tipController,
            count: _tips.length,
            effect: const WormEffect(
              dotHeight: 6, dotWidth: 6,
              activeDotColor: AppColors.primary,
              dotColor: AppColors.primaryLight,
            ),
          ),
        ),
      ],
    );
  }

  // ── Quick actions ─────────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _quickActions.asMap().entries.map((entry) {
          final i = entry.key;
          final action = entry.value;
          return Padding(
            padding: EdgeInsets.only(
                right: i < _quickActions.length - 1 ? AppConstants.paddingM : 0),
            child: GestureDetector(
              onTap: () => _handleQuickAction(action['route'] as String),
              child: SizedBox(
                width: 66,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(
                        color: action['color'] as Color,
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      ),
                      child: Icon(action['icon'] as IconData,
                          color: action['iconColor'] as Color, size: 24),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      action['label'] as String,
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Milestone progress ────────────────────────────────────────────────────

  Widget _buildMilestoneProgress() {
    final msState = ref.watch(milestonesProvider);
    final milestones = msState.categories.isNotEmpty ? msState.categories : sampleMilestones;
    final totalAchieved = msState.categories.isNotEmpty
        ? msState.totalAchieved
        : milestones.fold<int>(0, (s, m) => s + m.achieved);
    final totalItems = msState.categories.isNotEmpty
        ? msState.totalItems
        : milestones.fold<int>(0, (s, m) => s + m.total);
    final overallPercent = msState.categories.isNotEmpty
        ? msState.overallPercent
        : (totalItems == 0 ? 0.0 : totalAchieved / totalItems);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Milestone Progress',
          actionLabel: 'See All',
          onAction: _goToMilestones,
        ),
        const SizedBox(height: AppConstants.paddingM),
        GestureDetector(
          onTap: _goToMilestones,
          child: AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80, height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80, height: 80,
                        child: CircularProgressIndicator(
                          value: overallPercent,
                          strokeWidth: 7,
                          backgroundColor: AppColors.primaryLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(overallPercent * 100).toInt()}%',
                            style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primary, fontWeight: FontWeight.w800),
                          ),
                          Text('On Track',
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.accentGreen, fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.paddingL),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: milestones.take(4).map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _MilestoneProgressRow(milestone: m),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Recommended section ───────────────────────────────────────────────────

  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recommended for you',
          actionLabel: 'See All',
          onAction: _goToLearn,
        ),
        const SizedBox(height: AppConstants.paddingM),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _recommendedItems.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                    right: i < _recommendedItems.length - 1 ? AppConstants.paddingM : 0),
                child: GestureDetector(
                  onTap: _goToLearn,
                  child: SizedBox(
                    width: 200,
                    child: AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(AppConstants.radiusL),
                              topRight: Radius.circular(AppConstants.radiusL),
                            ),
                            child: Image.network(
                              item['image'] as String,
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 100,
                                color: item['color'] as Color,
                                child: const Center(
                                    child: Icon(Icons.image_rounded,
                                        color: AppColors.primaryMid, size: 32)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(AppConstants.paddingM),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item['title'] as String,
                                  style: AppTextStyles.titleMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded,
                                        size: 12, color: AppColors.textSecondary),
                                    const SizedBox(width: 3),
                                    Text(item['duration'] as String,
                                        style: AppTextStyles.labelSmall),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _BabyStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _BabyStatChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: AppColors.textSecondary),
            const SizedBox(width: 2),
            Text(label, style: AppTextStyles.labelSmall),
          ],
        ),
        Text(value,
            style: AppTextStyles.labelMedium
                .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _MilestoneProgressRow extends StatelessWidget {
  final MilestoneCategoryProgress milestone;
  const _MilestoneProgressRow({required this.milestone});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(milestone.category.emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(milestone.category.label.split(' ').first,
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
                  Text('${milestone.achieved}/${milestone.total}',
                      style: AppTextStyles.labelSmall),
                ],
              ),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: milestone.progressPercent,
                  minHeight: 4,
                  backgroundColor: AppColors.primaryLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    milestone.progressPercent >= 1.0
                        ? AppColors.accentGreen
                        : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Icon(
          milestone.progressPercent >= 1.0
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          size: 14,
          color: milestone.progressPercent >= 1.0
              ? AppColors.accentGreen
              : AppColors.textHint,
        ),
      ],
    );
  }
}

class _NotifTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String time;

  const _NotifTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                Text(subtitle,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(time,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }
}
