import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_order_entities.dart';

class AdminOrderDetailsState extends Equatable {
  final bool loading;
  final bool updating;
  final String? error;
  final String? message;
  final OrderDetailsResponse? data;

  const AdminOrderDetailsState({
    required this.loading,
    required this.updating,
    this.error,
    this.message,
    this.data,
  });

  factory AdminOrderDetailsState.initial() => const AdminOrderDetailsState(
        loading: false,
        updating: false,
        error: null,
        message: null,
        data: null,
      );

  AdminOrderDetailsState copyWith({
    bool? loading,
    bool? updating,
    String? error,
    String? message,
    OrderDetailsResponse? data,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return AdminOrderDetailsState(
      loading: loading ?? this.loading,
      updating: updating ?? this.updating,
      error: clearError ? null : (error ?? this.error),
      message: clearMessage ? null : (message ?? this.message),
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [loading, updating, error, message, data];
}
