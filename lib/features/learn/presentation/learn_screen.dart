import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/knowledge_hub_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../models/knowledge_resource_model.dart';
import 'resource_webview_screen.dart';
import 'youtube_player_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  late Future<List<KnowledgeResource>> _resourcesFuture;
  final _searchController = TextEditingController();
  String? _selectedCategory;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _resourcesFuture = KnowledgeHubService.fetchResources();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<List<KnowledgeResource>>(
        future: _resourcesFuture,
        builder: (context, snapshot) {
          final resources = snapshot.data ?? fallbackKnowledgeResources;
          final visible = _filter(resources);
          final featured = resources.where((r) => r.isFeatured).toList();
          final postpartum = resources
              .where((r) => r.category == 'Postpartum')
              .toList();
          final videos = resources
              .where((r) => r.resourceType.toLowerCase().contains('video'))
              .toList();
          final audio = resources
              .where((r) => r.resourceType.toLowerCase().contains('audio'))
              .toList();
          final trending = resources.where((r) => r.isTrending).toList();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              setState(() {
                _resourcesFuture = KnowledgeHubService.fetchResources(
                  forceRefresh: true,
                );
              });
              await _resourcesFuture;
            },
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingL,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: AppConstants.paddingL),
                      _buildSearchBar(),
                      const SizedBox(height: AppConstants.paddingXL),
                      _buildCategories(resources),
                      const SizedBox(height: AppConstants.paddingXL),
                      if (_query.isEmpty && _selectedCategory == null) ...[
                        _buildFeaturedResources(featured),
                        const SizedBox(height: AppConstants.paddingXL),
                        _buildPostpartumSection(postpartum),
                        const SizedBox(height: AppConstants.paddingXL),
                        _buildMediaSection(
                          title: 'Watch',
                          resources: videos,
                          icon: Icons.play_circle_rounded,
                        ),
                        const SizedBox(height: AppConstants.paddingXL),
                        _buildMediaSection(
                          title: 'Listen',
                          resources: audio,
                          icon: Icons.headphones_rounded,
                        ),
                        const SizedBox(height: AppConstants.paddingXL),
                        _buildTrending(trending),
                        const SizedBox(height: AppConstants.paddingXL),
                      ],
                      _buildResourceList(visible),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<KnowledgeResource> _filter(List<KnowledgeResource> resources) {
    return resources.where((resource) {
      final matchesCategory =
          _selectedCategory == null || resource.category == _selectedCategory;
      final text = [
        resource.title,
        resource.description,
        resource.category,
        resource.sourceName,
      ].join(' ').toLowerCase();
      final matchesSearch = _query.isEmpty || text.contains(_query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> _openResource(KnowledgeResource resource) async {
    final type = resource.resourceType.toLowerCase();
    final isVideo = type.contains('video');

    if (isVideo && isYouTubeUrl(resource.sourceUrl)) {
      // YouTube → in-app YouTube iframe player
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => YouTubePlayerScreen(resource: resource),
        ),
      );
      return;
    }

    // Everything else (articles, guides, audio, non-YouTube video)
    // → in-app WebView
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResourceWebViewScreen(resource: resource),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: AppConstants.paddingL,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Knowledge Hub', style: AppTextStyles.headlineLarge),
          Text(
            'Evidence-based resources from trusted sources',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.divider),
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search resources, topics, sources...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textHint,
            size: 20,
          ),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: _searchController.clear,
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildCategories(List<KnowledgeResource> resources) {
    final categories = <String, int>{};
    for (final resource in resources) {
      categories[resource.category] = (categories[resource.category] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Browse by Category',
          actionLabel: _selectedCategory == null ? null : 'Clear',
          onAction: () => setState(() => _selectedCategory = null),
        ),
        const SizedBox(height: AppConstants.paddingM),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categories.entries.map((entry) {
              final category = entry.key;
              final selected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: AppConstants.paddingL),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = selected ? null : category;
                    });
                  },
                  child: SizedBox(
                    width: 82,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: selected
                                ? KnowledgeResource.colorForCategory(category)
                                : KnowledgeResource.lightColorForCategory(
                                    category,
                                  ),
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusM,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              KnowledgeResource.emojiForCategory(category),
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          category,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${entry.value} resources',
                          style: AppTextStyles.labelSmall,
                          textAlign: TextAlign.center,
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

  Widget _buildFeaturedResources(List<KnowledgeResource> resources) {
    if (resources.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Featured Resources'),
        const SizedBox(height: AppConstants.paddingM),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: resources.map((resource) {
              return Padding(
                padding: const EdgeInsets.only(right: AppConstants.paddingM),
                child: SizedBox(
                  width: 220,
                  child: _ResourceImageCard(
                    resource: resource,
                    onTap: () => _openResource(resource),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPostpartumSection(List<KnowledgeResource> resources) {
    if (resources.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Postpartum Knowledge'),
        const SizedBox(height: AppConstants.paddingM),
        AppCard(
          color: const Color(0xFFFFEBEE),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('💗', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingM),
                  Expanded(
                    child: Text(
                      'Recovery, mental health, movement, feeding, and care after birth.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingL),
              ...resources
                  .take(3)
                  .map(
                    (resource) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.paddingS,
                      ),
                      child: _CompactResourceTile(
                        resource: resource,
                        onTap: () => _openResource(resource),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrending(List<KnowledgeResource> resources) {
    if (resources.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Frequently Used'),
        const SizedBox(height: AppConstants.paddingM),
        ...resources
            .take(3)
            .map(
              (resource) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
                child: _CompactResourceTile(
                  resource: resource,
                  onTap: () => _openResource(resource),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildMediaSection({
    required String title,
    required List<KnowledgeResource> resources,
    required IconData icon,
  }) {
    if (resources.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: AppConstants.paddingM),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: resources.map((resource) {
              return Padding(
                padding: const EdgeInsets.only(right: AppConstants.paddingM),
                child: SizedBox(
                  width: 210,
                  child: _MediaResourceCard(
                    resource: resource,
                    icon: icon,
                    onTap: () => _openResource(resource),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildResourceList(List<KnowledgeResource> resources) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title:
              _selectedCategory ??
              (_query.isEmpty ? 'All Resources' : 'Results'),
        ),
        const SizedBox(height: AppConstants.paddingM),
        if (resources.isEmpty)
          AppCard(
            child: Row(
              children: [
                const Icon(Icons.search_off_rounded, color: AppColors.primary),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: Text(
                    'No resources found. Try another topic or category.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          )
        else
          ...resources.map(
            (resource) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.paddingM),
              child: _ResourceListCard(
                resource: resource,
                onTap: () => _openResource(resource),
              ),
            ),
          ),
      ],
    );
  }
}

class _ResourceImageCard extends StatelessWidget {
  final KnowledgeResource resource;
  final VoidCallback onTap;

  const _ResourceImageCard({required this.resource, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = KnowledgeResource.colorForCategory(resource.category);

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.radiusL),
                  topRight: Radius.circular(AppConstants.radiusL),
                ),
                child: Image.network(
                  resource.imageUrl,
                  height: 118,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 118,
                    color: KnowledgeResource.lightColorForCategory(
                      resource.category,
                    ),
                    child: Center(
                      child: Text(
                        KnowledgeResource.emojiForCategory(resource.category),
                        style: const TextStyle(fontSize: 34),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: _CategoryPill(label: resource.category, color: color),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title,
                  style: AppTextStyles.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  resource.description,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _ResourceMeta(resource: resource),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceListCard extends StatelessWidget {
  final KnowledgeResource resource;
  final VoidCallback onTap;

  const _ResourceListCard({required this.resource, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = KnowledgeResource.colorForCategory(resource.category);

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: KnowledgeResource.lightColorForCategory(resource.category),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Center(
              child: Text(
                KnowledgeResource.emojiForCategory(resource.category),
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CategoryPill(label: resource.category, color: color),
                const SizedBox(height: 6),
                Text(resource.title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 4),
                Text(
                  resource.description,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _ResourceMeta(resource: resource),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.paddingS),
          const Icon(
            Icons.open_in_new_rounded,
            color: AppColors.textHint,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _MediaResourceCard extends StatelessWidget {
  final KnowledgeResource resource;
  final IconData icon;
  final VoidCallback onTap;

  const _MediaResourceCard({
    required this.resource,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = KnowledgeResource.colorForCategory(resource.category);

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.radiusL),
                  topRight: Radius.circular(AppConstants.radiusL),
                ),
                child: Image.network(
                  resource.imageUrl,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 110,
                    color: KnowledgeResource.lightColorForCategory(
                      resource.category,
                    ),
                    child: Center(child: Icon(icon, color: color, size: 42)),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CategoryPill(label: resource.resourceType, color: color),
                const SizedBox(height: 6),
                Text(
                  resource.title,
                  style: AppTextStyles.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                _ResourceMeta(resource: resource),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactResourceTile extends StatelessWidget {
  final KnowledgeResource resource;
  final VoidCallback onTap;

  const _CompactResourceTile({required this.resource, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppConstants.paddingM),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title,
                  style: AppTextStyles.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                _ResourceMeta(resource: resource),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.paddingS),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textHint,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final Color color;

  const _CategoryPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ResourceMeta extends StatelessWidget {
  final KnowledgeResource resource;

  const _ResourceMeta({required this.resource});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _MetaItem(icon: Icons.verified_outlined, label: resource.sourceName),
        _MetaItem(icon: Icons.access_time_rounded, label: resource.readTime),
        _MetaItem(icon: Icons.article_outlined, label: resource.resourceType),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}
