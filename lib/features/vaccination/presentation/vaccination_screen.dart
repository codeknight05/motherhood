import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/providers/baby_provider.dart';
import '../../../models/vaccination_model.dart';
import '../../../models/baby_model.dart';

class VaccinationScreen extends ConsumerStatefulWidget {
  const VaccinationScreen({super.key});

  @override
  ConsumerState<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends ConsumerState<VaccinationScreen> {
  List<VaccineRecord> _records = [];
  bool _loading = true;
  String _filter = 'All'; // All, Due, Given, Upcoming, Overdue

  final List<String> _filters = ['All', 'Due', 'Overdue', 'Upcoming', 'Given'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadVaccinations());
  }

  Future<void> _loadVaccinations() async {
    final baby = ref.read(babyProvider).baby;
    if (baby == null || baby.birthDate == null) {
      setState(() => _loading = false);
      return;
    }

    setState(() => _loading = true);
    try {
      // Try loading from Supabase first
      final res = await Supabase.instance.client
          .from('vaccinations')
          .select()
          .eq('baby_id', baby.id)
          .order('due_date');

      if ((res as List).isNotEmpty) {
        _records = res.map((r) => VaccineRecord(
          id: r['id'] as String,
          babyId: r['baby_id'] as String,
          vaccineName: r['vaccine_name'] as String,
          disease: r['notes'] as String? ?? '',
          dueDate: DateTime.parse(r['due_date'] as String),
          givenDate: r['given_date'] != null ? DateTime.parse(r['given_date'] as String) : null,
          doseNumber: 1,
        )).toList();
      } else {
        // First time — generate from schedule and save to Supabase
        final schedule = generateVaccinationSchedule(baby.id, baby.birthDate!);
        await _saveScheduleToSupabase(schedule, baby);
        _records = schedule;
      }
    } catch (_) {
      // Fallback to generated schedule if DB fails
      if (baby.birthDate != null) {
        _records = generateVaccinationSchedule(baby.id, baby.birthDate!);
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveScheduleToSupabase(List<VaccineRecord> schedule, BabyModel baby) async {
    final rows = schedule.map((v) => {
      'baby_id': baby.id,
      'vaccine_name': v.vaccineName,
      'due_date': v.dueDate.toIso8601String().split('T').first,
      'notes': v.disease,
    }).toList();

    await Supabase.instance.client.from('vaccinations').insert(rows);
  }

  Future<void> _markAsGiven(VaccineRecord record) async {
    final now = DateTime.now();
    try {
      await Supabase.instance.client
          .from('vaccinations')
          .update({'given_date': now.toIso8601String().split('T').first})
          .eq('id', record.id);
    } catch (_) {}

    setState(() {
      final idx = _records.indexWhere((r) => r.id == record.id);
      if (idx != -1) {
        _records[idx] = record.copyWith(givenDate: now);
      }
    });
  }

  List<VaccineRecord> get _filtered {
    if (_filter == 'All') return _records;
    return _records.where((r) {
      switch (_filter) {
        case 'Due': return r.status == VaccineStatus.due;
        case 'Overdue': return r.status == VaccineStatus.overdue;
        case 'Upcoming': return r.status == VaccineStatus.upcoming;
        case 'Given': return r.status == VaccineStatus.given;
        default: return true;
      }
    }).toList();
  }

  int get _givenCount => _records.where((r) => r.status == VaccineStatus.given).length;
  int get _overdueCount => _records.where((r) => r.status == VaccineStatus.overdue).length;
  int get _dueCount => _records.where((r) => r.status == VaccineStatus.due).length;

  @override
  Widget build(BuildContext context) {
    final baby = ref.watch(babyProvider).baby;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppConstants.paddingL),
                if (baby?.birthDate == null)
                  _buildNoBabyState()
                else ...[
                  _buildStatsRow(),
                  const SizedBox(height: AppConstants.paddingL),
                  _buildFilterChips(),
                  const SizedBox(height: AppConstants.paddingL),
                  if (_loading)
                    const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
                    ))
                  else if (_filtered.isEmpty)
                    _buildEmptyState()
                  else
                    ..._filtered.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
                      child: _VaccineCard(
                        record: r,
                        onMarkGiven: () => _markAsGiven(r),
                      ),
                    )),
                ],
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
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
          Row(children: [
            Text('Vaccination Tracker', style: AppTextStyles.headlineMedium),
            const SizedBox(width: 6),
            const Text('💉', style: TextStyle(fontSize: 18)),
          ]),
          Text('Indian immunisation schedule', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _StatCard(value: '$_givenCount', label: 'Given', emoji: '✅', color: AppColors.accentGreenLight, textColor: AppColors.accentGreen)),
        const SizedBox(width: AppConstants.paddingM),
        Expanded(child: _StatCard(value: '$_dueCount', label: 'Due Now', emoji: '📅', color: AppColors.primaryLight, textColor: AppColors.primary)),
        const SizedBox(width: AppConstants.paddingM),
        Expanded(child: _StatCard(value: '$_overdueCount', label: 'Overdue', emoji: '⚠️', color: AppColors.error.withValues(alpha: 0.1), textColor: AppColors.error)),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((f) {
          final isSelected = _filter == f;
          return Padding(
            padding: EdgeInsets.only(right: f != _filters.last ? AppConstants.paddingS : 0),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: 1.5),
                ),
                child: Text(f, style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                )),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNoBabyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppConstants.paddingL),
            Text('No baby profile found', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 6),
            Text('Add your baby\'s birth date to see the vaccination schedule', style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppConstants.paddingL),
            Text('All caught up!', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 6),
            Text('No vaccinations in this category', style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value, label, emoji;
  final Color color, textColor;
  const _StatCard({required this.value, required this.label, required this.emoji, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppConstants.radiusL)),
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

class _VaccineCard extends StatelessWidget {
  final VaccineRecord record;
  final VoidCallback onMarkGiven;

  const _VaccineCard({required this.record, required this.onMarkGiven});

  Color get _statusColor {
    switch (record.status) {
      case VaccineStatus.given:    return AppColors.accentGreen;
      case VaccineStatus.due:      return AppColors.primary;
      case VaccineStatus.overdue:  return AppColors.error;
      case VaccineStatus.upcoming: return AppColors.textSecondary;
    }
  }

  Color get _statusBg {
    switch (record.status) {
      case VaccineStatus.given:    return AppColors.accentGreenLight;
      case VaccineStatus.due:      return AppColors.primaryLight;
      case VaccineStatus.overdue:  return AppColors.error.withValues(alpha: 0.1);
      case VaccineStatus.upcoming: return AppColors.background;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: _statusBg, borderRadius: BorderRadius.circular(AppConstants.radiusM)),
            child: Center(child: Text(record.status.emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: AppConstants.paddingM),
          // Vaccine info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(record.vaccineName, style: AppTextStyles.titleMedium),
                Text(record.disease, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      record.status == VaccineStatus.given
                          ? 'Given: ${DateFormat('d MMM yyyy').format(record.givenDate!)}'
                          : 'Due: ${DateFormat('d MMM yyyy').format(record.dueDate)}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: record.status == VaccineStatus.overdue ? AppColors.error : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.paddingS),
          // Status badge / action
          if (record.status == VaccineStatus.given)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppColors.accentGreenLight, borderRadius: BorderRadius.circular(AppConstants.radiusFull)),
              child: Text('Given', style: AppTextStyles.labelMedium.copyWith(color: AppColors.accentGreen, fontWeight: FontWeight.w700)),
            )
          else
            GestureDetector(
              onTap: () => _confirmMarkGiven(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  border: Border.all(color: _statusColor, width: 1),
                ),
                child: Text(
                  record.status == VaccineStatus.overdue ? 'Mark Given' : 'Mark Done',
                  style: AppTextStyles.labelMedium.copyWith(color: _statusColor, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmMarkGiven(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusXL)),
        title: Text('Mark as Given', style: AppTextStyles.headlineSmall),
        content: Text(
          'Mark ${record.vaccineName} as given today?\n\nDisease: ${record.disease}',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onMarkGiven();
            },
            child: Text('Mark Given', style: AppTextStyles.titleMedium.copyWith(color: AppColors.accentGreen, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
