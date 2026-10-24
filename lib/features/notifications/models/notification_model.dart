enum NotificationType { booking, payment, message, review, system }

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String? relatedId; // e.g., booking ID, message ID
  final String? actionUrl;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
    this.relatedId,
    this.actionUrl,
  });

  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    String? relatedId,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  static List<NotificationModel> get mockNotifications => [
    NotificationModel(
      id: 'n1',
      type: NotificationType.booking,
      title: 'Booking Accepted',
      body: 'Bekele accepted your electrical repair booking',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: true,
      relatedId: 'b1248',
      actionUrl: '/booking-history',
    ),
    NotificationModel(
      id: 'n2',
      type: NotificationType.payment,
      title: 'Payment Confirmed',
      body: 'ETB 500 payment has been confirmed',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: true,
      relatedId: 'p1',
      actionUrl: '/booking-history',
    ),
    NotificationModel(
      id: 'n3',
      type: NotificationType.message,
      title: 'New Message from Bekele',
      body: 'I will be there in 30 minutes',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
      relatedId: 'm5',
      actionUrl: '/chat',
    ),
  ];
}
