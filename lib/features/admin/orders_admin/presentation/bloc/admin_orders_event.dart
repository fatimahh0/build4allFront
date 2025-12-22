import 'package:equatable/equatable.dart';

abstract class AdminOrdersEvent extends Equatable {
  const AdminOrdersEvent();

  @override
  List<Object?> get props => [];
}

class AdminOrdersStarted extends AdminOrdersEvent {
  const AdminOrdersStarted();
}

class AdminOrdersRefreshRequested extends AdminOrdersEvent {
  const AdminOrdersRefreshRequested();
}

class AdminOrdersStatusChanged extends AdminOrdersEvent {
  final String? status; // null => ALL

  const AdminOrdersStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}
