import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/providers/recipe_provider.dart';
import '../../../core/providers/dietary_preference_provider.dart';
import '../../../models/recipe_model.dart';
import 'recipe_detail_screen.dart';

class BookmarkedRecipesScreen extends ConsumerWidget {
  const BookmarkedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedRaw = ref.watch(bookmarkedRecipesProvider);
    final dietaryPref = ref.watch(dietaryPreferenceProvider);
    final bookmarked = bookmarkedRaw.where((r) => dietaryPref == DietaryPreference.both || r.isVeg).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
            Row(children: [
              Text('Saved Recipes', style: AppTextStyles.headlineMedium),
              const SizedBox(width: 6),
              const Text('🔖', style: TextStyle(fontSize: 18)),
            ]),
            Text('${bookmarked.length} recipe${bookmarked.length == 1 ? "" : "s"} saved', style: AppTextStyles.bodySmall),
          ],
        ),
      ),
      body: bookmarked.isEmpty
          ? _buildEmpty()
          : ListView.separated(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              itemCount: bookmarked.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppConstants.paddingM),
              itemBuilder: (context, index) => _RecipeListCard(recipe: bookmarked[index]),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: const Center(child: Text('🔖', style: TextStyle(fontSize: 36))),
          ),
          const SizedBox(height: AppConstants.paddingL),
          Text('No saved recipes yet', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 6),
          Text(
            'Tap the bookmark icon on any recipe\nto save it here',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RecipeListCard extends ConsumerWidget {
  final RecipeModel recipe;
  const _RecipeListCard({required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppConstants.radiusL),
              bottomLeft: Radius.circular(AppConstants.radiusL),
            ),
            child: Image.network(
              recipe.imageUrl,
              width: 90, height: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 90, height: 90,
                color: AppColors.primaryLight,
                child: const Center(child: Text('🍲', style: TextStyle(fontSize: 32))),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(recipe.name, style: AppTextStyles.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
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
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreenLight,
                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                    ),
                    child: Text(recipe.tag, style: AppTextStyles.labelSmall.copyWith(color: AppColors.accentGreen)),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.paddingM),
            child: GestureDetector(
              onTap: () => ref.read(bookmarksProvider.notifier).toggle(recipe.id),
              child: const Icon(Icons.bookmark_rounded, color: AppColors.primary, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
