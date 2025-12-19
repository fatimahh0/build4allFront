// lib/features/notifications/domain/usecases/mark_notification_read.dart

import '../repositories/notifications_repository.dart';

class MarkNotificationRead {
  final NotificationsRepository repo;
  MarkNotificationRead(this.repo);

  Future<void> call(int id) => repo.markAsRead(id);
}
