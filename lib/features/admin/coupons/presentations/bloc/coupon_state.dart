import 'package:build4front/features/admin/coupons/domain/entities/coupon.dart';
import 'package:equatable/equatable.dart';

class CouponState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final List<Coupon> coupons;
  final String? errorMessage;
  final String? lastMessage; // 'coupon_saved', 'coupon_deleted', ...

  const CouponState({
    required this.isLoading,
    required this.isSaving,
    required this.coupons,
    required this.errorMessage,
    required this.lastMessage,
  });

  factory CouponState.initial() => const CouponState(
    isLoading: false,
    isSaving: false,
    coupons: [],
    errorMessage: null,
    lastMessage: null,
  );

  CouponState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<Coupon>? coupons,
    String? errorMessage,
    String? lastMessage,
  }) {
    return CouponState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      coupons: coupons ?? this.coupons,
      errorMessage: errorMessage,
      lastMessage: lastMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSaving,
    coupons,
    errorMessage,
    lastMessage,
  ];
}
