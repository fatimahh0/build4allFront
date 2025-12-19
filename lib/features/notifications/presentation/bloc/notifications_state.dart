// lib/features/notifications/presentation/bloc/notifications_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/app_notification.dart';

class NotificationsState extends Equatable {
  final bool isLoading;
  final bool hasLoaded;
  final String? error;

  final List<AppNotification> items;
  final int unreadCount;

  // for snack/toast on actions (optional)
  final String? lastActionMessage;

  const NotificationsState({
    required this.isLoading,
    required this.hasLoaded,
    required this.items,
    required this.unreadCount,
    this.error,
    this.lastActionMessage,
  });

  factory NotificationsState.initial() {
    return const NotificationsState(
      isLoading: false,
      hasLoaded: false,
      items: [],
      unreadCount: 0,
      error: null,
      lastActionMessage: null,
    );
  }

  NotificationsState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    String? error,
    List<AppNotification>? items,
    int? unreadCount,
    String? lastActionMessage,
    bool clearError = false,
    bool clearLastAction = false,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      error: clearError ? null : (error ?? this.error),
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      lastActionMessage: clearLastAction
          ? null
          : (lastActionMessage ?? this.lastActionMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    hasLoaded,
    error,
    items,
    unreadCount,
    lastActionMessage,
  ];
}
