// lib/features/notifications/presentation/bloc/notifications_event.dart

import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsStarted extends NotificationsEvent {
  const NotificationsStarted();
}

class NotificationsRefreshRequested extends NotificationsEvent {
  const NotificationsRefreshRequested();
}

class NotificationReadRequested extends NotificationsEvent {
  final int id;
  const NotificationReadRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class NotificationDeleteRequested extends NotificationsEvent {
  final int id;
  const NotificationDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}
