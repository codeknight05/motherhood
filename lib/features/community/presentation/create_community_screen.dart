import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import 'communities_list_screen.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedEmoji = '💬';
  String _selectedCategory = 'Parenting';
  Color _selectedColor = AppColors.primary;
  Color _selectedColorLight = AppColors.primaryLight;
  bool _isCreating = false;

  static const _categories = [
    'Pregnancy', 'Parenting', 'Health', 'Humor', 'Culture', 'Lifestyle', 'Other',
  ];

  static const _emojiOptions = [
    '💬', '👶', '🤱', '👨‍👧', '👩‍👦', '🍼', '🌸', '💜',
    '🌟', '🎉', '🏡', '🌈', '🦁', '🐣', '🍀', '💪',
    '😴', '🧸', '🎀', '🪔', '💼', '🤝', '🌺', '💩',
  ];

  static const _colorOptions = [
    {'color': AppColors.primary, 'light': AppColors.primaryLight},
    {'color': Color(0xFF1565C0), 'light': Color(0xFFE3F2FD)},
    {'color': AppColors.accentPink, 'light': AppColors.accentPinkLight},
    {'color': AppColors.accentGreen, 'light': AppColors.accentGreenLight},
    {'color': AppColors.accentOrange, 'light': AppColors.accentOrangeLight},
    {'color': Color(0xFF5C6BC0), 'light': Color(0xFFE8EAF6)},
    {'color': Color(0xFF6D4C41), 'light': Color(0xFFEFEBE9)},
    {'color': Color(0xFFE53935), 'light': Color(0xFFFFEBEE)},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool get _canCreate =>
      _nameController.text.trim().length >= 3 &&
      _descController.text.trim().length >= 10;

  void _create() async {
    if (!_canCreate) return;
    setState(() => _isCreating = true);
    await Future.delayed(const Duration(milliseconds: 600)); // simulate save

    final newCommunity = CommunityInfo(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      emoji: _selectedEmoji,
      color: _selectedColor,
      colorLight: _selectedColorLight,
      memberCount: 1,
      activeCount: 1,
      category: _selectedCategory,
      isJoined: true,
      tags: [_selectedCategory],
    );

    if (mounted) Navigator.pop(context, newCommunity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.divider,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Create Community', style: AppTextStyles.headlineMedium),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.paddingM),
            child: TextButton(
              onPressed: _canCreate && !_isCreating ? _create : null,
              style: TextButton.styleFrom(
                backgroundColor: _canCreate ? AppColors.primary : AppColors.divider,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
              ),
              child: _isCreating
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Create', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview card
            _buildPreview(),
            const SizedBox(height: AppConstants.paddingXL),

            // Name
            _buildLabel('Community Name *'),
            const SizedBox(height: AppConstants.paddingS),
            _buildTextField(
              controller: _nameController,
              hint: 'e.g. Diaper Changers, Working Dads...',
              maxLength: 40,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppConstants.paddingXL),

            // Description
            _buildLabel('Description *'),
            const SizedBox(height: AppConstants.paddingS),
            _buildTextField(
              controller: _descController,
              hint: 'What is this community about? Who should join?',
              maxLines: 3,
              maxLength: 200,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppConstants.paddingXL),

            // Emoji picker
            _buildLabel('Pick an Emoji'),
            const SizedBox(height: AppConstants.paddingS),
            _buildEmojiPicker(),
            const SizedBox(height: AppConstants.paddingXL),

            // Color picker
            _buildLabel('Theme Color'),
            const SizedBox(height: AppConstants.paddingS),
            _buildColorPicker(),
            const SizedBox(height: AppConstants.paddingXL),

            // Category
            _buildLabel('Category'),
            const SizedBox(height: AppConstants.paddingS),
            _buildCategoryPicker(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final name = _nameController.text.trim().isEmpty ? 'Your Community' : _nameController.text.trim();
    final desc = _descController.text.trim().isEmpty
        ? 'Your community description will appear here.'
        : _descController.text.trim();

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: _selectedColorLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: _selectedColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: _selectedColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Center(child: Text(_selectedEmoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.titleLarge),
                const SizedBox(height: 3),
                Text(desc, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _selectedColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                      ),
                      child: Text(
                        _selectedCategory,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _selectedColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingS),
                    const Icon(Icons.people_outline_rounded, size: 12, color: AppColors.textHint),
                    const SizedBox(width: 3),
                    Text('1 member', style: AppTextStyles.labelSmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: AppTextStyles.titleMedium);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.surface,
        counterStyle: AppTextStyles.labelSmall,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildEmojiPicker() {
    return Wrap(
      spacing: AppConstants.paddingS,
      runSpacing: AppConstants.paddingS,
      children: _emojiOptions.map((emoji) {
        final isSelected = _selectedEmoji == emoji;
        return GestureDetector(
          onTap: () => setState(() => _selectedEmoji = emoji),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isSelected ? _selectedColorLight : AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(
                color: isSelected ? _selectedColor : AppColors.divider,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: AppConstants.paddingM,
      runSpacing: AppConstants.paddingM,
      children: _colorOptions.map((pair) {
        final color = pair['color'] as Color;
        final light = pair['light'] as Color;
        final isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedColor = color;
            _selectedColorLight = light;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.textPrimary : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))]
                  : [],
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryPicker() {
    return Wrap(
      spacing: AppConstants.paddingS,
      runSpacing: AppConstants.paddingS,
      children: _categories.map((cat) {
        final isSelected = _selectedCategory == cat;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
            ),
            child: Text(
              cat,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
