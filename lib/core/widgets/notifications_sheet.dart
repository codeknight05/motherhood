import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';

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
    id: '1',
    emoji: '🏆',
    title: 'Milestone achieved!',
    subtitle: 'Your baby completed Social — 2/5 done. Keep it up!',
    timeAgo: '2h ago',
  ),
  const AppNotification(
    id: '2',
    emoji: '💡',
    title: 'Daily tip',
    subtitle: 'Tummy time helps strengthen neck and shoulder muscles.',
    timeAgo: '5h ago',
    isRead: true,
  ),
  const AppNotification(
    id: '3',
    emoji: '💉',
    title: 'Vaccination reminder',
    subtitle: 'Check upcoming vaccinations for your baby.',
    timeAgo: '1d ago',
    isRead: true,
  ),
  const AppNotification(
    id: '4',
    emoji: '📸',
    title: 'Memory prompt',
    subtitle: 'Capture a memory from this week — your baby is growing fast!',
    timeAgo: '2d ago',
    isRead: true,
  ),
];

final _pregnancyNotifications = [
  const AppNotification(
    id: '1',
    emoji: '🤰',
    title: 'Weekly update ready',
    subtitle: 'Your pregnancy guide for this week is available. Tap to read.',
    timeAgo: '1h ago',
  ),
  const AppNotification(
    id: '2',
    emoji: '💡',
    title: 'Pregnancy tip',
    subtitle: 'Stay hydrated — aim for 8–10 glasses of water daily.',
    timeAgo: '4h ago',
    isRead: true,
  ),
  const AppNotification(
    id: '3',
    emoji: '📅',
    title: 'Prenatal reminder',
    subtitle: 'Don\'t forget to schedule your next prenatal appointment.',
    timeAgo: '1d ago',
    isRead: true,
  ),
  const AppNotification(
    id: '4',
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

class _NotificationsSheet extends StatefulWidget {
  final bool isPregnant;
  const _NotificationsSheet({this.isPregnant = false});

  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(
      widget.isPregnant ? _pregnancyNotifications : _parentNotifications,
    );
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => AppNotification(
                id: n.id,
                emoji: n.emoji,
                title: n.title,
                subtitle: n.subtitle,
                timeAgo: n.timeAgo,
                isRead: true,
              ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                if (_unreadCount > 0) ...[
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
                      '$_unreadCount',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (_unreadCount > 0)
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
            child: _notifications.isEmpty
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
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      color: AppColors.divider,
                      indent: 72,
                    ),
                    itemBuilder: (_, i) {
                      final n = _notifications[i];
                      return _NotifTile(
                        notification: n,
                        onTap: () {
                          if (!n.isRead) {
                            setState(() {
                              _notifications[i] = AppNotification(
                                id: n.id,
                                emoji: n.emoji,
                                title: n.title,
                                subtitle: n.subtitle,
                                timeAgo: n.timeAgo,
                                isRead: true,
                              );
                            });
                          }
                        },
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

class NotificationBell extends StatelessWidget {
  final bool isPregnant;
  final int badgeCount;

  const NotificationBell({
    super.key,
    this.isPregnant = false,
    this.badgeCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined,
              color: AppColors.textPrimary, size: 26),
          if (badgeCount > 0)
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
                    badgeCount > 9 ? '9+' : '$badgeCount',
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
