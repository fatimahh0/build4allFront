import 'package:equatable/equatable.dart';

abstract class AdminOrderDetailsEvent extends Equatable {
  const AdminOrderDetailsEvent();

  @override
  List<Object?> get props => [];
}

class AdminOrderDetailsStarted extends AdminOrderDetailsEvent {
  final int orderId;
  const AdminOrderDetailsStarted(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class AdminOrderStatusUpdateRequested extends AdminOrderDetailsEvent {
  final int orderId;
  final String status;

  const AdminOrderStatusUpdateRequested({
    required this.orderId,
    required this.status,
  });

  @override
  List<Object?> get props => [orderId, status];
}

/// manual payment state change
class AdminOrderPaymentStateUpdateRequested extends AdminOrderDetailsEvent {
  final int orderId;
  final String paymentState; // UNPAID / PARTIAL / PAID
  final double? amount; // for PARTIAL (optional)

  const AdminOrderPaymentStateUpdateRequested({
    required this.orderId,
    required this.paymentState,
    this.amount,
  });

  @override
  List<Object?> get props => [orderId, paymentState, amount];
}
