import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';

class NotificationNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  NotificationNotifier() : super(const AsyncValue.data([])) {
    _initializeMockNotifications();
  }

  void _initializeMockNotifications() {
    final notifications = NotificationModel.mockNotifications;
    state = AsyncValue.data(notifications);
  }

  /// Add a new notification
  void addNotification(NotificationModel notification) {
    final currentNotifications = state.maybeWhen(
      data: (notifications) => notifications,
      orElse: () => <NotificationModel>[],
    );

    state = AsyncValue.data([notification, ...currentNotifications]);
  }

  /// Mark notification as read
  void markAsRead(String notificationId) {
    final currentNotifications = state.maybeWhen(
      data: (notifications) => notifications,
      orElse: () => <NotificationModel>[],
    );

    final updatedNotifications = currentNotifications.map((notif) {
      if (notif.id == notificationId) {
        return notif.copyWith(isRead: true);
      }
      return notif;
    }).toList();

    state = AsyncValue.data(updatedNotifications);
  }

  /// Mark all as read
  void markAllAsRead() {
    final currentNotifications = state.maybeWhen(
      data: (notifications) => notifications,
      orElse: () => <NotificationModel>[],
    );

    final updatedNotifications = currentNotifications
        .map((notif) => notif.copyWith(isRead: true))
        .toList();

    state = AsyncValue.data(updatedNotifications);
  }

  /// Delete notification
  void deleteNotification(String notificationId) {
    final currentNotifications = state.maybeWhen(
      data: (notifications) => notifications,
      orElse: () => <NotificationModel>[],
    );

    final filteredNotifications =
        currentNotifications.where((n) => n.id != notificationId).toList();

    state = AsyncValue.data(filteredNotifications);
  }

  /// Get unread count
  int getUnreadCount() {
    return state.maybeWhen(
      data: (notifications) =>
          notifications.where((n) => !n.isRead).length,
      orElse: () => 0,
    );
  }
}

// Global notifications provider
final notificationsProvider = StateNotifierProvider<NotificationNotifier,
    AsyncValue<List<NotificationModel>>>((ref) {
  return NotificationNotifier();
});

// Derived: unread count
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.maybeWhen(
    data: (notifications) =>
        notifications.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});

// Derived: unread notifications
final unreadNotificationsProvider =
    Provider<List<NotificationModel>>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.maybeWhen(
    data: (notifications) =>
        notifications.where((n) => !n.isRead).toList(),
    orElse: () => <NotificationModel>[],
  );
});

// Derived: recent notifications
final recentNotificationsProvider =
    Provider<List<NotificationModel>>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.maybeWhen(
    data: (notifications) {
      final sorted = List<NotificationModel>.from(notifications)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return sorted.take(20).toList();
    },
    orElse: () => <NotificationModel>[],
  );
});
