import 'package:equatable/equatable.dart';

enum OrdersFilter { all, pending, completed, canceled }

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();
  @override
  List<Object?> get props => [];
}

class OrdersStarted extends OrdersEvent {
  const OrdersStarted();
}

class OrdersRefreshRequested extends OrdersEvent {
  const OrdersRefreshRequested();
}

class OrdersFilterChanged extends OrdersEvent {
  final OrdersFilter filter;
  const OrdersFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}
