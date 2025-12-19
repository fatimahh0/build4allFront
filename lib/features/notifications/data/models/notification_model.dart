// lib/features/notifications/data/models/notification_model.dart

class NotificationModel {
  final int id;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id:
          (json['id'] ?? json['notification_id'] ?? json['notificationId'])
              as int,
      message: (json['message'] ?? '') as String,
      isRead: (json['isRead'] ?? json['is_read'] ?? false) as bool,
      createdAt: DateTime.parse(
        (json['createdAt'] ?? json['created_at']).toString(),
      ),
      updatedAt: DateTime.parse(
        (json['updatedAt'] ?? json['updated_at']).toString(),
      ),
    );
  }
}
