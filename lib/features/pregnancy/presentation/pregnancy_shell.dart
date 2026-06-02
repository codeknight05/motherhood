import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/presentation/home_screen.dart';
import '../../food_menu/presentation/food_menu_screen.dart';
import '../../community/presentation/communities_list_screen.dart';
import '../../learn/presentation/learn_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/baby_provider.dart';
import '../../../core/providers/pregnancy_provider.dart';
import 'pregnancy_home_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Pregnancy Shell — bottom nav for pregnant users.
// Replaces "Milestones" with "Journey" (pregnancy week screen).
// ═══════════════════════════════════════════════════════════════════════════

class PregnancyShell extends ConsumerStatefulWidget {
  const PregnancyShell({super.key});

  @override
  ConsumerState<PregnancyShell> createState() => _PregnancyShellState();
}

class _PregnancyShellState extends ConsumerState<PregnancyShell> {
  int _currentIndex = 0;
  bool _showExitPill = false;

  void _handleBackPress() {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return;
    }
    if (_showExitPill) {
      SystemNavigator.pop();
      return;
    }
    setState(() => _showExitPill = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showExitPill = false);
    });
  }

  final List<Widget> _screens = const [
    HomeScreen(role: 'pregnant'),
    PregnancyHomeScreen(),
    FoodMenuScreen(),
    CommunitiesListScreen(),
    LearnScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureDataLoaded());
  }

  Future<void> _ensureDataLoaded() async {
    // Make sure baby is loaded
    final babyState = ref.read(babyProvider);
    if (!babyState.hasChecked) {
      await ref.read(babyProvider.notifier).loadBaby();
    }
    if (!mounted) return;

    // Trigger pregnancy week load if not already done
    final baby = ref.read(babyProvider).baby;
    final pgState = ref.read(pregnancyProvider);
    if (baby != null && pgState.guidance == null && !pgState.isLoading) {
      final notifier = ref.read(pregnancyProvider.notifier);
      if (baby.dueDate != null) {
        notifier.loadFromDueDate(baby.dueDate!);
      } else {
        notifier.loadWeek(1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBackPress();
      },
      child: Stack(
        children: [
          Scaffold(
            body: IndexedStack(index: _currentIndex, children: _screens),
            bottomNavigationBar: _buildBottomNav(),
          ),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _NavItem(
                icon: Icons.favorite_rounded,
                label: 'Journey',
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
