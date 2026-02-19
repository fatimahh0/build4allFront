import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/delete_coupon.dart';
import '../../domain/usecases/get_coupons.dart';
import '../../domain/usecases/save_coupon.dart';

import 'coupon_event.dart';
import 'coupon_state.dart';

class CouponBloc extends Bloc<CouponEvent, CouponState> {
  final GetCoupons getCouponsUc;
  final SaveCoupon saveCouponUc;
  final DeleteCoupon deleteCouponUc;

  CouponBloc({
    required this.getCouponsUc,
    required this.saveCouponUc,
    required this.deleteCouponUc,
  }) : super(CouponState.initial()) {
    on<CouponsStarted>(_onStarted);
    on<CouponsRefreshed>(_onRefreshed);
    on<CouponSaveRequested>(_onSaveCoupon);
    on<CouponDeleteRequested>(_onDeleteCoupon);
    on<CouponMessagesCleared>(_onMessagesCleared);
  }

  Future<void> _load(
    Emitter<CouponState> emit, {
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        emit(
          state.copyWith(
            isLoading: true,
            errorMessage: null,
            lastMessage: null,
          ),
        );
      }

      // ✅ backend uses tenant from token
      final list = await getCouponsUc();
      emit(state.copyWith(isLoading: false, coupons: list));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onStarted(CouponsStarted event, Emitter<CouponState> emit) async {
    await _load(emit);
  }

  Future<void> _onRefreshed(
    CouponsRefreshed event,
    Emitter<CouponState> emit,
  ) async {
    await _load(emit, showLoading: false);
  }

  Future<void> _onSaveCoupon(
    CouponSaveRequested event,
    Emitter<CouponState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          isSaving: true,
          errorMessage: null,
          lastMessage: null,
        ),
      );

      // ✅ no ownerProjectId injection anymore
      final saved = await saveCouponUc(event.coupon);

      final updatedList = [
        ...state.coupons.where((c) => c.id != saved.id),
        saved,
      ]..sort((a, b) => a.code.compareTo(b.code));

      emit(
        state.copyWith(
          isSaving: false,
          coupons: updatedList,
          lastMessage: 'coupon_saved',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteCoupon(
    CouponDeleteRequested event,
    Emitter<CouponState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          isSaving: true,
          errorMessage: null,
          lastMessage: null,
        ),
      );

      await deleteCouponUc(event.couponId);

      final list = state.coupons.where((c) => c.id != event.couponId).toList();

      emit(
        state.copyWith(
          isSaving: false,
          coupons: list,
          lastMessage: 'coupon_deleted',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  void _onMessagesCleared(
    CouponMessagesCleared event,
    Emitter<CouponState> emit,
  ) {
    emit(state.copyWith(lastMessage: null, errorMessage: null));
  }
}
