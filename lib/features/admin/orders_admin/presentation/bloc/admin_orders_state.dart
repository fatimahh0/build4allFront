import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_order_entities.dart';

class AdminOrdersState extends Equatable {
  final bool loading;
  final List<OrderHeaderRow> orders;
  final String? statusFilter; // null => ALL
  final String? error;

  const AdminOrdersState({
    required this.loading,
    required this.orders,
    required this.statusFilter,
    required this.error,
  });

  factory AdminOrdersState.initial() => const AdminOrdersState(
    loading: false,
    orders: [],
    statusFilter: null,
    error: null,
  );

  static const Object _unset = Object();

  AdminOrdersState copyWith({
    bool? loading,
    List<OrderHeaderRow>? orders,
    Object? statusFilter = _unset, // ✅ allows setting null intentionally
    String? error,
    bool clearError = false,
  }) {
    return AdminOrdersState(
      loading: loading ?? this.loading,
      orders: orders ?? this.orders,
      statusFilter: identical(statusFilter, _unset)
          ? this.statusFilter
          : statusFilter as String?, // can be null ✅
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [loading, orders, statusFilter, error];
}
