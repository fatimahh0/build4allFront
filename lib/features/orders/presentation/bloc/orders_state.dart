// lib/features/orders/presentation/bloc/orders_state.dart
import 'package:equatable/equatable.dart';

import '../../domain/entities/order_entities.dart';
import 'orders_event.dart';

class OrdersState extends Equatable {
  final bool loading;
  final String? error;

  final List<OrderLine> orders;
  final OrdersFilter filter;

  const OrdersState({
    required this.loading,
    required this.orders,
    required this.filter,
    this.error,
  });

  factory OrdersState.initial() => const OrdersState(
    loading: false,
    orders: [],
    filter: OrdersFilter.all,
    error: null,
  );

  OrdersState copyWith({
    bool? loading,
    String? error,
    List<OrderLine>? orders,
    OrdersFilter? filter,
  }) {
    return OrdersState(
      loading: loading ?? this.loading,
      error: error,
      orders: orders ?? this.orders,
      filter: filter ?? this.filter,
    );
  }

  /// ✅ Correct filtering: use backend raw status in `order.status`
  /// because `orderStatus` is already "Pending/Completed/..."
  List<OrderLine> get filtered {
    if (filter == OrdersFilter.all) return orders;

    String norm(String? s) => (s ?? '').trim().toUpperCase();

    bool match(OrderLine o) {
      final raw = norm(o.order.status);

      switch (filter) {
        case OrdersFilter.pending:
          return raw == 'PENDING' || raw == 'CANCEL_REQUESTED';
        case OrdersFilter.completed:
          return raw == 'COMPLETED';
        case OrdersFilter.canceled:
          return raw == 'CANCELED';
        case OrdersFilter.all:
          return true;
      }
    }

    return orders.where(match).toList();
  }

  @override
  List<Object?> get props => [loading, error, orders, filter];
}
