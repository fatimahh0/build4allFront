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
class AdminOrderMarkCashPaidRequested extends AdminOrderDetailsEvent {
  final int orderId;
  const AdminOrderMarkCashPaidRequested({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class AdminOrderResetCashUnpaidRequested extends AdminOrderDetailsEvent {
  final int orderId;
  const AdminOrderResetCashUnpaidRequested({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class AdminOrderCancelAndUnpayRequested extends AdminOrderDetailsEvent {
  final int orderId;
  const AdminOrderCancelAndUnpayRequested({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class AdminOrderReopenRequested extends AdminOrderDetailsEvent {
  final int orderId;
  const AdminOrderReopenRequested({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}
