import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/baby_provider.dart';
import '../../../core/providers/pregnancy_provider.dart';
import '../../../core/services/supabase_service.dart';
import 'login_screen.dart';
import '../../../core/widgets/main_shell.dart';
import '../../onboarding/presentation/baby_setup_screen.dart';
import '../../pregnancy/presentation/pregnancy_shell.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    // Minimum splash display time
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null && !_isExpired(session);

    if (!isLoggedIn) {
      _go(const LoginScreen());
      return;
    }

    // User is logged in — check profile role and baby profile.
    final profile = await SupabaseService.fetchProfile(session.user.id);
    if (!mounted) return;

    debugPrint('[SplashScreen] role=${profile?['role']}, userId=${session.user.id}');

    if (profile?['role'] == 'family') {
      _go(const MainShell());
      return;
    }

    await ref.read(babyProvider.notifier).loadBaby();
    if (!mounted) return;

    final babyState = ref.read(babyProvider);
    if (!babyState.hasBaby) {
      _go(const BabySetupScreen());
      return;
    }

    // Pregnant users get the pregnancy home screen
    if (profile?['role'] == 'pregnant') {
      debugPrint('[SplashScreen] Routing to PregnancyShell, dueDate=${babyState.baby?.dueDate}');
      final baby = babyState.baby!;
      if (baby.dueDate != null) {
        await ref
            .read(pregnancyProvider.notifier)
            .loadFromDueDate(baby.dueDate!);
      } else {
        await ref.read(pregnancyProvider.notifier).loadWeek(1);
      }
      if (!mounted) return;
      _go(const PregnancyShell());
      return;
    }

    _go(const MainShell());
  }

  void _go(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  bool _isExpired(Session session) {
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(
      DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF0F3), // warm cream (matches icon bg)
              Color(0xFFFFD6E0), // soft blush pink
              Color(0xFFE8D5F5), // light lavender (matches icon purple)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App icon
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB57BEE).withValues(alpha: 0.25),
                            blurRadius: 30,
                            spreadRadius: 4,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF9B59B6), Color(0xFFFF8FAB)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: const Center(
                              child: Text('💗', style: TextStyle(fontSize: 52)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'MotherHood',
                      style: AppTextStyles.displayLarge.copyWith(
                        color: const Color(0xFF6B2D8B),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your parenting companion',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: const Color(0xFF9B6BB5),
                      ),
                    ),
                    const SizedBox(height: 64),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: const Color(0xFF9B59B6).withValues(alpha: 0.6),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
