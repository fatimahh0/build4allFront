// lib/features/notifications/domain/usecases/delete_notification.dart

import '../repositories/notifications_repository.dart';

class DeleteNotification {
  final NotificationsRepository repo;
  DeleteNotification(this.repo);

  Future<void> call(int id) => repo.deleteNotification(id);
}
