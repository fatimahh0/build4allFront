// lib/features/notifications/domain/entities/app_notification.dart

class AppNotification {
  final int id;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppNotification({
    required this.id,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  AppNotification copyWith({
    String? message,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppNotification(
      id: id,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
