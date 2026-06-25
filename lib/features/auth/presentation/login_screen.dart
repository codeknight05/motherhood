import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Session;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/baby_provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/widgets/main_shell.dart';
import '../../onboarding/presentation/baby_setup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  ProviderSubscription<AsyncValue<Session?>>? _sessionSubscription;
  bool _isNavigatingAfterAuth = false;
  bool _isSignUp = true; // Default to true if user doesn't have an account
  bool _isLoadingPrefs = true;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkHasAccount();
    // Listen for auth state changes — catches Google OAuth completing
    _listenForAuthChange();
  }

  Future<void> _checkHasAccount() async {
    try {
      final value = await _storage.read(key: 'has_account');
      if (mounted) {
        setState(() {
          _isSignUp = value != 'true';
          _isLoadingPrefs = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingPrefs = false;
        });
      }
    }
  }

  void _listenForAuthChange() {
    _sessionSubscription = ref.listenManual(sessionProvider, (previous, next) {
      next.whenData((session) async {
        if (session != null && mounted) {
          await _navigateAfterAuth();
        }
      });
    });
  }

  @override
  void dispose() {
    _sessionSubscription?.close();
    super.dispose();
  }

  Future<void> _navigateAfterAuth() async {
    if (_isNavigatingAfterAuth) return;
    _isNavigatingAfterAuth = true;

    // Upsert profile with name from auth metadata (Google name, email, etc.)
    final user = SupabaseService.currentUser;
    if (user == null) {
      _isNavigatingAfterAuth = false;
      return;
    }

    final meta = user.userMetadata ?? {};
    final name = meta['full_name'] as String? ??
        meta['name'] as String? ??
        meta['display_name'] as String?;
    final avatar = meta['avatar_url'] as String? ??
        meta['picture'] as String?;

    if (name != null || avatar != null) {
      try {
        await SupabaseService.upsertProfile(
          userId: user.id,
          fullName: name,
          avatarUrl: avatar,
        );
      } catch (_) {}
    }

    // Save account presence on this device
    try {
      await _storage.write(key: 'has_account', value: 'true');
    } catch (_) {}

    await ref.read(babyProvider.notifier).loadBaby();
    if (!mounted) return;
    final hasBaby = ref.read(babyProvider).hasBaby;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => hasBaby ? const MainShell() : const BabySetupScreen(),
      ),
      (_) => false,
    );
  }

  Future<void> _signInWithGoogle() async {
    final notifier = ref.read(authNotifierProvider.notifier);
    final success = await notifier.signInWithGoogle();
    if (success && mounted) {
      await _navigateAfterAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingPrefs) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingXXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildTabToggle(),
                const SizedBox(height: 32),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isSignUp ? _buildFeaturesShowcase() : _buildWelcomeCard(),
                ),
                const SizedBox(height: 32),
                _buildGoogleButton(authState),
                if (authState.hasError) ...[
                  const SizedBox(height: AppConstants.paddingXL),
                  _buildErrorBanner(authState.errorMessage!),
                ],
                const SizedBox(height: 48),
                _buildTerms(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // App logo card
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B2D8B).withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 4,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/app_icon.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          _isSignUp ? 'Create Account' : 'Welcome Back',
          style: AppTextStyles.displayMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF6B2D8B),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _isSignUp
              ? 'Start your parenting journey with Moms of Tomorrow'
              : 'Sign in to continue your parenting journey',
          style: AppTextStyles.bodyMedium.copyWith(
            color: const Color(0xFF9B6BB5),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabToggle() {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF), // light lavender background
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          // Sliding indicator
          AnimatedAlign(
            alignment: _isSignUp ? Alignment.centerRight : Alignment.centerLeft,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF6B2D8B), // brand deep purple
                  borderRadius: BorderRadius.circular(21),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B2D8B).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Interactive tab texts
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_isSignUp) {
                      setState(() => _isSignUp = false);
                      ref.read(authNotifierProvider.notifier).clearError();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      'Sign In',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: _isSignUp ? const Color(0xFF6B2D8B) : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!_isSignUp) {
                      setState(() => _isSignUp = true);
                      ref.read(authNotifierProvider.notifier).clearError();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      'Sign Up',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: _isSignUp ? Colors.white : const Color(0xFF6B2D8B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesShowcase() {
    final features = [
      {'emoji': '👶', 'title': 'Milestone Tracker', 'desc': 'Track baby growth & developmental milestones'},
      {'emoji': '📅', 'title': 'Pregnancy Updates', 'desc': 'Get weekly pregnancy updates & tips'},
      {'emoji': '🥗', 'title': 'Nutrition Plans', 'desc': 'Access meal planners & dietitian guides'},
      {'emoji': '💜', 'title': 'Mom Community', 'desc': 'Connect with other moms & share advice'},
    ];

    return Container(
      key: const ValueKey('features_showcase'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3E8FF), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B2D8B).withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What you get:',
            style: AppTextStyles.titleMedium.copyWith(
              color: const Color(0xFF6B2D8B),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f['emoji']!, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f['title']!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6B2D8B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        f['desc']!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF9B6BB5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      key: const ValueKey('welcome_card'),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3E8FF), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B2D8B).withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '👋',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome back, Mama!',
            style: AppTextStyles.titleLarge.copyWith(
              color: const Color(0xFF6B2D8B),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We are so happy to see you again. Log in to continue tracking and connecting.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: const Color(0xFF9B6BB5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleButton(AuthState authState) {
    return GestureDetector(
      onTap: authState.isLoading ? null : _signInWithGoogle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: authState.isLoading
              ? AppColors.surface.withValues(alpha: 0.6)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: AppColors.divider, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (authState.isLoading)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2.5,
                ),
              )
            else ...[
              SvgPicture.asset(
                'assets/icons/google_logo.svg',
                width: 22,
                height: 22,
              ),
              const SizedBox(width: 12),
              Text(
                _isSignUp ? 'Sign up with Google' : 'Sign in with Google',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
            color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildTerms() {
    return Center(
      child: Text(
        'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textHint),
        textAlign: TextAlign.center,
      ),
    );
  }
}
