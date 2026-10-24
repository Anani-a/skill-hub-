import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../features/notifications/models/notification_model.dart';
import '../../features/notifications/providers/notification_provider.dart';
import '../../shared/providers/mock_state_providers.dart';

void showNotificationsModal(BuildContext context, WidgetRef ref) {
  final activeLang = ref.read(languageProvider);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) {
      return Consumer(
        builder: (context, ref, child) {
          final notificationsAsync = ref.watch(notificationsProvider);
          final notifications = notificationsAsync.maybeWhen(
            data: (list) => list,
            orElse: () => <NotificationModel>[],
          );
          final unreadCount = ref.watch(unreadNotificationsCountProvider);

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.outlineLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              activeLang == 'am' ? 'ማሳወቂያዎች' : 'Notifications',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            if (unreadCount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.error,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$unreadCount ${activeLang == 'am' ? 'አዲስ' : 'new'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        if (notifications.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              ref.read(notificationsProvider.notifier).markAllAsRead();
                            },
                            child: Text(
                              activeLang == 'am' ? 'ሁሉንም እንዳነበብኩ አድርግ' : 'Mark all read',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Notifications List
                  Expanded(
                    child: notifications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.notifications_off_outlined,
                                  size: 48,
                                  color: AppTheme.textTertiary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  activeLang == 'am' ? 'ምንም ማሳወቂያ የለም' : 'No notifications right now',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            itemCount: notifications.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final notif = notifications[index];
                              return _buildNotificationItem(context, ref, notif, activeLang);
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildNotificationItem(
  BuildContext context,
  WidgetRef ref,
  NotificationModel notif,
  String activeLang,
) {
  IconData iconData;
  Color iconBg;

  switch (notif.type) {
    case NotificationType.booking:
      iconData = Icons.calendar_month_rounded;
      iconBg = AppTheme.primary;
      break;
    case NotificationType.payment:
      iconData = Icons.account_balance_wallet_rounded;
      iconBg = AppTheme.secondary;
      break;
    case NotificationType.message:
      iconData = Icons.chat_bubble_rounded;
      iconBg = AppTheme.tertiary;
      break;
    case NotificationType.review:
      iconData = Icons.star_rounded;
      iconBg = AppTheme.starFilled;
      break;
    case NotificationType.system:
      iconData = Icons.info_rounded;
      iconBg = AppTheme.statusInfo;
      break;
  }

  final timeAgo = _formatTimeAgo(notif.timestamp, activeLang);

  return InkWell(
    onTap: () {
      // Mark read & navigate to action URL
      ref.read(notificationsProvider.notifier).markAsRead(notif.id);
      Navigator.pop(context);
      if (notif.actionUrl != null && notif.actionUrl!.isNotEmpty) {
        context.push(notif.actionUrl!);
      }
    },
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notif.isRead ? AppTheme.bgSurface : AppTheme.primaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: notif.isRead ? AppTheme.outlineLighter : AppTheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconBg, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notif.title,
                        style: TextStyle(
                          fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notif.body,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (!notif.isRead) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

String _formatTimeAgo(DateTime timestamp, String activeLang) {
  final diff = DateTime.now().difference(timestamp);
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m ago';
  } else if (diff.inHours < 24) {
    return '${diff.inHours}h ago';
  } else {
    return '${diff.inDays}d ago';
  }
}
