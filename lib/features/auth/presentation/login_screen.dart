import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();
    // Listen for auth state changes — catches Google OAuth completing
    _listenForAuthChange();
  }

  void _listenForAuthChange() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(sessionProvider, (previous, next) {
        next.whenData((session) async {
          if (session != null && mounted) {
            await _navigateAfterAuth();
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _navigateAfterAuth() async {
    // Upsert profile with name from auth metadata (Google name, email, etc.)
    final user = ref.read(sessionProvider).value?.user;
    if (user != null) {
      final meta = user.userMetadata ?? {};
      final name = meta['full_name'] as String? ??
          meta['name'] as String? ??
          meta['display_name'] as String?;
      final avatar = meta['avatar_url'] as String? ??
          meta['picture'] as String?;
      // Only upsert if we have something useful
      if (name != null || avatar != null) {
        try {
          await SupabaseService.upsertProfile(
            userId: user.id,
            fullName: name,
            avatarUrl: avatar,
          );
        } catch (_) {}
      }
    }

    await ref.read(babyProvider.notifier).loadBaby();
    if (!mounted) return;
    final hasBaby = ref.read(babyProvider).hasBaby;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => hasBaby ? const MainShell() : const BabySetupScreen()),
      (_) => false,
    );
  }

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authNotifierProvider.notifier);
    final success = _isSignUp
        ? await notifier.signUpWithEmail(
            _emailController.text.trim(), _passwordController.text)
        : await notifier.signInWithEmail(
            _emailController.text.trim(), _passwordController.text);

    if (success && mounted) {
      await _navigateAfterAuth();
    }
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
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingXXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              _buildHeader(),
              const SizedBox(height: 36),
              _buildGoogleButton(authState),
              const SizedBox(height: AppConstants.paddingXL),
              _buildDivider(),
              const SizedBox(height: AppConstants.paddingXL),
              _buildEmailForm(authState),
              if (authState.hasError) ...[
                const SizedBox(height: AppConstants.paddingM),
                _buildErrorBanner(authState.errorMessage!),
              ],
              const SizedBox(height: AppConstants.paddingXL),
              _buildSubmitButton(authState),
              const SizedBox(height: AppConstants.paddingL),
              _buildToggleMode(),
              const SizedBox(height: 40),
              _buildTerms(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
              child: Text('💗', style: TextStyle(fontSize: 28))),
        ),
        const SizedBox(height: 20),
        Text(
          _isSignUp ? 'Create account' : 'Welcome back',
          style: AppTextStyles.displayMedium,
        ),
        const SizedBox(height: 6),
        Text(
          _isSignUp
              ? 'Start your parenting journey with MotherHood'
              : 'Sign in to continue your parenting journey',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildGoogleButton(AuthState authState) {
    return GestureDetector(
      onTap: authState.isLoading ? null : _signInWithGoogle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: authState.isLoading
              ? AppColors.surface.withValues(alpha: 0.6)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: AppColors.divider, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/google_logo.svg',
              width: 22,
              height: 22,
            ),
            const SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or continue with email',
              style: AppTextStyles.bodySmall),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }

  Widget _buildEmailForm(AuthState authState) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !authState.isLoading,
            decoration: _inputDecoration(
              label: 'Email address',
              icon: Icons.email_outlined,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter your email';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: AppConstants.paddingM),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: _isSignUp ? TextInputAction.next : TextInputAction.done,
            onFieldSubmitted: _isSignUp ? null : (_) => _submitEmail(),
            enabled: !authState.isLoading,
            decoration: _inputDecoration(
              label: 'Password',
              icon: Icons.lock_outline_rounded,
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter your password';
              if (_isSignUp && v.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          // Confirm password — only shown during sign up
          if (_isSignUp) ...[
            const SizedBox(height: AppConstants.paddingM),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitEmail(),
              enabled: !authState.isLoading,
              decoration: _inputDecoration(
                label: 'Confirm password',
                icon: Icons.lock_outline_rounded,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm your password';
                if (v != _passwordController.text) return 'Passwords do not match';
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
      {required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon:
          Icon(icon, color: AppColors.textSecondary, size: 20),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide:
            const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide:
            const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
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

  Widget _buildSubmitButton(AuthState authState) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: authState.isLoading ? null : _submitEmail,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              AppColors.primary.withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusM)),
          elevation: 0,
        ),
        child: authState.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : Text(
                _isSignUp ? 'Create Account' : 'Sign In',
                style: AppTextStyles.titleMedium
                    .copyWith(color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildToggleMode() {
    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() => _isSignUp = !_isSignUp);
          _confirmPasswordController.clear();
          ref.read(authNotifierProvider.notifier).clearError();
        },
        child: RichText(
          text: TextSpan(
            style: AppTextStyles.bodyMedium,
            children: [
              TextSpan(
                  text: _isSignUp
                      ? 'Already have an account? '
                      : "Don't have an account? "),
              TextSpan(
                text: _isSignUp ? 'Sign In' : 'Sign Up',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTerms() {
    return Center(
      child: Text(
        'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
        style: AppTextStyles.labelSmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}


