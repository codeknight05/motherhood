import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';
import '../providers/baby_provider.dart';
import '../providers/pregnancy_provider.dart';
import '../services/cloudinary_service.dart';
import '../services/milestone_guidance_service.dart';
import '../../models/baby_model.dart';
import '../../models/vaccination_model.dart';
import '../../models/milestone_model.dart';
import '../../models/memory_model.dart';

// ── Notification model ────────────────────────────────────────────────────────

class AppNotification {
  final String id;
  final String emoji;
  final String title;
  final String subtitle;
  final String timeAgo;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    this.isRead = false,
  });
}

// ── Sample notifications (replace with Supabase later) ────────────────────────

final _parentNotifications = [
  const AppNotification(
    id: 'parent_static_1',
    emoji: '🏆',
    title: 'Milestone achieved!',
    subtitle: 'Your baby completed Social — 2/5 done. Keep it up!',
    timeAgo: '2h ago',
  ),
  const AppNotification(
    id: 'parent_static_2',
    emoji: '💡',
    title: 'Daily tip',
    subtitle: 'Tummy time helps strengthen neck and shoulder muscles.',
    timeAgo: '5h ago',
    isRead: true,
  ),
  const AppNotification(
    id: 'parent_static_3',
    emoji: '💉',
    title: 'Vaccination reminder',
    subtitle: 'Check upcoming vaccinations for your baby.',
    timeAgo: '1d ago',
    isRead: true,
  ),
  const AppNotification(
    id: 'parent_static_4',
    emoji: '📸',
    title: 'Memory prompt',
    subtitle: 'Capture a memory from this week — your baby is growing fast!',
    timeAgo: '2d ago',
    isRead: true,
  ),
];

final _pregnancyNotifications = [
  const AppNotification(
    id: 'preg_static_1',
    emoji: '🤰',
    title: 'Weekly update ready',
    subtitle: 'Your pregnancy guide for this week is available. Tap to read.',
    timeAgo: '1h ago',
  ),
  const AppNotification(
    id: 'preg_static_2',
    emoji: '💡',
    title: 'Pregnancy tip',
    subtitle: 'Stay hydrated — aim for 8–10 glasses of water daily.',
    timeAgo: '4h ago',
    isRead: true,
  ),
  const AppNotification(
    id: 'preg_static_3',
    emoji: '📅',
    title: 'Prenatal reminder',
    subtitle: 'Don\'t forget to schedule your next prenatal appointment.',
    timeAgo: '1d ago',
    isRead: true,
  ),
  const AppNotification(
    id: 'preg_static_4',
    emoji: '🥗',
    title: 'Nutrition reminder',
    subtitle: 'Include iron-rich foods in your meals today.',
    timeAgo: '2d ago',
    isRead: true,
  ),
];

// ── Show helper ───────────────────────────────────────────────────────────────

void showNotificationsSheet(BuildContext context, {bool isPregnant = false}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _NotificationsSheet(isPregnant: isPregnant),
  );
}

// ── Sheet widget ──────────────────────────────────────────────────────────────

class _NotificationsSheet extends ConsumerStatefulWidget {
  final bool isPregnant;
  const _NotificationsSheet({this.isPregnant = false});

  @override
  ConsumerState<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends ConsumerState<_NotificationsSheet> {
  void _markAllRead() {
    ref.read(notificationsProvider.notifier).markAllRead(widget.isPregnant);
  }

  void _showVaccinationUpdateSheet(BuildContext context, AppNotification notification, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VaccinationManualUpdateSheet(
        notification: notification,
        ref: ref,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    final notifications = widget.isPregnant
        ? state.pregnancyNotifications
        : state.parentNotifications;
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppConstants.paddingM,
        0,
        AppConstants.paddingM,
        AppConstants.paddingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingXL,
              AppConstants.paddingL,
              AppConstants.paddingL,
              AppConstants.paddingM,
            ),
            child: Row(
              children: [
                Text('Notifications', style: AppTextStyles.headlineMedium),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(
                          AppConstants.radiusFull),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (unreadCount > 0)
                  TextButton(
                    onPressed: _markAllRead,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Mark all read',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          // Notification list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.55,
            ),
            child: notifications.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔔',
                            style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 12),
                        Text('No notifications yet',
                            style: AppTextStyles.titleLarge),
                        const SizedBox(height: 4),
                        Text('You\'re all caught up!',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.paddingS),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      color: AppColors.divider,
                      indent: 72,
                    ),
                    itemBuilder: (_, i) {
                      final n = notifications[i];
                      return Dismissible(
                        key: Key(n.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          color: AppColors.error.withValues(alpha: 0.85),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        onDismissed: (direction) {
                          ref
                              .read(notificationsProvider.notifier)
                              .removeNotification(n.id, widget.isPregnant);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Notification "${n.title}" cleared'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              ),
                            ),
                          );
                        },
                        child: _NotifTile(
                          notification: n,
                          onTap: () {
                            if (n.id.startsWith('dyn_vac_')) {
                              _showVaccinationUpdateSheet(context, n, ref);
                            } else {
                              if (!n.isRead) {
                                ref
                                    .read(notificationsProvider.notifier)
                                    .markAsRead(n.id, widget.isPregnant);
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: AppConstants.paddingM),
        ],
      ),
    );
  }
}

// ── Notification tile ─────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotifTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingL,
          vertical: AppConstants.paddingM,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji avatar with unread indicator
            Stack(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: notification.isRead
                        ? AppColors.surface
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: notification.isRead
                          ? AppColors.divider
                          : AppColors.primaryMid,
                    ),
                  ),
                  child: Center(
                    child: Text(notification.emoji,
                        style: const TextStyle(fontSize: 22)),
                  ),
                ),
                if (!notification.isRead)
                  Positioned(
                    top: 0, right: 0,
                    child: Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        notification.timeAgo,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: notification.isRead
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bell icon widget (reusable in app bars) ───────────────────────────────────

class NotificationBell extends ConsumerWidget {
  final bool isPregnant;
  final int? badgeCount;

  const NotificationBell({
    super.key,
    this.isPregnant = false,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    final list = isPregnant ? state.pregnancyNotifications : state.parentNotifications;
    final derivedBadgeCount = badgeCount ?? list.where((n) => !n.isRead).length;

    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined,
              color: AppColors.textPrimary, size: 26),
          if (derivedBadgeCount > 0)
            Positioned(
              right: -2, top: -2,
              child: Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    derivedBadgeCount > 9 ? '9+' : '$derivedBadgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      onPressed: () => showNotificationsSheet(context, isPregnant: isPregnant),
    );
  }
}

// ── Riverpod Provider ─────────────────────────────────────────────────────────

class NotificationsState {
  final List<AppNotification> parentNotifications;
  final List<AppNotification> pregnancyNotifications;

  const NotificationsState({
    required this.parentNotifications,
    required this.pregnancyNotifications,
  });

  NotificationsState copyWith({
    List<AppNotification>? parentNotifications,
    List<AppNotification>? pregnancyNotifications,
  }) {
    return NotificationsState(
      parentNotifications: parentNotifications ?? this.parentNotifications,
      pregnancyNotifications: pregnancyNotifications ?? this.pregnancyNotifications,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final Ref ref;
  static const _storage = FlutterSecureStorage();
  static const _readKeysKey = 'read_notification_ids';
  static const _removedKeysKey = 'removed_notification_ids';

  final Set<String> _readIds = {};
  final Set<String> _removedIds = {};

  List<AppNotification> _dynamicParentNotifications = [];
  List<AppNotification> _dynamicPregnancyNotifications = [];

  NotificationsNotifier(this.ref)
      : super(NotificationsState(
          parentNotifications: List.from(_parentNotifications),
          pregnancyNotifications: List.from(_pregnancyNotifications),
        )) {
    _init();
  }

  Future<void> _init() async {
    await _loadPersistedIds();
    _updateState();

    final baby = ref.read(babyProvider).baby;
    refreshDynamicNotifications(baby);
  }

  Future<void> _loadPersistedIds() async {
    try {
      final readStr = await _storage.read(key: _readKeysKey);
      final removedStr = await _storage.read(key: _removedKeysKey);

      if (readStr != null && readStr.isNotEmpty) {
        _readIds.addAll(readStr.split(','));
      }
      if (removedStr != null && removedStr.isNotEmpty) {
        _removedIds.addAll(removedStr.split(','));
      }
    } catch (e) {
      debugPrint('[NotificationsNotifier] Error loading persisted state: $e');
    }
  }

  Future<void> _savePersistedState() async {
    try {
      await _storage.write(key: _readKeysKey, value: _readIds.join(','));
      await _storage.write(key: _removedKeysKey, value: _removedIds.join(','));
    } catch (e) {
      debugPrint('[NotificationsNotifier] Error saving persisted state: $e');
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }

  Future<void> refreshDynamicNotifications(BabyModel? baby) async {
    try {
      final List<AppNotification> newParentDyn = [];
      final List<AppNotification> newPregDyn = [];

      // 1. Resolve Pregnancy Mode alerts
      final pgState = ref.read(pregnancyProvider);
      final week = pgState.currentWeek;

      newPregDyn.add(AppNotification(
        id: 'dyn_preg_week_update_$week',
        emoji: '🤰',
        title: 'Week $week Pregnancy Guide',
        subtitle: 'Your pregnancy guide for Week $week is ready! Learn about baby\'s development and maternal tips.',
        timeAgo: 'Now',
      ));

      newPregDyn.add(const AppNotification(
        id: 'dyn_preg_hydration',
        emoji: '🥗',
        title: 'Daily Hydration & Nutrition',
        subtitle: 'Stay hydrated! Aim for 8-10 glasses of water and include iron-rich foods in your meals today.',
        timeAgo: 'Today',
      ));

      // 2. Resolve Parent Mode alerts (if baby is born)
      if (baby != null && baby.birthDate != null) {
        // A. Check Memory Diary status
        try {
          final memoriesRes = await Supabase.instance.client
              .from('memories')
              .select('id')
              .eq('baby_id', baby.id)
              .limit(1);
          final hasMemories = (memoriesRes as List).isNotEmpty;

          if (!hasMemories) {
            newParentDyn.add(AppNotification(
              id: 'dyn_mem_empty',
              emoji: '📸',
              title: 'Memory Diary is empty',
              subtitle: 'Start capturing memories! Record ${baby.name}\'s beautiful milestones and daily moments.',
              timeAgo: 'Now',
            ));
          }
        } catch (e) {
          debugPrint('[NotificationsNotifier] Error checking memories: $e');
        }

        // B. Check Vaccinations status
        try {
          final vaccinationRes = await Supabase.instance.client
              .from('vaccinations')
              .select()
              .eq('baby_id', baby.id)
              .order('due_date');

          List<VaccineRecord> vaccineRecords = [];
          if ((vaccinationRes as List).isNotEmpty) {
            vaccineRecords = vaccinationRes.map((r) => VaccineRecord(
              id: r['id']?.toString() ?? '',
              babyId: r['baby_id']?.toString() ?? '',
              vaccineName: r['vaccine_name']?.toString() ?? '',
              disease: r['notes']?.toString() ?? '',
              dueDate: DateTime.parse(r['due_date'] as String),
              givenDate: r['given_date'] != null ? DateTime.parse(r['given_date'] as String) : null,
            )).toList();
          } else {
            // First time loading - generate from schedule and write to database
            final schedule = generateVaccinationSchedule(baby.id, baby.birthDate!);
            final rows = schedule.map((v) => {
              'baby_id': baby.id,
              'vaccine_name': v.vaccineName,
              'due_date': v.dueDate.toIso8601String().split('T').first,
              'notes': v.disease,
            }).toList();
            await Supabase.instance.client.from('vaccinations').insert(rows);

            // Re-fetch to populate actual primary key UUIDs
            final reFetch = await Supabase.instance.client
                .from('vaccinations')
                .select()
                .eq('baby_id', baby.id)
                .order('due_date');
            
            vaccineRecords = (reFetch as List).map((r) => VaccineRecord(
              id: r['id']?.toString() ?? '',
              babyId: r['baby_id']?.toString() ?? '',
              vaccineName: r['vaccine_name']?.toString() ?? '',
              disease: r['notes']?.toString() ?? '',
              dueDate: DateTime.parse(r['due_date'] as String),
              givenDate: r['given_date'] != null ? DateTime.parse(r['given_date'] as String) : null,
            )).toList();
          }

          int count = 0;
          for (final r in vaccineRecords) {
            if (r.status == VaccineStatus.overdue) {
              newParentDyn.add(AppNotification(
                id: 'dyn_vac_${r.id}',
                emoji: '⚠️',
                title: 'Vaccination Overdue!',
                subtitle: '${r.vaccineName} (${r.disease}) was due on ${_formatDate(r.dueDate)}.',
                timeAgo: 'Overdue',
              ));
              count++;
            } else if (r.status == VaccineStatus.due) {
              newParentDyn.add(AppNotification(
                id: 'dyn_vac_${r.id}',
                emoji: '📅',
                title: 'Vaccination Due Now',
                subtitle: '${r.vaccineName} (${r.disease}) is due on ${_formatDate(r.dueDate)}.',
                timeAgo: 'Due Now',
              ));
              count++;
            }
            if (count >= 3) break;
          }
        } catch (e) {
          debugPrint('[NotificationsNotifier] Error checking vaccinations: $e');
        }

        // C. Check Milestones status
        try {
          final milestoneRes = await Supabase.instance.client
              .from('milestones')
              .select('title, category, status')
              .eq('baby_id', baby.id);

          final Map<String, MilestoneStatus> statusMap = {};
          for (final row in (milestoneRes as List)) {
            final category = row['category'] as String? ?? '';
            final title = row['title'] as String? ?? '';
            final statusStr = row['status'] as String? ?? 'not_started';
            final status = statusStr == 'achieved'
                ? MilestoneStatus.achieved
                : (statusStr == 'in_progress' ? MilestoneStatus.inProgress : MilestoneStatus.notStarted);
            statusMap['${category.toLowerCase()}:${title.toLowerCase()}'] = status;
          }

          final days = DateTime.now().difference(baby.birthDate!).inDays;
          final bandIndex = ageBandFromDays(days);
          final band = ageBands[bandIndex];
          
          final libraryGuidance = await MilestoneGuidanceService.getGuidance(bandIndex);
          
          int unachievedCount = 0;
          for (final g in libraryGuidance) {
            for (final m in g.milestones) {
              final key = '${g.category.name.toLowerCase()}:${m.title.toLowerCase()}';
              final status = statusMap[key] ?? MilestoneStatus.notStarted;
              if (status != MilestoneStatus.achieved) {
                unachievedCount++;
              }
            }
          }

          if (unachievedCount > 0) {
            newParentDyn.add(AppNotification(
              id: 'dyn_milestone_update',
              emoji: '🏆',
              title: 'Time to update milestones',
              subtitle: 'Check if ${baby.name} has achieved new milestones for the "${band.shortLabel}" stage.',
              timeAgo: 'Now',
            ));
          }
        } catch (e) {
          debugPrint('[NotificationsNotifier] Error checking milestones: $e');
        }
      }

      _dynamicParentNotifications = newParentDyn;
      _dynamicPregnancyNotifications = newPregDyn;

      _updateState();
    } catch (e) {
      debugPrint('[NotificationsNotifier] Error in refreshDynamicNotifications: $e');
    }
  }

  void _updateState() {
    final allParent = [
      ..._dynamicParentNotifications,
      ..._parentNotifications,
    ];
    final allPregnancy = [
      ..._dynamicPregnancyNotifications,
      ..._pregnancyNotifications,
    ];

    final filteredParent = allParent
        .where((n) => !_removedIds.contains(n.id))
        .map((n) => AppNotification(
              id: n.id,
              emoji: n.emoji,
              title: n.title,
              subtitle: n.subtitle,
              timeAgo: n.timeAgo,
              isRead: n.isRead || _readIds.contains(n.id),
            ))
        .toList();

    final filteredPregnancy = allPregnancy
        .where((n) => !_removedIds.contains(n.id))
        .map((n) => AppNotification(
              id: n.id,
              emoji: n.emoji,
              title: n.title,
              subtitle: n.subtitle,
              timeAgo: n.timeAgo,
              isRead: n.isRead || _readIds.contains(n.id),
            ))
        .toList();

    state = NotificationsState(
      parentNotifications: filteredParent,
      pregnancyNotifications: filteredPregnancy,
    );
  }

  void markAllRead(bool isPregnant) {
    final list = isPregnant ? state.pregnancyNotifications : state.parentNotifications;
    for (final n in list) {
      _readIds.add(n.id);
    }
    _updateState();
    _savePersistedState();
  }

  void markAsRead(String id, bool isPregnant) {
    _readIds.add(id);
    _updateState();
    _savePersistedState();
  }

  void removeNotification(String id, bool isPregnant) {
    _removedIds.add(id);
    _updateState();
    _savePersistedState();
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final notifier = NotificationsNotifier(ref);

  ref.listen<BabyState>(babyProvider, (previous, next) {
    if (next.baby != previous?.baby || next.hasChecked != previous?.hasChecked) {
      notifier.refreshDynamicNotifications(next.baby);
    }
  });

  ref.listen<PregnancyState>(pregnancyProvider, (previous, next) {
    if (next.currentWeek != previous?.currentWeek) {
      final baby = ref.read(babyProvider).baby;
      notifier.refreshDynamicNotifications(baby);
    }
  });

  return notifier;
});

// ── Vaccination Manual Update Bottom Sheet ───────────────────────────────────

class _VaccinationManualUpdateSheet extends StatefulWidget {
  final AppNotification notification;
  final WidgetRef ref;

  const _VaccinationManualUpdateSheet({
    required this.notification,
    required this.ref,
  });

  @override
  State<_VaccinationManualUpdateSheet> createState() => _VaccinationManualUpdateSheetState();
}

class _VaccinationManualUpdateSheetState extends State<_VaccinationManualUpdateSheet> {
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final dbId = widget.notification.id.replaceFirst('dyn_vac_', '');
      
      await Supabase.instance.client
          .from('vaccinations')
          .update({'given_date': _selectedDate.toIso8601String().split('T').first})
          .eq('id', dbId);

      widget.ref.read(notificationsProvider.notifier).removeNotification(widget.notification.id, false);

      if (mounted) {
        final vaccineName = widget.notification.title
            .replaceFirst('Vaccination due: ', '')
            .replaceFirst('Vaccination Due Now', '')
            .replaceFirst('Vaccination Overdue!', '')
            .trim();

        final babyName = widget.ref.read(babyProvider).baby?.name ?? 'My Baby';

        Navigator.pop(context); // close manual date entry sheet
        Navigator.pop(context); // close notifications sheet

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _VaccinationCelebrationSheet(
            vaccineName: vaccineName,
            babyName: babyName,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update vaccination: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingL),
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingXL,
        AppConstants.paddingXL,
        AppConstants.paddingXL,
        AppConstants.paddingXL + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingL),
          Text('Mark as Vaccinated', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppConstants.paddingS),
          Text(
            'Confirm if your baby has received the vaccine: ${widget.notification.title.replaceFirst('Vaccination Due Now', '').replaceFirst('Vaccination Overdue!', '').trim()}',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppConstants.paddingL),
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vaccination Date', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('d MMMM yyyy').format(_selectedDate),
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _selectDate,
                  child: Text('Change', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingXL),
          if (_saving)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                    child: Text('Cancel', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                      elevation: 0,
                    ),
                    child: Text('Save & Done', style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Vaccination Celebration Sheet (Memory Capture) ──────────────────────────

class _VaccinationCelebrationSheet extends StatefulWidget {
  final String vaccineName;
  final String babyName;

  const _VaccinationCelebrationSheet({
    required this.vaccineName,
    required this.babyName,
  });

  @override
  State<_VaccinationCelebrationSheet> createState() => _VaccinationCelebrationSheetState();
}

class _VaccinationCelebrationSheetState extends State<_VaccinationCelebrationSheet>
    with SingleTickerProviderStateMixin {
  final _picker = ImagePicker();
  bool _uploading = false;
  bool _uploaded = false;
  late final AnimationController _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload(ImageSource source, {bool isVideo = false}) async {
    try {
      XFile? file;
      if (isVideo) {
        file = await _picker.pickVideo(source: source, maxDuration: const Duration(minutes: 5));
      } else {
        file = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1200);
      }
      if (file == null || !mounted) return;

      setState(() => _uploading = true);

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        setState(() => _uploading = false);
        return;
      }

      // Get baby id from Supabase
      final babies = await Supabase.instance.client
          .from('babies')
          .select('id')
          .eq('user_id', userId)
          .limit(1);
      final babyId = (babies as List).isNotEmpty ? babies.first['id'] as String : 'unknown';

      String? imageUrl;
      String? videoUrl;

      if (isVideo) {
        videoUrl = await CloudinaryService.uploadMemoryVideo(
          file: File(file.path), userId: userId, babyId: babyId,
        );
      } else {
        imageUrl = await CloudinaryService.uploadMemoryPhoto(
          file: File(file.path), userId: userId, babyId: babyId,
        );
      }

      await Supabase.instance.client.from('memories').insert({
        'baby_id': babyId,
        'user_id': userId,
        if (imageUrl != null) 'image_url': imageUrl,
        if (videoUrl != null) 'video_url': videoUrl,
        'caption': '${widget.babyName} got vaccinated: ${widget.vaccineName} 💉💪',
        'tag': MemoryTag.special.dbValue,
        'memory_date': DateTime.now().toIso8601String().split('T').first,
      });

      if (mounted) setState(() { _uploading = false; _uploaded = true; });
    } catch (e) {
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

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
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: AppConstants.paddingL),

          ScaleTransition(
            scale: CurvedAnimation(parent: _confettiCtrl, curve: Curves.elasticOut),
            child: const Text('💉', style: TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: AppConstants.paddingM),

          Text(
            _uploaded ? 'Memory Saved! 📸' : 'Vaccination Recorded!',
            style: AppTextStyles.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingS),

          Text(
            _uploaded
                ? 'This brave moment has been added to ${widget.babyName}\'s Memory Diary.'
                : 'Brave baby! ${widget.babyName} got their ${widget.vaccineName} vaccine. Record this moment to keep in the Memory Diary.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingXL),

          if (!_uploaded) ...[
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              decoration: BoxDecoration(
                color: AppColors.accentBlueLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('📸', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: AppConstants.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Capture the brave moment!', style: AppTextStyles.titleMedium.copyWith(color: AppColors.accentBlue)),
                        Text('Upload a photo or video of ${widget.babyName} receiving their vaccine or their brave smile afterwards.', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingXL),

            if (_uploading)
              Column(
                children: [
                  const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
                  const SizedBox(height: AppConstants.paddingM),
                  Text('Uploading to Memory Diary...', style: AppTextStyles.bodySmall),
                ],
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: _MediaButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Take Photo',
                      color: AppColors.primaryLight,
                      iconColor: AppColors.primary,
                      onTap: () => _pickAndUpload(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingM),
                  Expanded(
                    child: _MediaButton(
                      icon: Icons.photo_library_rounded,
                      label: 'From Gallery',
                      color: AppColors.accentPinkLight,
                      iconColor: AppColors.accentPink,
                      onTap: () => _pickAndUpload(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingM),
              Row(
                children: [
                  Expanded(
                    child: _MediaButton(
                      icon: Icons.videocam_rounded,
                      label: 'Record Video',
                      color: AppColors.accentOrangeLight,
                      iconColor: AppColors.accentOrange,
                      onTap: () => _pickAndUpload(ImageSource.camera, isVideo: true),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingM),
                  Expanded(
                    child: _MediaButton(
                      icon: Icons.video_library_rounded,
                      label: 'Video Gallery',
                      color: AppColors.accentBlueLight,
                      iconColor: AppColors.accentBlue,
                      onTap: () => _pickAndUpload(ImageSource.gallery, isVideo: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingL),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Maybe later', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ),
            ],
          ] else ...[
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              decoration: BoxDecoration(
                color: AppColors.accentGreenLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.accentGreen, size: 28),
                  const SizedBox(width: AppConstants.paddingM),
                  Expanded(
                    child: Text(
                      'Find it in the Memory Diary tab 📸',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accentGreen),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                  elevation: 0,
                ),
                child: Text('Done', style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
              ),
            ),
          ],
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, iconColor;
  final VoidCallback onTap;

  const _MediaButton({
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.labelMedium.copyWith(color: iconColor, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
