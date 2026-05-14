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
    {'icon': Icons.directions_walk_rounded, 'label': 'Milestone\nTracker', 'color': AppColors.primaryLight, 'iconColor': AppColors.primary},
    {'icon': Icons.restaurant_menu_rounded, 'label': 'Menu &\nRecipes', 'color': AppColors.accentGreenLight, 'iconColor': AppColors.accentGreen},
    {'icon': Icons.people_rounded, 'label': 'Communities', 'color': AppColors.accentPinkLight, 'iconColor': AppColors.accentPink},
    {'icon': Icons.menu_book_rounded, 'label': 'Knowledge\nHub', 'color': AppColors.primaryLight, 'iconColor': AppColors.primary},
    {'icon': Icons.vaccines_rounded, 'label': 'Vaccination\nTracker', 'color': AppColors.accentOrangeLight, 'iconColor': AppColors.accentOrange},
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

  @override
  Widget build(BuildContext context) {
    final babyState = ref.watch(babyProvider);
    final baby = babyState.baby ?? sampleBaby; // fallback while loading

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
            width: 32,
            height: 32,
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
              Text(
                AppConstants.appTagline,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 26),
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                  child: const Center(
                    child: Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: AppConstants.paddingL),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: BabyAvatar(name: 'Mom', size: 34),
          ),
        ),
      ],
    );
  }

  Widget _buildBabyCard(BabyModel baby) {
    return AppCard(
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
                Text(
                  baby.name,
                  style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
                ),
                Text(
                  baby.ageString,
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.accentPink),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 2,
                  children: [
                    if (baby.birthDate != null)
                      _BabyStatChip(
                        icon: Icons.cake_rounded,
                        label: 'Born',
                        value: '${baby.birthDate!.day} ${_monthName(baby.birthDate!.month)} ${baby.birthDate!.year}',
                      ),
                    if (baby.dueDate != null && baby.birthDate == null)
                      _BabyStatChip(icon: Icons.calendar_today_rounded, label: 'Due', value: '${baby.dueDate!.day} ${_monthName(baby.dueDate!.month)}'),
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
    );
  }

  Widget _buildTodayForYou() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Today for you', actionLabel: 'See All', onAction: () {}),
        const SizedBox(height: AppConstants.paddingM),
        // Use AspectRatio so height is always proportional to screen width
        AspectRatio(
          aspectRatio: 2.6,
          child: PageView.builder(
            controller: _tipController,
            itemCount: _tips.length,
            itemBuilder: (context, index) {
              final tip = _tips[index];
              return AppCard(
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
                              child: const Icon(Icons.lightbulb_rounded, color: AppColors.accentOrange, size: 15),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Did you know?',
                              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 3),
                            Flexible(
                              child: Text(
                                tip['text']!,
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
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
                            child: const Center(child: Text('👶', style: TextStyle(fontSize: 32))),
                          ),
                        ),
                      ),
                    ),
                  ],
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
              dotHeight: 6,
              dotWidth: 6,
              activeDotColor: AppColors.primary,
              dotColor: AppColors.primaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _quickActions.asMap().entries.map((entry) {
          final i = entry.key;
          final action = entry.value;
          return Padding(
            padding: EdgeInsets.only(right: i < _quickActions.length - 1 ? AppConstants.paddingM : 0),
            child: GestureDetector(
              onTap: () {},
              child: SizedBox(
                width: 66,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: action['color'] as Color,
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      ),
                      child: Icon(action['icon'] as IconData, color: action['iconColor'] as Color, size: 24),
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

  Widget _buildMilestoneProgress() {
    // Using real milestones from provider, fallback to sample while loading
    final msState = ref.watch(milestonesProvider);
    final milestones = msState.categories.isNotEmpty
        ? msState.categories
        : sampleMilestones;
    final totalAchieved = msState.categories.isNotEmpty ? msState.totalAchieved : milestones.fold<int>(0, (sum, m) => sum + m.achieved);
    final totalItems = msState.categories.isNotEmpty ? msState.totalItems : milestones.fold<int>(0, (sum, m) => sum + m.total);
    final overallPercent = msState.categories.isNotEmpty ? msState.overallPercent : (totalItems == 0 ? 0.0 : totalAchieved / totalItems);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Milestone Progress', actionLabel: 'See All', onAction: () {}),
        const SizedBox(height: AppConstants.paddingM),
        AppCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Fixed-size circular indicator — no Column inside Stack
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
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
                          style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'On Track',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentGreen, fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.paddingL),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: milestones.take(4).map((m) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _MilestoneProgressRow(milestone: m),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedSection() {
    final items = [
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Recommended for you', actionLabel: 'See All', onAction: () {}),
        const SizedBox(height: AppConstants.paddingM),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(right: i < items.length - 1 ? AppConstants.paddingM : 0),
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
                              child: const Center(child: Icon(Icons.image_rounded, color: AppColors.primaryMid, size: 32)),
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
                                  const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textSecondary),
                                  const SizedBox(width: 3),
                                  Text(item['duration'] as String, style: AppTextStyles.labelSmall),
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
}

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
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
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
                  Text(
                    milestone.category.label.split(' ').first,
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary),
                  ),
                  Text('${milestone.achieved}/${milestone.total}', style: AppTextStyles.labelSmall),
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
                    milestone.progressPercent >= 1.0 ? AppColors.accentGreen : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Icon(
          milestone.progressPercent >= 1.0 ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 14,
          color: milestone.progressPercent >= 1.0 ? AppColors.accentGreen : AppColors.textHint,
        ),
      ],
    );
  }
}
