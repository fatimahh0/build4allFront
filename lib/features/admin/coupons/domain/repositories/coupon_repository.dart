import 'package:build4front/features/admin/coupons/domain/entities/coupon.dart';

abstract class CouponRepository {
  Future<List<Coupon>> listCoupons();
  Future<Coupon> createCoupon(Coupon coupon);
  Future<Coupon> updateCoupon(Coupon coupon);
  Future<void> deleteCoupon(int id);
}
