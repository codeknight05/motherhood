import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../admin/milestone_seed_screen.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/baby_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/app_card.dart';
import '../../../features/auth/presentation/login_screen.dart';
import '../../../core/widgets/notifications_sheet.dart';
import '../../../features/onboarding/presentation/baby_setup_screen.dart';
import '../../../models/baby_model.dart';
import 'help_faq_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final babyState = ref.watch(babyProvider);
    final baby = babyState.baby;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppConstants.paddingL),
                _buildUserCard(user),
                const SizedBox(height: AppConstants.paddingL),
                if (baby != null) _buildBabyCard(baby),
                if (baby == null) _buildNoBabyCard(context),
                const SizedBox(height: AppConstants.paddingXL),
                _buildSectionLabel('Account'),
                const SizedBox(height: AppConstants.paddingS),
                _buildMenuCard([
                  _MenuItem(icon: Icons.person_outline_rounded, label: 'Edit Profile', color: AppColors.primary, onTap: () => _showEditProfileSheet(context, user)),
                  _MenuItem(icon: Icons.child_care_rounded, label: 'Edit Baby Details', color: AppColors.accentPink, onTap: () => ProfileScreen.showEditBabySheet(context, ref, baby)),
                  _MenuItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    color: AppColors.accentOrange,
                    onTap: () {
                      final isPregnant = baby?.isExpected ?? false;
                      showNotificationsSheet(context, isPregnant: isPregnant);
                    },
                  ),
                ]),
                const SizedBox(height: AppConstants.paddingL),
                _buildSectionLabel('Data & Privacy'),
                const SizedBox(height: AppConstants.paddingS),
                _buildMenuCard([
                  _MenuItem(icon: Icons.refresh_rounded, label: 'Reset & Start Over', color: AppColors.warning, onTap: () => _confirmReset(context, ref)),
                  _MenuItem(icon: Icons.delete_outline_rounded, label: 'Delete All My Data', color: AppColors.error, onTap: () => _confirmDeleteAll(context, ref)),
                ]),
                // Developer tools — debug builds only
                if (kDebugMode) ...[
                  const SizedBox(height: AppConstants.paddingL),
                  _buildSectionLabel('Developer Tools'),
                  const SizedBox(height: AppConstants.paddingS),
                  _buildMenuCard([
                    _MenuItem(
                      icon: Icons.upload_rounded,
                      label: 'Seed Milestone Guidance',
                      color: AppColors.accentBlue,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MilestoneSeedScreen())),
                    ),
                  ]),
                ],
                const SizedBox(height: AppConstants.paddingL),
                _buildSectionLabel('Support'),
                const SizedBox(height: AppConstants.paddingS),
                _buildMenuCard([
                  _MenuItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & FAQ',
                    color: AppColors.accentBlue,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpFaqScreen())),
                  ),
                  _MenuItem(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    color: AppColors.accentBlue,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                  ),
                  _MenuItem(
                    icon: Icons.description_outlined,
                    label: 'Terms of Service',
                    color: AppColors.accentBlue,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsOfServiceScreen())),
                  ),
                ]),
                const SizedBox(height: AppConstants.paddingXL),
                _buildSignOutButton(context, ref),
                const SizedBox(height: AppConstants.paddingL),
                Center(child: Text('MotherHood v1.0.0', style: AppTextStyles.labelSmall)),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Profile', style: AppTextStyles.headlineMedium),
      centerTitle: true,
    );
  }

  Widget _buildUserCard(User? user) {
    final email = user?.email ?? '';
    final name = user?.userMetadata?['full_name'] as String? ??
        user?.userMetadata?['name'] as String? ??
        email.split('@').first;
    final avatar = user?.userMetadata?['avatar_url'] as String?;
    final provider = user?.appMetadata['provider'] as String? ?? 'email';

    return AppCard(
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
              border: Border.all(color: AppColors.primaryMid, width: 2),
            ),
            child: ClipOval(
              child: avatar != null
                  ? Image.network(avatar, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatarFallback(name))
                  : _avatarFallback(name),
            ),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, style: AppTextStyles.headlineSmall),
                Text(email, style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: provider == 'google' ? const Color(0xFFE8F0FE) : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(provider == 'google' ? '🔵' : '📧', style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 4),
                      Text(
                        provider == 'google' ? 'Google account' : 'Email account',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: provider == 'google' ? const Color(0xFF1A73E8) : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(String name) {
    return Container(
      color: AppColors.primaryLight,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '👤',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildBabyCard(BabyModel baby) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentPinkLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Center(child: Text(baby.gender == 'boy' ? '👦' : '👶', style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(baby.name, style: AppTextStyles.headlineSmall),
                    Text(baby.ageString, style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          const Divider(color: AppColors.divider),
          const SizedBox(height: AppConstants.paddingM),
          Wrap(
            spacing: AppConstants.paddingXL,
            runSpacing: AppConstants.paddingS,
            children: [
              if (baby.birthDate != null)
                _BabyDetail(label: 'Born', value: DateFormat('d MMM yyyy').format(baby.birthDate!)),
              if (baby.dueDate != null && baby.birthDate == null)
                _BabyDetail(label: 'Due date', value: DateFormat('d MMM yyyy').format(baby.dueDate!)),
              if (baby.heightCm != null)
                _BabyDetail(label: 'Height', value: '${baby.heightCm!.toInt()} cm'),
              if (baby.weightKg != null)
                _BabyDetail(label: 'Weight', value: '${baby.weightKg} kg'),
              _BabyDetail(label: 'Gender', value: baby.gender[0].toUpperCase() + baby.gender.substring(1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoBabyCard(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(AppConstants.radiusM)),
            child: const Center(child: Text('👶', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('No baby profile yet', style: AppTextStyles.titleLarge),
                Text('Add your baby\'s details to get started', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BabySetupScreen())),
            child: Text('Add', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(label, style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
    );
  }

  Widget _buildMenuCard(List<_MenuItem> items) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, color: item.color, size: 18),
                      ),
                      const SizedBox(width: AppConstants.paddingM),
                      Expanded(child: Text(item.label, style: AppTextStyles.titleMedium)),
                      Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 18),
                    ],
                  ),
                ),
              ),
              if (i < items.length - 1)
                const Divider(height: 1, indent: 68, color: AppColors.divider),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirmSignOut(context, ref),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text('Sign Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
          textStyle: AppTextStyles.titleMedium,
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _showEditProfileSheet(BuildContext context, User? user) {
    final nameController = TextEditingController(
      text: user?.userMetadata?['full_name'] as String? ?? '',
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditSheet(
        title: 'Edit Profile',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Display name', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.paddingS),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Your name',
                filled: true, fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM), borderSide: const BorderSide(color: AppColors.divider)),
              ),
            ),
            const SizedBox(height: AppConstants.paddingXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await Supabase.instance.client.auth.updateUser(
                    UserAttributes(data: {'full_name': nameController.text.trim()}),
                  );
                  final currentUser = Supabase.instance.client.auth.currentUser;
                  if (currentUser != null) {
                    await Supabase.instance.client
                        .from('profiles')
                        .update({'full_name': nameController.text.trim()})
                        .eq('id', currentUser.id);
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM))),
                child: Text('Save', style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showEditBabySheet(BuildContext context, WidgetRef ref, BabyModel? baby) {
    if (baby == null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const BabySetupScreen()));
      return;
    }
    final nameController = TextEditingController(text: baby.name);
    final heightController = TextEditingController(text: baby.heightCm?.toString() ?? '');
    final weightController = TextEditingController(text: baby.weightKg?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditSheet(
        title: 'Edit Baby Details',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.paddingS),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Baby\'s name',
                filled: true, fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM), borderSide: const BorderSide(color: AppColors.divider)),
              ),
            ),
            const SizedBox(height: AppConstants.paddingL),
            Row(
              children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Height (cm)', style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppConstants.paddingS),
                    TextField(
                      controller: heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '67',
                        filled: true, fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM), borderSide: const BorderSide(color: AppColors.divider)),
                      ),
                    ),
                  ],
                )),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weight (kg)', style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppConstants.paddingS),
                    TextField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '7.6',
                        filled: true, fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM), borderSide: const BorderSide(color: AppColors.divider)),
                      ),
                    ),
                  ],
                )),
              ],
            ),
            const SizedBox(height: AppConstants.paddingXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await Supabase.instance.client.from('babies').update({
                    'name': nameController.text.trim(),
                    if (heightController.text.isNotEmpty) 'height_cm': double.tryParse(heightController.text),
                    if (weightController.text.isNotEmpty) 'weight_kg': double.tryParse(weightController.text),
                  }).eq('id', baby.id);
                  await ref.read(babyProvider.notifier).loadBaby();
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM))),
                child: Text('Save Changes', style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    _showConfirmDialog(
      context: context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmLabel: 'Sign Out',
      confirmColor: AppColors.error,
      onConfirm: () async {
        await ref.read(authNotifierProvider.notifier).signOut();
        ref.read(babyProvider.notifier).clear();
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
        }
      },
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    _showConfirmDialog(
      context: context,
      title: 'Reset & Start Over',
      message: 'This will delete your baby profile and all associated data (milestones, memories, vaccinations). Your account will remain. You\'ll be taken back to the setup screen.\n\nThis cannot be undone.',
      confirmLabel: 'Reset',
      confirmColor: AppColors.warning,
      onConfirm: () async {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) return;
        // Delete all babies (cascades to milestones, memories, vaccinations)
        await Supabase.instance.client
            .from('babies')
            .delete()
            .eq('user_id', user.id);
        // Reset role in profile
        await Supabase.instance.client
            .from('profiles')
            .update({'role': 'parent', 'due_date': null})
            .eq('id', user.id);
        ref.read(babyProvider.notifier).clear();
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const BabySetupScreen()),
            (_) => false,
          );
        }
      },
    );
  }

  void _confirmDeleteAll(BuildContext context, WidgetRef ref) {
    _showConfirmDialog(
      context: context,
      title: 'Delete All My Data',
      message: 'This will permanently delete your account and ALL data including baby profiles, memories, milestones, and photos. This cannot be undone.',
      confirmLabel: 'Delete Everything',
      confirmColor: AppColors.error,
      onConfirm: () async {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) return;
        // Delete all user data (RLS cascades handle related tables)
        await Supabase.instance.client
            .from('babies')
            .delete()
            .eq('user_id', user.id);
        await Supabase.instance.client
            .from('profiles')
            .delete()
            .eq('id', user.id);
        // Sign out
        await Supabase.instance.client.auth.signOut();
        ref.read(babyProvider.notifier).clear();
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
        }
      },
    );
  }

  void _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusXL)),
        title: Text(title, style: AppTextStyles.headlineSmall),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(confirmLabel, style: AppTextStyles.titleMedium.copyWith(color: confirmColor, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.color, required this.onTap});
}

class _BabyDetail extends StatelessWidget {
  final String label, value;
  const _BabyDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.labelSmall),
        Text(value, style: AppTextStyles.titleMedium),
      ],
    );
  }
}

class _EditSheet extends StatelessWidget {
  final String title;
  final Widget child;
  const _EditSheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingL),
      padding: EdgeInsets.only(
        left: AppConstants.paddingXXL, right: AppConstants.paddingXXL,
        top: AppConstants.paddingXL, bottom: AppConstants.paddingXXL + bottomInset,
      ),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusXXL)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: AppConstants.paddingL),
            Text(title, style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppConstants.paddingXL),
            child,
          ],
        ),
      ),
    );
  }
}
