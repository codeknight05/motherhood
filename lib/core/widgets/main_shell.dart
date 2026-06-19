import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/milestones/presentation/baby_journey_screen.dart';
import '../../features/food_menu/presentation/food_menu_screen.dart';
import '../../features/community/presentation/communities_list_screen.dart';
import '../../features/learn/presentation/learn_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../providers/baby_provider.dart';
import '../providers/milestones_provider.dart';
import '../providers/pregnancy_provider.dart';
import '../services/supabase_service.dart';
import '../../features/pregnancy/presentation/pregnancy_shell.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;
  bool _roleChecked = false;
  bool _showExitPill = false;

  void _handleBackPress() {
    if (_currentIndex != 0) {
      // Not on Home — go to Home tab
      setState(() => _currentIndex = 0);
      return;
    }
    // Already on Home — show exit pill
    if (_showExitPill) {
      // Second back press while pill is showing — exit
      SystemNavigator.pop();
      return;
    }
    setState(() => _showExitPill = true);
    // Auto-hide pill after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showExitPill = false);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initShell());
  }

  Future<void> _initShell() async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      setState(() => _roleChecked = true);
      return;
    }

    // Load baby data if not already loaded
    final babyState = ref.read(babyProvider);
    if (!babyState.hasChecked) {
      await ref.read(babyProvider.notifier).loadBaby();
    }
    if (!mounted) return;

    // Check role — if pregnant, redirect to PregnancyShell
    final profile = await SupabaseService.fetchProfile(user.id);
    if (!mounted) return;

    setState(() => _roleChecked = true);

    if (profile?['role'] == 'pregnant') {
      // Load pregnancy data then replace with PregnancyShell
      final baby = ref.read(babyProvider).baby;
      if (baby?.dueDate != null) {
        await ref.read(pregnancyProvider.notifier).loadFromDueDate(baby!.dueDate!);
      } else {
        await ref.read(pregnancyProvider.notifier).loadWeek(1);
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const PregnancyShell(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
      return;
    }

    // Parent role — load milestones
    _loadMilestonesForCurrentUser();
  }

  Future<void> _loadMilestonesForCurrentUser() async {
    final user = SupabaseService.currentUser;
    final baby = ref.read(babyProvider).baby;
    if (user == null || baby == null) return;

    final profile = await SupabaseService.fetchProfile(user.id);
    final audience = profile?['role'] as String? ?? 'parent';
    if (!mounted) return;

    ref.read(milestonesProvider.notifier)
        .loadMilestones(baby.id, baby.ageInMonths, audience: audience);
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    MilestonesScreen(),
    FoodMenuScreen(role: 'parent'),
    CommunitiesListScreen(),
    LearnScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Show a brief loading screen only while checking role for the first time
    // This prevents the wrong shell from flashing for pregnant users
    if (!_roleChecked) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF0F3),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF9B59B6),
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBackPress();
      },
      child: Stack(
        children: [
          Scaffold(
            extendBody: true,
            body: IndexedStack(index: _currentIndex, children: _screens),
            bottomNavigationBar: _buildBottomNav(),
          ),
          // Exit pill overlay
          if (_showExitPill)
            Positioned(
              bottom: 90,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _showExitPill ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Press back again to exit',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => SystemNavigator.pop(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Exit',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding > 0 ? bottomPadding : 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.directions_walk_rounded,
                  label: 'Milestones',
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _CenterNavItem(
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  icon: Icons.people_rounded,
                  label: 'Community',
                  isSelected: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
                _NavItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Learn',
                  isSelected: _currentIndex == 4,
                  onTap: () => setState(() => _currentIndex = 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? AppColors.navSelected
                  : AppColors.navUnselected,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected
                    ? AppColors.navSelected
                    : AppColors.navUnselected,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterNavItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _CenterNavItem({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? AppColors.primaryGradient
                    : const LinearGradient(
                        colors: [AppColors.primaryMid, AppColors.primaryMid],
                      ),
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: const Icon(
                Icons.rice_bowl_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Nutrition',
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected
                    ? AppColors.navSelected
                    : AppColors.navUnselected,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
