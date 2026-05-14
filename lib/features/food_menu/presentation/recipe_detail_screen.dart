import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/recipe_model.dart';

class RecipeDetailScreen extends StatefulWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _isBookmarked = false;
  bool _showFullDescription = false;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.recipe.isBookmarked;
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildHeroAppBar(recipe),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppConstants.paddingL),
                _buildTitleRow(recipe),
                const SizedBox(height: AppConstants.paddingM),
                _buildMetaChips(recipe),
                const SizedBox(height: AppConstants.paddingXL),
                _buildDescription(recipe),
                const SizedBox(height: AppConstants.paddingXL),
                _buildIngredients(recipe),
                const SizedBox(height: AppConstants.paddingXL),
                _buildSteps(recipe),
                const SizedBox(height: AppConstants.paddingXL),
                _buildHowToServe(recipe),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAppBar(RecipeModel recipe) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textPrimary),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => setState(() => _isBookmarked = !_isBookmarked),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                size: 18,
                color: _isBookmarked ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.ios_share_rounded, size: 16, color: AppColors.textPrimary),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              recipe.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.primaryLight,
                child: const Center(child: Text('🍲', style: TextStyle(fontSize: 64))),
              ),
            ),
            // Bottom gradient
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppColors.background, Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow(RecipeModel recipe) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(recipe.name, style: AppTextStyles.displayMedium),
        ),
        const SizedBox(width: AppConstants.paddingM),
        GestureDetector(
          onTap: () {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.flag_rounded, color: AppColors.error, size: 16),
              const SizedBox(width: 4),
              Text(
                'Report Content',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaChips(RecipeModel recipe) {
    return Row(
      children: [
        _MetaChip(
          icon: Icons.timer_outlined,
          label: '${recipe.cookTimeMinutes} mins',
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppConstants.paddingL),
        _MetaChip(
          icon: Icons.local_fire_department_outlined,
          label: '${recipe.calories} cal',
          color: AppColors.accentOrange,
        ),
        const SizedBox(width: AppConstants.paddingL),
        _MetaChip(
          icon: Icons.menu_book_outlined,
          label: recipe.tag,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildDescription(RecipeModel recipe) {
    final isLong = recipe.description.length > 120;
    final displayText = (!_showFullDescription && isLong)
        ? '${recipe.description.substring(0, 120)}...'
        : recipe.description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppConstants.paddingS),
        RichText(
          text: TextSpan(
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            children: [
              TextSpan(text: displayText),
              if (isLong)
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => setState(() => _showFullDescription = !_showFullDescription),
                    child: Text(
                      _showFullDescription ? ' Show Less' : ' Show More',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIngredients(RecipeModel recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ingredients', style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppConstants.paddingM),
        ...recipe.ingredients.map((ing) => _IngredientRow(ingredient: ing)),
      ],
    );
  }

  Widget _buildSteps(RecipeModel recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step by step', style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppConstants.paddingM),
        ...recipe.steps.map((step) => _StepCard(step: step)),
      ],
    );
  }

  Widget _buildHowToServe(RecipeModel recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How to serve', style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppConstants.paddingS),
        Text(
          recipe.howToServe,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
      ],
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final RecipeIngredient ingredient;

  const _IngredientRow({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
      child: Row(
        children: [
          // Ingredient icon placeholder
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentGreenLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: ingredient.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    child: Image.network(ingredient.imageUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(child: Text('🥗', style: TextStyle(fontSize: 20)))),
                  )
                : const Center(child: Text('🥗', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Text(ingredient.name, style: AppTextStyles.titleMedium),
          ),
          Text(
            ingredient.quantity,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatefulWidget {
  final RecipeStep step;
  const _StepCard({required this.step});

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingL,
            vertical: AppConstants.paddingM,
          ),
          decoration: BoxDecoration(
            color: _expanded ? AppColors.primaryLight : AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(
              color: _expanded ? AppColors.primary : AppColors.divider,
              width: _expanded ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: _expanded ? AppColors.primary : AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.step.stepNumber}',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: _expanded ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingM),
                  Expanded(
                    child: Text(
                      widget.step.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: _expanded ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less_rounded : Icons.play_arrow_rounded,
                    color: _expanded ? AppColors.primary : AppColors.accentOrange,
                    size: 20,
                  ),
                ],
              ),
              if (_expanded && widget.step.description != null) ...[
                const SizedBox(height: AppConstants.paddingS),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Text(
                    widget.step.description!,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
