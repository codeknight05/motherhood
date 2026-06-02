import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/baby_avatar.dart';
import '../../../core/widgets/notifications_sheet.dart';
import '../../../core/providers/baby_provider.dart';
import '../../../core/providers/tips_provider.dart';
import '../../../models/article_model.dart';
import '../../learn/presentation/article_detail_screen.dart';
import '../../../core/providers/milestones_provider.dart';
import '../../../core/providers/pregnancy_provider.dart';
import '../../../models/baby_model.dart';
import '../../../models/milestone_model.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../vaccination/presentation/vaccination_screen.dart';
import '../../food_menu/presentation/food_menu_screen.dart';
import '../../milestones/presentation/baby_journey_screen.dart';
import '../../community/presentation/communities_list_screen.dart';
import '../../learn/presentation/learn_screen.dart';
import '../../pregnancy/presentation/pregnancy_home_screen.dart';

// ─── HomeScreen ───────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  /// 'parent' (default) or 'pregnant'
  final String role;
  const HomeScreen({super.key, this.role = 'parent'});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _tipController = PageController();

  bool get _isPregnant => widget.role == 'pregnant';

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

  final List<Map<String, String>> _pregnancyTips = [
    {
      'text': 'Staying hydrated during pregnancy helps support amniotic fluid levels.',
      'image': 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=400',
    },
    {
      'text': 'Gentle walking for 20–30 minutes daily can ease pregnancy discomfort.',
      'image': 'https://images.unsplash.com/photo-1519340241574-2cec6aef0c01?w=400',
    },
    {
      'text': 'Folic acid in the first trimester is essential for your baby\'s neural development.',
      'image': 'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=400',
    },
  ];

  List<Map<String, String>> get _activeTips =>
      _isPregnant ? _pregnancyTips : _tips;

  List<Map<String, dynamic>> get _quickActions => _isPregnant
      ? [
          {'icon': Icons.favorite_rounded,        'label': 'My\nJourney',        'color': const Color(0xFFFFE4EC),     'iconColor': const Color(0xFFE8405A), 'route': 'journey'},
          {'icon': Icons.restaurant_menu_rounded, 'label': 'Nutrition',           'color': AppColors.accentGreenLight,  'iconColor': AppColors.accentGreen,  'route': 'food'},
          {'icon': Icons.people_rounded,          'label': 'Communities',        'color': AppColors.accentPinkLight,   'iconColor': AppColors.accentPink,   'route': 'community'},
          {'icon': Icons.menu_book_rounded,       'label': 'Knowledge\nHub',     'color': AppColors.primaryLight,      'iconColor': AppColors.primary,      'route': 'learn'},
          {'icon': Icons.local_hospital_rounded,  'label': 'Prenatal\nCare',     'color': AppColors.accentOrangeLight, 'iconColor': AppColors.accentOrange, 'route': 'learn'},
        ]
      : [
          {'icon': Icons.directions_walk_rounded, 'label': 'Milestone\nTracker', 'color': AppColors.primaryLight,      'iconColor': AppColors.primary,      'route': 'milestones'},
          {'icon': Icons.restaurant_menu_rounded, 'label': 'Nutrition',           'color': AppColors.accentGreenLight,  'iconColor': AppColors.accentGreen,  'route': 'food'},
          {'icon': Icons.people_rounded,          'label': 'Communities',        'color': AppColors.accentPinkLight,   'iconColor': AppColors.accentPink,   'route': 'community'},
          {'icon': Icons.menu_book_rounded,       'label': 'Knowledge\nHub',     'color': AppColors.primaryLight,      'iconColor': AppColors.primary,      'route': 'learn'},
          {'icon': Icons.vaccines_rounded,        'label': 'Vaccination\nTracker','color': AppColors.accentOrangeLight,'iconColor': AppColors.accentOrange, 'route': 'vaccination'},
        ];

  // Real articles for recommended section
  List<ArticleModel> get _recommendedArticles => _isPregnant
      ? sampleArticles.where((a) =>
          a.id == 'umbilical_cord' || a.id == 'baby_sleep').toList()
      : sampleArticles.where((a) =>
          a.id == 'toddler_breakfast' || a.id == 'toddler_tantrums').toList();



  String _monthName(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[month - 1];
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _goToProfile() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const ProfileScreen()));

  void _goToLearn() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const LearnScreen()));

  void _goToMilestones() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const MilestonesScreen()));

  void _goToJourney() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const PregnancyHomeScreen()));

  void _goToArticle(ArticleModel article) => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)));

  void _handleQuickAction(String route) {
    switch (route) {
      case 'journey':
        _goToJourney();
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
                _isPregnant ? _buildPregnancyCard(baby) : _buildBabyCard(baby),
                const SizedBox(height: AppConstants.paddingXL),
                _buildTodayForYou(),
                const SizedBox(height: AppConstants.paddingXL),
                _buildQuickActions(),
                const SizedBox(height: AppConstants.paddingXL),
                _isPregnant ? _buildPregnancyProgress() : _buildMilestoneProgress(),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppConstants.appName, style: AppTextStyles.headlineMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(AppConstants.appTagline,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Notification bell
        NotificationBell(isPregnant: _isPregnant),
        Padding(
          padding: const EdgeInsets.only(right: AppConstants.paddingL),
          child: GestureDetector(
            onTap: _goToProfile,
            child: BabyAvatar(name: baby.name, size: 34),
          ),
        ),
      ],
    );
  }

  // ── Baby card (parent) ────────────────────────────────────────────────────

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
                  Row(children: [
                    Text('My Baby', style: AppTextStyles.bodySmall),
                    const SizedBox(width: 2),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => ProfileScreen.showEditBabySheet(context, ref, baby),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Icon(Icons.edit_rounded, size: 14, color: AppColors.primary),
                      ),
                    ),
                  ]),
                  Text(baby.name,
                      style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary)),
                  Text(baby.ageString,
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.accentPink)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 10, runSpacing: 2, children: [
                    if (baby.birthDate != null)
                      _BabyStatChip(
                        icon: Icons.cake_rounded, label: 'Born',
                        value: '${baby.birthDate!.day} ${_monthName(baby.birthDate!.month)} ${baby.birthDate!.year}',
                      ),
                    if (baby.heightCm != null)
                      _BabyStatChip(icon: Icons.straighten_rounded, label: 'Height', value: '${baby.heightCm!.toInt()} cm'),
                    if (baby.weightKg != null)
                      _BabyStatChip(icon: Icons.monitor_weight_rounded, label: 'Weight', value: '${baby.weightKg} kg'),
                  ]),
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

  // ── Pregnancy card ────────────────────────────────────────────────────────

  Widget _buildPregnancyCard(BabyModel baby) {
    final pgState = ref.watch(pregnancyProvider);
    final week = pgState.currentWeek;
    final dueDate = baby.dueDate;
    final daysLeft = dueDate != null
        ? dueDate.difference(DateTime.now()).inDays.clamp(0, 280)
        : 0;
    final trimester = week <= 13 ? '1st Trimester' : week <= 26 ? '2nd Trimester' : '3rd Trimester';

    return GestureDetector(
      onTap: _goToJourney,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8FAB), Color(0xFFE8405A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE8405A).withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Womb mini-icon
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('🤰', style: TextStyle(fontSize: 32))),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Week $week · $trimester',
                      style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(
                    daysLeft > 0 ? '$daysLeft days until your due date' : 'Due any day now! 💜',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                    child: LinearProgressIndicator(
                      value: week / 40,
                      minHeight: 5,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${((week / 40) * 100).toInt()}% of journey complete',
                      style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text('View', style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Today for you ─────────────────────────────────────────────────────────

  Widget _buildTodayForYou() {
    final tipsState = ref.watch(tipsProvider);

    // Load tips on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (tipsState.tips.isEmpty && !tipsState.isLoading) {
        final baby = ref.read(babyProvider).baby ?? sampleBaby;
        ref.read(tipsProvider.notifier).loadTips(
          ageInMonths: baby.ageInMonths > 0 ? baby.ageInMonths : 8,
          isPregnant: _isPregnant,
          pregnancyWeek: _isPregnant
              ? ref.read(pregnancyProvider).currentWeek
              : 1,
        );
      }
    });

    // Use AI tips if loaded, otherwise use static fallback
    final List<DailyTip> tips = tipsState.tips.isNotEmpty
        ? tipsState.tips
        : _activeTips.asMap().entries.map((entry) {
            String title = '';
            if (_isPregnant) {
              title = entry.key == 0
                  ? 'Stay Hydrated'
                  : (entry.key == 1 ? 'Gentle Walking' : 'Folic Acid');
            } else {
              title = entry.key == 0
                  ? 'Physical Play'
                  : (entry.key == 1 ? 'New Foods' : 'Daily Reading');
            }
            return DailyTip(
              title: title,
              text: entry.value['text']!,
              emoji: '💡',
              category: _isPregnant ? 'nutrition' : (entry.key == 0 ? 'development' : (entry.key == 1 ? 'nutrition' : 'wellness')),
            );
          }).toList();

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
          aspectRatio: 2.2,
          child: PageView.builder(
            controller: _tipController,
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final tip = tips[index];
              final imageUrl = index < _activeTips.length
                  ? _activeTips[index]['image']!
                  : _activeTips[0]['image']!;
              return GestureDetector(
                onTap: () => _showArticleLoadingAndGenerate(context, tip),
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
                                  color: _isPregnant
                                      ? const Color(0xFFFFE4EC)
                                      : AppColors.accentOrangeLight,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: tipsState.isLoading && tipsState.tips.isEmpty
                                    ? const SizedBox(
                                        width: 15, height: 15,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : Text(
                                        tip.emoji,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                tipsState.tips.isNotEmpty ? '✨ Grandma\'s Tip' : 'Did you know?',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tip.title,
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Flexible(
                                child: Text(
                                  tip.text,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 2,
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
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.primaryLight,
                              child: const Center(
                                  child: Text('👶',
                                      style: TextStyle(fontSize: 32))),
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
            count: tips.length,
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

  void _showArticleLoadingAndGenerate(BuildContext context, DailyTip tip) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const _ArticleGenerationDialog();
      },
    );

    try {
      final article = await ref.read(tipsProvider.notifier).generateArticleForTip(tip);
      if (context.mounted) {
        Navigator.pop(context); // Close dialog
        _goToArticle(article);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close dialog
        final fallback = ref.read(tipsProvider.notifier).createFallbackArticle(tip);
        _goToArticle(fallback);
      }
    }
  }

  // ── Quick actions ─────────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    final actions = _quickActions;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: actions.asMap().entries.map((entry) {
          final i = entry.key;
          final action = entry.value;
          return Padding(
            padding: EdgeInsets.only(right: i < actions.length - 1 ? AppConstants.paddingM : 0),
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
                    Text(action['label'] as String,
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary),
                        textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Milestone progress (parent) ───────────────────────────────────────────

  Widget _buildMilestoneProgress() {
    final msState = ref.watch(milestonesProvider);
    final milestones = msState.categories.isNotEmpty ? msState.categories : sampleMilestones;
    final totalAchieved = msState.categories.isNotEmpty ? msState.totalAchieved : milestones.fold<int>(0, (s, m) => s + m.achieved);
    final totalItems = msState.categories.isNotEmpty ? msState.totalItems : milestones.fold<int>(0, (s, m) => s + m.total);
    final overallPercent = msState.categories.isNotEmpty ? msState.overallPercent : (totalItems == 0 ? 0.0 : totalAchieved / totalItems);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Milestone Progress', actionLabel: 'See All', onAction: _goToMilestones),
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
                          value: overallPercent, strokeWidth: 7,
                          backgroundColor: AppColors.primaryLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${(overallPercent * 100).toInt()}%',
                              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
                          Text('On Track',
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentGreen, fontSize: 9)),
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

  // ── Pregnancy progress card ───────────────────────────────────────────────

  Widget _buildPregnancyProgress() {
    final pgState = ref.watch(pregnancyProvider);
    final week = pgState.currentWeek;
    final guidance = pgState.guidance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'This Week\'s Highlights', actionLabel: 'Full Guide', onAction: _goToJourney),
        const SizedBox(height: AppConstants.paddingM),
        GestureDetector(
          onTap: _goToJourney,
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4EC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(child: Text('👶', style: TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: AppConstants.paddingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Week $week — Baby Update',
                              style: AppTextStyles.titleLarge.copyWith(color: const Color(0xFFE8405A))),
                          Text('Tap to read your full weekly guide',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
                  ],
                ),
                if (guidance != null && guidance.babyThisWeek.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.paddingM),
                  const Divider(height: 1),
                  const SizedBox(height: AppConstants.paddingM),
                  Text(
                    guidance.babyThisWeek.split('\n').first.trim(),
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary, height: 1.5),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Recommended section ───────────────────────────────────────────────────

  Widget _buildRecommendedSection() {
    final articles = _recommendedArticles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Recommended for you', actionLabel: 'See All', onAction: _goToLearn),
        const SizedBox(height: AppConstants.paddingM),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: articles.asMap().entries.map((entry) {
              final i = entry.key;
              final article = entry.value;
              return Padding(
                padding: EdgeInsets.only(right: i < articles.length - 1 ? AppConstants.paddingM : 0),
                child: GestureDetector(
                  onTap: () => _goToArticle(article),
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
                              article.imageUrl,
                              height: 100, width: double.infinity, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 100,
                                color: article.categoryColor.withValues(alpha: 0.15),
                                child: Center(child: Icon(Icons.article_rounded,
                                    color: article.categoryColor, size: 32)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(AppConstants.paddingM),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Category chip
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: article.categoryColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                                  ),
                                  child: Text(article.category,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: article.categoryColor,
                                        fontWeight: FontWeight.w700,
                                      )),
                                ),
                                const SizedBox(height: 6),
                                Text(article.title,
                                    style: AppTextStyles.titleMedium,
                                    maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 6),
                                Row(children: [
                                  const Icon(Icons.access_time_rounded,
                                      size: 12, color: AppColors.textSecondary),
                                  const SizedBox(width: 3),
                                  Text(article.readTime, style: AppTextStyles.labelSmall),
                                ]),
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
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 10, color: AppColors.textSecondary),
          const SizedBox(width: 2),
          Text(label, style: AppTextStyles.labelSmall),
        ]),
        Text(value, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
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
                  Text('${milestone.achieved}/${milestone.total}', style: AppTextStyles.labelSmall),
                ],
              ),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: milestone.progressPercent, minHeight: 4,
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

class _ArticleGenerationDialog extends StatelessWidget {
  const _ArticleGenerationDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('✨', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Generating detailed guide...',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Creating a personalized article based on this tip',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

