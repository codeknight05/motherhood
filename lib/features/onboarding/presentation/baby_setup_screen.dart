import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/baby_provider.dart';
import '../../../core/widgets/main_shell.dart';

// ─── User role ────────────────────────────────────────────────────────────────

enum UserRole { pregnant, parent, family }

extension UserRoleExt on UserRole {
  String get label {
    switch (this) {
      case UserRole.pregnant: return 'I am pregnant';
      case UserRole.parent:   return 'I have a baby / child';
      case UserRole.family:   return 'I am a family member';
    }
  }

  String get subtitle {
    switch (this) {
      case UserRole.pregnant: return 'Track your pregnancy journey';
      case UserRole.parent:   return 'Track milestones & memories';
      case UserRole.family:   return 'Support & learn together';
    }
  }

  String get emoji {
    switch (this) {
      case UserRole.pregnant: return '🤰';
      case UserRole.parent:   return '👶';
      case UserRole.family:   return '👨‍👩‍👧';
    }
  }

  String get dbValue {
    switch (this) {
      case UserRole.pregnant: return 'pregnant';
      case UserRole.parent:   return 'parent';
      case UserRole.family:   return 'family';
    }
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class BabySetupScreen extends ConsumerStatefulWidget {
  const BabySetupScreen({super.key});

  @override
  ConsumerState<BabySetupScreen> createState() => _BabySetupScreenState();
}

class _BabySetupScreenState extends ConsumerState<BabySetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  int _step = 0;
  UserRole? _role;

  // Parent fields
  DateTime? _birthDate;
  String _gender = 'girl';
  File? _photoFile;

  // Pregnant fields
  DateTime? _dueDate;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  int get _totalSteps {
    if (_role == UserRole.family) return 1;
    return 2;
  }

  Future<void> _pickPhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PhotoPickerSheet(
        onCamera: () async {
          Navigator.pop(context);
          final f = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
          if (f != null && mounted) setState(() => _photoFile = File(f.path));
        },
        onGallery: () async {
          Navigator.pop(context);
          final f = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
          if (f != null && mounted) setState(() => _photoFile = File(f.path));
        },
      ),
    );
  }

  Future<void> _pickDate({required bool isDueDate}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isDueDate
          ? (now.add(const Duration(days: 60)))
          : (_birthDate ?? DateTime(now.year, now.month - 8)),
      firstDate: isDueDate ? now : DateTime(now.year - 10),
      lastDate: isDueDate ? now.add(const Duration(days: 300)) : now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary, onPrimary: Colors.white, surface: AppColors.surface),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isDueDate) { _dueDate = picked; }
        else { _birthDate = picked; }
      });
    }
  }

  Future<void> _saveAndContinue() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Save role to profile
    await Supabase.instance.client.from('profiles').upsert({
      'id': user.id,
      'role': _role!.dbValue,
      if (_dueDate != null) 'due_date': _dueDate!.toIso8601String().split('T').first,
      'updated_at': DateTime.now().toIso8601String(),
    });

    if (!mounted) return;

    if (_role == UserRole.family) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainShell(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (_) => false,
      );
      return;
    }

    if (_role == UserRole.pregnant) {
      await ref.read(babyProvider.notifier).createBaby(
        name: 'My Baby',
        birthDate: _dueDate ?? DateTime.now().add(const Duration(days: 90)),
        gender: _gender,
        isDueDate: true,
        dueDate: _dueDate,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainShell(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (_) => false,
      );
      return;
    }

    // Parent — save baby details
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your baby\'s birth date')),
      );
      return;
    }

    final success = await ref.read(babyProvider.notifier).createBaby(
      name: _nameController.text.trim().isEmpty ? 'My Baby' : _nameController.text.trim(),
      birthDate: _birthDate!,
      gender: _gender,
      heightCm: _heightController.text.isNotEmpty ? double.tryParse(_heightController.text) : null,
      weightKg: _weightController.text.isNotEmpty ? double.tryParse(_weightController.text) : null,
    );

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainShell(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (_) => false,
      );
    }
  }

  void _next() {
    if (_step == 0) {
      if (_role == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select who you are')),
        );
        return;
      }
      if (_role == UserRole.family) {
        _saveAndContinue();
        return;
      }
      setState(() => _step = 1);
    } else {
      _saveAndContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    final babyState = ref.watch(babyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_role != UserRole.family) _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingXXL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: AppConstants.paddingXL),
                      if (_step == 0) _buildRoleStep(),
                      if (_step == 1 && _role == UserRole.pregnant) _buildPregnantStep(),
                      if (_step == 1 && _role == UserRole.parent) _buildParentStep(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomBar(babyState),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titles = {
      null: 'Tell us about\nyourself',
      UserRole.pregnant: _step == 0 ? 'Tell us about\nyourself' : 'Your pregnancy',
      UserRole.parent: _step == 0 ? 'Tell us about\nyourself' : 'About your baby',
      UserRole.family: 'Tell us about\nyourself',
    };
    final subtitles = {
      null: 'So we can personalise your experience',
      UserRole.pregnant: _step == 0 ? 'So we can personalise your experience' : 'We\'ll track your journey week by week',
      UserRole.parent: _step == 0 ? 'So we can personalise your experience' : 'You can always update these later',
      UserRole.family: 'So we can personalise your experience',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppConstants.paddingXXL, AppConstants.paddingXL, AppConstants.paddingXXL, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14)),
            child: const Center(child: Text('💗', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(height: 16),
          Text(titles[_role] ?? 'Tell us about\nyourself', style: AppTextStyles.displayMedium),
          const SizedBox(height: 6),
          Text(subtitles[_role] ?? 'So we can personalise your experience', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppConstants.paddingXXL, AppConstants.paddingL, AppConstants.paddingXXL, 0),
      child: Row(
        children: List.generate(_totalSteps, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < _totalSteps - 1 ? 6 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 4,
                decoration: BoxDecoration(
                  color: i <= _step ? AppColors.primary : AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Step 0: Role selection ──────────────────────────────────────────────────

  Widget _buildRoleStep() {
    return Column(
      children: UserRole.values.map((role) {
        final isSelected = _role == role;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.paddingM),
          child: GestureDetector(
            onTap: () => setState(() => _role = role),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(AppConstants.paddingL),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryLight : AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.background,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Center(child: Text(role.emoji, style: const TextStyle(fontSize: 26))),
                  ),
                  const SizedBox(width: AppConstants.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(role.label, style: AppTextStyles.titleLarge.copyWith(color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text(role.subtitle, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: 2),
                    ),
                    child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Step 1: Pregnant ────────────────────────────────────────────────────────

  Widget _buildPregnantStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Expected due date', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppConstants.paddingS),
        _DatePickerField(
          date: _dueDate,
          hint: 'Select your due date',
          onTap: () => _pickDate(isDueDate: true),
        ),
        const SizedBox(height: AppConstants.paddingXL),
        if (_dueDate != null) ...[
          _PregnancyWeekCard(dueDate: _dueDate!),
          const SizedBox(height: AppConstants.paddingM),
        ],
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          decoration: BoxDecoration(
            color: AppColors.accentGreenLight,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          child: Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Text(
                  'You can add your baby\'s details after they are born.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 1: Parent ──────────────────────────────────────────────────────────

  Widget _buildParentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: GestureDetector(
            onTap: _pickPhoto,
            child: Stack(
              children: [
                Container(
                  width: 96, height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryLight,
                    border: Border.all(color: AppColors.primaryMid, width: 2),
                    image: _photoFile != null ? DecorationImage(image: FileImage(_photoFile!), fit: BoxFit.cover) : null,
                  ),
                  child: _photoFile == null ? const Center(child: Text('👶', style: TextStyle(fontSize: 38))) : null,
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
        Center(child: Padding(
          padding: const EdgeInsets.only(top: 6, bottom: AppConstants.paddingXL),
          child: Text('Add photo (optional)', style: AppTextStyles.bodySmall),
        )),
        Text('Baby\'s name', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppConstants.paddingS),
        TextFormField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: _inputDeco(hint: 'e.g. Aarohi (optional)', icon: Icons.child_care_rounded),
        ),
        const SizedBox(height: AppConstants.paddingXL),
        Text('Date of birth', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppConstants.paddingS),
        _DatePickerField(date: _birthDate, hint: 'Select birth date', onTap: () => _pickDate(isDueDate: false)),
        const SizedBox(height: AppConstants.paddingXL),
        Text('Gender', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppConstants.paddingM),
        Row(
          children: [
            _GenderChip(label: 'Girl', emoji: '👧', value: 'girl', selected: _gender, onTap: (v) => setState(() => _gender = v)),
            const SizedBox(width: AppConstants.paddingM),
            _GenderChip(label: 'Boy', emoji: '👦', value: 'boy', selected: _gender, onTap: (v) => setState(() => _gender = v)),
            const SizedBox(width: AppConstants.paddingM),
            _GenderChip(label: 'Other', emoji: '🌟', value: 'other', selected: _gender, onTap: (v) => setState(() => _gender = v)),
          ],
        ),
        const SizedBox(height: AppConstants.paddingXL),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Height (cm)', style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppConstants.paddingS),
                  TextFormField(
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}'))],
                    decoration: _inputDeco(hint: '67', icon: Icons.straighten_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Weight (kg)', style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppConstants.paddingS),
                  TextFormField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                    decoration: _inputDeco(hint: '7.6', icon: Icons.monitor_weight_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar(BabyState babyState) {
    String buttonLabel;
    if (_role == UserRole.family) {
      buttonLabel = 'Get Started 🎉';
    } else if (_step == 0) {
      buttonLabel = 'Continue →';
    } else {
      buttonLabel = 'Let\'s Go! 🎉';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(AppConstants.paddingXXL, AppConstants.paddingL, AppConstants.paddingXXL, AppConstants.paddingXXL),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          if (_step > 0)
            Padding(
              padding: const EdgeInsets.only(right: AppConstants.paddingM),
              child: OutlinedButton(
                onPressed: () => setState(() => _step--),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primaryMid),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                ),
                child: const Icon(Icons.arrow_back_rounded),
              ),
            ),
          Expanded(
            child: ElevatedButton(
              onPressed: babyState.isLoading ? null : _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                elevation: 0,
              ),
              child: babyState.isLoading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text(buttonLabel, style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      filled: true, fillColor: AppColors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM), borderSide: const BorderSide(color: AppColors.divider)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  final DateTime? date;
  final String hint;
  final VoidCallback onTap;

  const _DatePickerField({required this.date, required this.hint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: date != null ? AppColors.primary : AppColors.divider, width: date != null ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 18, color: date != null ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 10),
            Text(
              date != null ? DateFormat('d MMMM yyyy').format(date!) : hint,
              style: AppTextStyles.bodyMedium.copyWith(color: date != null ? AppColors.textPrimary : AppColors.textHint),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}

class _PregnancyWeekCard extends StatelessWidget {
  final DateTime dueDate;
  const _PregnancyWeekCard({required this.dueDate});

  @override
  Widget build(BuildContext context) {
    final daysLeft = dueDate.difference(DateTime.now()).inDays;
    final conceptionApprox = dueDate.subtract(const Duration(days: 280));
    final week = (DateTime.now().difference(conceptionApprox).inDays ~/ 7).clamp(1, 42);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        gradient: AppColors.softPurpleGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Row(
        children: [
          const Text('🤰', style: TextStyle(fontSize: 36)),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Week $week of pregnancy', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary)),
                Text(
                  daysLeft > 0 ? '$daysLeft days until your due date' : 'Due any day now!',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label, emoji, value, selected;
  final void Function(String) onTap;

  const _GenderChip({required this.label, required this.emoji, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: isSelected ? 1.5 : 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(label, style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPickerSheet extends StatelessWidget {
  final VoidCallback onCamera, onGallery;
  const _PhotoPickerSheet({required this.onCamera, required this.onGallery});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingL),
      padding: const EdgeInsets.all(AppConstants.paddingXL),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusXXL)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: AppConstants.paddingL),
          Text('Add Baby Photo', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppConstants.paddingXL),
          Row(
            children: [
              Expanded(child: _PhotoOption(icon: Icons.camera_alt_rounded, label: 'Camera', color: AppColors.primaryLight, iconColor: AppColors.primary, onTap: onCamera)),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(child: _PhotoOption(icon: Icons.photo_library_rounded, label: 'Gallery', color: AppColors.accentPinkLight, iconColor: AppColors.accentPink, onTap: onGallery)),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
        ],
      ),
    );
  }
}

class _PhotoOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, iconColor;
  final VoidCallback onTap;

  const _PhotoOption({required this.icon, required this.label, required this.color, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppConstants.radiusL)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 30),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.titleMedium.copyWith(color: iconColor)),
          ],
        ),
      ),
    );
  }
}
