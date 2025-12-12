import 'package:build4front/features/admin/coupons/domain/entities/coupon.dart';
import 'package:equatable/equatable.dart';


abstract class CouponEvent extends Equatable {
  const CouponEvent();

  @override
  List<Object?> get props => [];
}

class CouponsStarted extends CouponEvent {
  const CouponsStarted();
}

class CouponsRefreshed extends CouponEvent {
  const CouponsRefreshed();
}

class CouponSaveRequested extends CouponEvent {
  final Coupon coupon;

  const CouponSaveRequested({required this.coupon});

  @override
  List<Object?> get props => [coupon];
}

class CouponDeleteRequested extends CouponEvent {
  final int couponId;

  const CouponDeleteRequested({required this.couponId});

  @override
  List<Object?> get props => [couponId];
}

class CouponMessagesCleared extends CouponEvent {
  const CouponMessagesCleared();
}
