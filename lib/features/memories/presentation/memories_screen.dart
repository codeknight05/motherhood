import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/baby_provider.dart';
import '../../../models/baby_model.dart';
import '../../../models/memory_model.dart';

class MemoriesScreen extends ConsumerStatefulWidget {
  const MemoriesScreen({super.key});

  @override
  ConsumerState<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends ConsumerState<MemoriesScreen> {
  final _picker = ImagePicker();
  final List<MemoryEntry> _memories = List.from(sampleMemories);
  MemoryTag? _selectedFilter;
  bool _isGridView = true;
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MemoryEntry> get _filtered {
    List<MemoryEntry> list = _memories;
    if (_selectedFilter != null) {
      list = list.where((m) => m.tag == _selectedFilter).toList();
    }
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((m) => m.caption?.toLowerCase().contains(query) ?? false).toList();
    }
    return list;
  }

  // Group memories by month label
  Map<String, List<MemoryEntry>> get _grouped {
    final map = <String, List<MemoryEntry>>{};
    for (final m in _filtered) {
      final key = _monthLabel(m.date);
      map.putIfAbsent(key, () => []).add(m);
    }
    return map;
  }

  String _monthLabel(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (file == null) return;
      if (!mounted) return;
      _showAddMemorySheet(file.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not access ${source == ImageSource.camera ? 'camera' : 'gallery'}. Check permissions.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SourcePickerSheet(
        onCamera: () {
          Navigator.pop(context);
          _pickImage(ImageSource.camera);
        },
        onGallery: () {
          Navigator.pop(context);
          _pickImage(ImageSource.gallery);
        },
      ),
    );
  }

  void _showAddMemorySheet(String imagePath) {
    final baby = ref.read(babyProvider).baby ?? sampleBaby;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMemorySheet(
        imagePath: imagePath,
        baby: baby,
        onSave: (entry) {
          setState(() => _memories.insert(0, entry));
        },
      ),
    );
  }

  void _openMemory(MemoryEntry memory) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _MemoryDetailScreen(memory: memory)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baby = ref.watch(babyProvider).baby ?? sampleBaby;
    final grouped = _grouped;

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
                _buildStatsRow(),
                const SizedBox(height: AppConstants.paddingL),
                _buildFilterChips(),
                const SizedBox(height: AppConstants.paddingXL),
                if (_filtered.isEmpty)
                  _buildEmptyState()
                else
                  ...grouped.entries.map((entry) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMonthHeader(entry.key),
                          const SizedBox(height: AppConstants.paddingM),
                          _isGridView
                              ? _buildMemoryGrid(entry.value)
                              : _buildMemoryList(entry.value),
                          const SizedBox(height: AppConstants.paddingXL),
                        ],
                      )),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildAppBar(BabyModel baby) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: AppConstants.paddingL,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search memories...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary, size: 20),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _isSearching = false;
                    });
                  },
                ),
              ),
              style: AppTextStyles.titleMedium,
              onChanged: (_) => setState(() {}),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text('Memory Diary', style: AppTextStyles.headlineLarge),
                    const SizedBox(width: 6),
                    const Text('📸', style: TextStyle(fontSize: 20)),
                  ],
                ),
                Text(
                  '${baby.name}\'s precious moments',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
      actions: [
        IconButton(
          icon: Icon(
            _isGridView ? Icons.list_alt_rounded : Icons.grid_view_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => setState(() => _isGridView = !_isGridView),
        ),
        if (!_isSearching)
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
            onPressed: () => setState(() => _isSearching = true),
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildStatsRow() {
    final baby = ref.watch(babyProvider).baby ?? sampleBaby;
    return Row(
      children: [
        Expanded(child: _StatCard(value: '${_memories.length}', label: 'Memories', emoji: '📸', color: AppColors.primaryLight, textColor: AppColors.primary)),
        const SizedBox(width: AppConstants.paddingM),
        Expanded(child: _StatCard(value: '${baby.ageInMonths}', label: 'Months old', emoji: '🎂', color: AppColors.accentPinkLight, textColor: AppColors.accentPink)),
        const SizedBox(width: AppConstants.paddingM),
        Expanded(child: _StatCard(value: '${_memories.where((m) => m.tag == MemoryTag.milestone).length}', label: 'Milestones', emoji: '🏆', color: AppColors.accentOrangeLight, textColor: AppColors.accentOrange)),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            emoji: '✨',
            isSelected: _selectedFilter == null,
            onTap: () => setState(() => _selectedFilter = null),
          ),
          const SizedBox(width: AppConstants.paddingS),
          ...MemoryTag.values.map((tag) => Padding(
                padding: const EdgeInsets.only(right: AppConstants.paddingS),
                child: _FilterChip(
                  label: tag.label,
                  emoji: tag.emoji,
                  isSelected: _selectedFilter == tag,
                  onTap: () => setState(() => _selectedFilter = _selectedFilter == tag ? null : tag),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(String month) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(month, style: AppTextStyles.headlineSmall),
        const SizedBox(width: 8),
        Text(
          '${_grouped[month]?.length ?? 0} photos',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildMemoryGrid(List<MemoryEntry> memories) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1,
      ),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index];
        return GestureDetector(
          onTap: () => _openMemory(memory),
          child: _MemoryGridTile(memory: memory),
        );
      },
    );
  }

  Widget _buildMemoryList(List<MemoryEntry> memories) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index];
        return GestureDetector(
          onTap: () => _openMemory(memory),
          child: Container(
            margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
            padding: const EdgeInsets.all(AppConstants.paddingM),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: memory.imagePath != null
                        ? Image.file(File(memory.imagePath!), fit: BoxFit.cover)
                        : memory.imageUrl != null
                            ? Image.network(
                                memory.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.primaryLight,
                                  child: const Icon(Icons.image_rounded, color: AppColors.primaryMid),
                                ),
                              )
                            : Container(
                                color: AppColors.primaryLight,
                                child: const Icon(Icons.image_rounded, color: AppColors.primaryMid),
                              ),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        memory.caption ?? 'Memory from ${memory.ageMonths} months',
                        style: AppTextStyles.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                            ),
                            child: Text(
                              '${memory.tag.emoji} ${memory.tag.label}',
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('d MMM yyyy').format(memory.date),
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('📷', style: TextStyle(fontSize: 36))),
            ),
            const SizedBox(height: AppConstants.paddingL),
            Text('No memories yet', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Tap the + button to add your first photo',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _showSourcePicker,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add_a_photo_rounded),
      label: Text('Add Memory', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
    );
  }
}

// ─── Grid Tile ───────────────────────────────────────────────────────────────

class _MemoryGridTile extends StatelessWidget {
  final MemoryEntry memory;

  const _MemoryGridTile({required this.memory});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          memory.imagePath != null
              ? Image.file(File(memory.imagePath!), fit: BoxFit.cover)
              : memory.imageUrl != null
                  ? Image.network(
                      memory.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primaryLight,
                        child: const Center(child: Icon(Icons.image_rounded, color: AppColors.primaryMid, size: 28)),
                      ),
                    )
                  : Container(
                      color: AppColors.primaryLight,
                      child: const Center(child: Icon(Icons.image_rounded, color: AppColors.primaryMid, size: 28)),
                    ),
          // Gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent],
                ),
              ),
            ),
          ),
          // Tag badge
          Positioned(
            top: 5,
            left: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(memory.tag.emoji, style: const TextStyle(fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Card ──────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String emoji;
  final Color color;
  final Color textColor;

  const _StatCard({
    required this.value,
    required this.label,
    required this.emoji,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.headlineMedium.copyWith(color: textColor)),
          Text(label, style: AppTextStyles.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Filter Chip ─────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
            Text(emoji, style: const TextStyle(fontSize: 13)),
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
    );
  }
}

// ─── Source Picker Sheet ─────────────────────────────────────────────────────

class _SourcePickerSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _SourcePickerSheet({required this.onCamera, required this.onGallery});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingL),
      padding: const EdgeInsets.all(AppConstants.paddingXL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppConstants.paddingL),
          Text('Add a Memory', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 6),
          Text('Choose how to add your photo', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppConstants.paddingXL),
          Row(
            children: [
              Expanded(
                child: _SourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: AppColors.primaryLight,
                  iconColor: AppColors.primary,
                  onTap: onCamera,
                ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: _SourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: AppColors.accentPinkLight,
                  iconColor: AppColors.accentPink,
                  onTap: onGallery,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
        ],
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.titleMedium.copyWith(color: iconColor)),
          ],
        ),
      ),
    );
  }
}

// ─── Add Memory Sheet ─────────────────────────────────────────────────────────

class _AddMemorySheet extends StatefulWidget {
  final String imagePath;
  final BabyModel baby;
  final void Function(MemoryEntry) onSave;

  const _AddMemorySheet({
    required this.imagePath,
    required this.baby,
    required this.onSave,
  });

  @override
  State<_AddMemorySheet> createState() => _AddMemorySheetState();
}

class _AddMemorySheetState extends State<_AddMemorySheet> {
  final _captionController = TextEditingController();
  MemoryTag _selectedTag = MemoryTag.everyday;
  bool _saving = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _save() {
    setState(() => _saving = true);
    final entry = MemoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      babyId: widget.baby.id,
      imagePath: widget.imagePath,
      caption: _captionController.text.trim().isEmpty ? null : _captionController.text.trim(),
      date: DateTime.now(),
      tag: _selectedTag,
      ageMonths: widget.baby.ageInMonths,
    );
    widget.onSave(entry);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingL),
      padding: EdgeInsets.only(
        left: AppConstants.paddingXL,
        right: AppConstants.paddingXL,
        top: AppConstants.paddingXL,
        bottom: AppConstants.paddingXL + bottomInset,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: AppConstants.paddingL),
            Text('Save Memory', style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppConstants.paddingXL),

            // Preview image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              child: Image.file(
                File(widget.imagePath),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: AppConstants.paddingXL),

            // Caption
            Text('Caption', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.paddingS),
            TextField(
              controller: _captionController,
              maxLines: 2,
              maxLength: 150,
              decoration: InputDecoration(
                hintText: 'Write something about this moment...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: BorderSide.none,
                ),
                counterStyle: AppTextStyles.labelSmall,
              ),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppConstants.paddingL),

            // Tag selector
            Text('Tag this memory', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.paddingM),
            Wrap(
              spacing: AppConstants.paddingS,
              runSpacing: AppConstants.paddingS,
              children: MemoryTag.values.map((tag) {
                final isSelected = _selectedTag == tag;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTag = tag),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(tag.emoji, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 5),
                        Text(
                          tag.label,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppConstants.paddingXXL),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Save Memory 💾', style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Memory Detail Screen ─────────────────────────────────────────────────────

class _MemoryDetailScreen extends StatelessWidget {
  final MemoryEntry memory;

  const _MemoryDetailScreen({required this.memory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen image
          Positioned.fill(
            child: InteractiveViewer(
              child: memory.imagePath != null
                  ? Image.file(File(memory.imagePath!), fit: BoxFit.contain)
                  : memory.imageUrl != null
                      ? Image.network(memory.imageUrl!, fit: BoxFit.contain)
                      : const Center(child: Icon(Icons.image_rounded, color: Colors.white54, size: 64)),
            ),
          ),
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM, vertical: AppConstants.paddingS),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
                      ),
                      onPressed: () async {
                        final text = '${memory.caption ?? 'A beautiful memory'} 📸\n\n'
                            'Captured at ${memory.ageMonths} months old.\n\n'
                            'Shared from MotherHood 💗';
                        await Share.share(text);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.paddingXL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(memory.tag.emoji, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                memory.tag.label,
                                style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (memory.ageMonths != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                            ),
                            child: Text(
                              '${memory.ageMonths} months old',
                              style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    if (memory.caption != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        memory.caption!,
                        style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(memory.date),
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
