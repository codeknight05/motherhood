import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/article_model.dart';

class ArticleDetailScreen extends StatefulWidget {
  final ArticleModel article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool _bookmarked = false;
  bool? _helpful; // true = yes, false = no

  @override
  Widget build(BuildContext context) {
    final a = widget.article;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(a),
          SliverToBoxAdapter(child: _buildHero(a)),
          SliverToBoxAdapter(child: _buildTableOfContents(a)),
          ...a.sections.map((s) => SliverToBoxAdapter(child: _buildSection(s))),
          SliverToBoxAdapter(child: _buildRemember(a)),
          SliverToBoxAdapter(child: _buildHelpful(a)),
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }

  // ── App bar ─────────────────────────────────────────────────────────────────

  Widget _buildAppBar(ArticleModel a) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.divider,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        a.title,
        style: AppTextStyles.headlineMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          icon: Icon(
            _bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: _bookmarked ? AppColors.primary : AppColors.textPrimary,
            size: 22,
          ),
          onPressed: () => setState(() => _bookmarked = !_bookmarked),
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary, size: 22),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textPrimary, size: 22),
          onPressed: () {},
        ),
      ],
    );
  }

  // ── Hero ────────────────────────────────────────────────────────────────────

  Widget _buildHero(ArticleModel a) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingL, AppConstants.paddingS,
        AppConstants.paddingL, AppConstants.paddingL,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: categories + title + subtitle + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category chips
                Wrap(
                  spacing: 6,
                  children: [
                    _CategoryChip(label: a.category, color: a.categoryColor),
                    if (a.secondaryCategory.isNotEmpty)
                      _CategoryChip(label: a.secondaryCategory, color: AppColors.accentBlue),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingS),
                Text(a.title, style: AppTextStyles.headlineLarge),
                const SizedBox(height: AppConstants.paddingS),
                Text(a.subtitle, style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppConstants.paddingM),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(a.readTime, style: AppTextStyles.labelSmall),
                    const SizedBox(width: AppConstants.paddingM),
                    const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(a.updatedLabel, style: AppTextStyles.labelSmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.paddingM),
          // Right: hero image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            child: Image.network(
              a.imageUrl,
              width: 110, height: 130,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 110, height: 130,
                color: AppColors.primaryLight,
                child: const Center(child: Icon(Icons.article_rounded, color: AppColors.primaryMid, size: 40)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Table of contents ───────────────────────────────────────────────────────

  Widget _buildTableOfContents(ArticleModel a) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppConstants.paddingL, 0, AppConstants.paddingL, AppConstants.paddingL,
      ),
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('In this article', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppConstants.paddingM),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: a.sections.map((s) => Padding(
                padding: const EdgeInsets.only(right: AppConstants.paddingL),
                child: SizedBox(
                  width: 60,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: s.colorLight, shape: BoxShape.circle),
                        child: Center(child: Text(s.emoji, style: const TextStyle(fontSize: 20))),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.title,
                        style: AppTextStyles.labelSmall,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section ─────────────────────────────────────────────────────────────────

  Widget _buildSection(ArticleSection s) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppConstants.paddingL, 0, AppConstants.paddingL, AppConstants.paddingM,
      ),
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number badge
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: s.colorLight, shape: BoxShape.circle),
            child: Center(
              child: Text(
                '${s.number}',
                style: TextStyle(color: s.color, fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s.title, style: AppTextStyles.headlineSmall),
                const SizedBox(height: AppConstants.paddingS),
                if (s.type == ArticleSectionType.text && s.body != null)
                  Text(s.body!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, height: 1.6)),
                if (s.type == ArticleSectionType.bulletList)
                  ...s.bullets.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 18, height: 18,
                          margin: const EdgeInsets.only(top: 1),
                          decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 11),
                        ),
                        const SizedBox(width: AppConstants.paddingS),
                        Expanded(child: Text(b, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary))),
                      ],
                    ),
                  )),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.paddingS),
          // Emoji illustration
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: s.colorLight, shape: BoxShape.circle),
            child: Center(child: Text(s.emoji, style: const TextStyle(fontSize: 26))),
          ),
        ],
      ),
    );
  }

  // ── Remember card ───────────────────────────────────────────────────────────

  Widget _buildRemember(ArticleModel a) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppConstants.paddingL, 0, AppConstants.paddingL, AppConstants.paddingL,
      ),
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.primaryMid.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Center(child: Text('💡', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Remember', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                const SizedBox(height: 3),
                Text(a.rememberText, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary, height: 1.5)),
              ],
            ),
          ),
          const Text('💜', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  // ── Helpful feedback ────────────────────────────────────────────────────────

  Widget _buildHelpful(ArticleModel a) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Was this article helpful?', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppConstants.paddingM),
          Row(
            children: [
              _HelpfulButton(
                icon: Icons.thumb_up_outlined,
                label: 'Yes',
                isSelected: _helpful == true,
                color: AppColors.accentGreen,
                onTap: () => setState(() => _helpful = _helpful == true ? null : true),
              ),
              const SizedBox(width: AppConstants.paddingM),
              _HelpfulButton(
                icon: Icons.thumb_down_outlined,
                label: 'No',
                isSelected: _helpful == false,
                color: AppColors.error,
                onTap: () => setState(() => _helpful = _helpful == false ? null : false),
              ),
              const Spacer(),
              Text(
                '${a.helpfulCount + (_helpful == true ? 1 : 0)} people found this helpful',
                style: AppTextStyles.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  const _CategoryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _HelpfulButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  const _HelpfulButton({required this.icon, required this.label, required this.isSelected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          border: Border.all(color: isSelected ? color : AppColors.divider, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? color : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.labelMedium.copyWith(color: isSelected ? color : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
