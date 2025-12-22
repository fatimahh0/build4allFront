import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/admin_orders_repository.dart';
import '../../domain/usecases/get_admin_order_details.dart';
import 'admin_order_details_event.dart';
import 'admin_order_details_state.dart';

class AdminOrderDetailsBloc
    extends Bloc<AdminOrderDetailsEvent, AdminOrderDetailsState> {
  final GetAdminOrderDetails getDetails;
  final AdminOrdersRepository repo;

  AdminOrderDetailsBloc({required this.getDetails, required this.repo})
    : super(AdminOrderDetailsState.initial()) {
    on<AdminOrderDetailsStarted>(_onLoad);
    on<AdminOrderStatusUpdateRequested>(_onUpdateStatus);

    // ✅ NEW
    on<AdminOrderPaymentStateUpdateRequested>(_onUpdatePaymentState);
  }

  Future<void> _onLoad(
    AdminOrderDetailsStarted event,
    Emitter<AdminOrderDetailsState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true, clearMessage: true));
    try {
      final res = await getDetails(orderId: event.orderId);
      emit(state.copyWith(loading: false, data: res, clearError: true));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateStatus(
    AdminOrderStatusUpdateRequested event,
    Emitter<AdminOrderDetailsState> emit,
  ) async {
    emit(state.copyWith(updating: true, clearError: true, clearMessage: true));
    try {
      await repo.updateOrderStatus(
        orderId: event.orderId,
        status: event.status,
      );

      final res = await getDetails(orderId: event.orderId);
      emit(
        state.copyWith(
          updating: false,
          data: res,
          clearError: true,
          message: 'Status updated',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          updating: false,
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  // ✅ NEW
  Future<void> _onUpdatePaymentState(
    AdminOrderPaymentStateUpdateRequested event,
    Emitter<AdminOrderDetailsState> emit,
  ) async {
    emit(state.copyWith(updating: true, clearError: true, clearMessage: true));
    try {
      await repo.updateOrderPaymentState(
        orderId: event.orderId,
        paymentState: event.paymentState,
      );

      final res = await getDetails(orderId: event.orderId);
      emit(
        state.copyWith(
          updating: false,
          data: res,
          clearError: true,
          message: 'Payment updated',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          updating: false,
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
