import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/providers/baby_provider.dart';
import '../../../core/providers/ai_recipes_provider.dart';
import '../../../core/providers/recipe_provider.dart';
import '../../../models/baby_model.dart';
import '../../../models/recipe_model.dart';
import 'recipe_detail_screen.dart';
import '../../../core/widgets/network_error_screen.dart';
import '../../../core/utils/network_connectivity.dart';

class AiRecipesScreen extends ConsumerStatefulWidget {
  final String? initialTheme;
  const AiRecipesScreen({super.key, this.initialTheme});

  @override
  ConsumerState<AiRecipesScreen> createState() => _AiRecipesScreenState();
}

class _AiRecipesScreenState extends ConsumerState<AiRecipesScreen> {
  String? _selectedTheme;

  static const List<Map<String, String>> _themes = [
    {'label': 'Surprise Me', 'emoji': '✨'},
    {'label': 'High Protein', 'emoji': '💪'},
    {'label': 'Iron Rich', 'emoji': '🥬'},
    {'label': 'Brain Boost', 'emoji': '🧠'},
    {'label': 'Immunity', 'emoji': '🛡️'},
    {'label': 'Weight Gain', 'emoji': '📈'},
    {'label': 'Finger Foods', 'emoji': '🤌'},
    {'label': 'Easy Digest', 'emoji': '🌿'},
  ];

  // Emoji placeholders for AI recipes (no image URL)
  static const List<String> _categoryEmojis = ['🍲', '🥣', '🍛', '🥗', '🍜', '🫕'];

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.initialTheme;
    // Only auto-generate if we have no recipes yet — don't fire on every open
    WidgetsBinding.instance.addPostFrameCallback((_) => _generateIfNeeded());
  }

  void _generateIfNeeded() {
    final aiState = ref.read(aiRecipesProvider);
    if (widget.initialTheme != null) {
      _generate(theme: widget.initialTheme);
    } else if (aiState.status == AiRecipesStatus.idle) {
      _generate();
    }
  }

  void _generate({String? theme}) async {
    final isConnected = await NetworkConnectivity.checkConnection();
    if (!mounted) return;

    if (!isConnected) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => NetworkErrorScreen(
            onRetry: () async {
              final recheck = await NetworkConnectivity.checkConnection();
              if (recheck) {
                if (ctx.mounted) Navigator.of(ctx).pop();
                _generate(theme: theme);
              }
            },
          ),
        ),
      );
      return;
    }

    final baby = ref.read(babyProvider).baby ?? sampleBaby;
    ref.read(aiRecipesProvider.notifier).generate(
      ageInMonths: baby.ageInMonths > 0 ? baby.ageInMonths : 8,
      focusTheme: theme == 'Surprise Me' ? null : theme,
      count: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiRecipesProvider);
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
                _buildHeroBanner(baby),
                const SizedBox(height: AppConstants.paddingL),
                _buildThemeSelector(),
                const SizedBox(height: AppConstants.paddingXL),
                if (aiState.isLoading)
                  _buildLoadingState()
                else if (aiState.hasError)
                  _buildErrorState(aiState.error!)
                else if (aiState.hasRecipes)
                  _buildRecipeList(aiState.recipes)
                else
                  _buildEmptyState(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BabyModel baby) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('AI Recipes', style: AppTextStyles.headlineMedium),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: const Text(
                  'Powered by Mumma',
                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          Text(
            'Fresh recipes for ${baby.name} · ${baby.ageString}',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Generate new recipes',
          icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
          onPressed: () => _generate(theme: _selectedTheme),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildHeroBanner(BabyModel baby) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Daily AI Recipes ✨',
                  style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mumma creates fresh, nutritious recipes tailored to ${baby.name}\'s age every time you tap Generate.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _generate(theme: _selectedTheme),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Generate Recipes',
                          style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text('🤖', style: TextStyle(fontSize: 52)),
        ],
      ),
    );
  }

  Widget _buildThemeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose a focus', style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppConstants.paddingM),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _themes.asMap().entries.map((entry) {
              final i = entry.key;
              final theme = entry.value;
              final label = theme['label']!;
              final isSelected = _selectedTheme == label ||
                  (_selectedTheme == null && label == 'Surprise Me');
              return Padding(
                padding: EdgeInsets.only(right: i < _themes.length - 1 ? AppConstants.paddingS : 0),
                child: GestureDetector(
                  onTap: () {
                    final newTheme = label == 'Surprise Me' ? null : label;
                    setState(() => _selectedTheme = newTheme);
                    // Immediately regenerate with the selected theme
                    _generate(theme: newTheme);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(theme['emoji']!, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 5),
                        Text(
                          label,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
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

  Widget _buildLoadingState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingXXL),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: AppConstants.paddingL),
              Text(
                _selectedTheme != null
                    ? 'Generating $_selectedTheme recipes... 🍳'
                    : 'Mumma is cooking up recipes... 🍳',
                style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Creating nutritious, age-appropriate recipes\njust for your baby.\nThis may take up to 30 seconds.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.paddingXL),
        ...List.generate(3, (_) => Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.paddingM),
          child: _SkeletonCard(),
        )),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('😕', style: TextStyle(fontSize: 32))),
            ),
            const SizedBox(height: AppConstants.paddingL),
            Text('Could not generate recipes', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
              child: Text(
                error,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppConstants.paddingXL),
            ElevatedButton.icon(
              onPressed: () => _generate(theme: _selectedTheme),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🤖', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppConstants.paddingL),
            Text('No recipes yet', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Tap Generate Recipes to get\nAI-powered recipes for your baby',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeList(List<RecipeModel> recipes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Today's AI Picks", style: AppTextStyles.headlineSmall),
                  Text(
                    '${recipes.length} recipes generated',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _generate(theme: _selectedTheme),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppColors.primaryMid),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Regenerate',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingM),
        ...recipes.asMap().entries.map((entry) {
          final emoji = _categoryEmojis[entry.key % _categoryEmojis.length];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.paddingM),
            child: _AiRecipeCard(recipe: entry.value, emoji: emoji),
          );
        }),
      ],
    );
  }
}

// ─── AI Recipe Card ───────────────────────────────────────────────────────────

class _AiRecipeCard extends ConsumerWidget {
  final RecipeModel recipe;
  final String emoji;

  const _AiRecipeCard({required this.recipe, required this.emoji});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = ref.watch(bookmarksProvider).contains(recipe.id);

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeDetailScreen(recipe: recipe, isAiGenerated: true),
        ),
      ),
      child: Row(
        children: [
          // Image/Emoji thumbnail
          Container(
            width: 90,
            height: 110,
            decoration: BoxDecoration(
              gradient: AppColors.softPurpleGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.radiusL),
                bottomLeft: Radius.circular(AppConstants.radiusL),
              ),
            ),
            child: recipe.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppConstants.radiusL),
                      bottomLeft: Radius.circular(AppConstants.radiusL),
                    ),
                    child: Image.network(
                      recipe.imageUrl,
                      width: 90,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 44)),
                      ),
                    ),
                  )
                : Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 44)),
                  ),
          ),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // AI badge + category
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                        ),
                        child: const Text(
                          '✨ AI',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          recipe.category.label,
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    recipe.name,
                    style: AppTextStyles.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Meta row
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text('${recipe.cookTimeMinutes} min', style: AppTextStyles.labelSmall),
                      const SizedBox(width: 8),
                      const Icon(Icons.local_fire_department_outlined, size: 12, color: AppColors.accentOrange),
                      const SizedBox(width: 3),
                      Text('${recipe.calories} cal', style: AppTextStyles.labelSmall),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Tag + bookmark
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreenLight,
                            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                          ),
                          child: Text(
                            recipe.tag,
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentGreen),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          ref.read(bookmarksProvider.notifier).toggle(recipe.id);
                          // Also persist the recipe so it shows in bookmarks
                          ref.read(aiBookmarkedRecipesProvider.notifier).upsert(recipe);
                          final nowBookmarked = ref.read(bookmarksProvider).contains(recipe.id);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(nowBookmarked
                                ? '${recipe.name} saved to bookmarks'
                                : 'Removed from bookmarks'),
                            backgroundColor: nowBookmarked ? AppColors.primary : AppColors.textSecondary,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            ),
                          ));
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            key: ValueKey(isBookmarked),
                            color: isBookmarked ? AppColors.primary : AppColors.textHint,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton loading card ────────────────────────────────────────────────────

class _SkeletonCard extends StatefulWidget {
  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 90,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusL),
                    bottomLeft: Radius.circular(AppConstants.radiusL),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(height: 12, width: 60, color: AppColors.divider),
                      const SizedBox(height: 8),
                      Container(height: 16, color: AppColors.divider),
                      const SizedBox(height: 6),
                      Container(height: 12, width: 120, color: AppColors.divider),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
