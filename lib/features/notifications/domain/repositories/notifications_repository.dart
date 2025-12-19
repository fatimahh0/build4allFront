// lib/features/notifications/domain/repositories/notifications_repository.dart

import '../entities/app_notification.dart';

abstract class NotificationsRepository {
  Future<List<AppNotification>> getMyNotifications();
  Future<int> getUnreadCount();
  Future<void> markAsRead(int id);
  Future<void> deleteNotification(int id);
}
