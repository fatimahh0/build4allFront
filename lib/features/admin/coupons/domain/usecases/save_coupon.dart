import '../entities/coupon.dart';
import '../repositories/coupon_repository.dart';

class SaveCoupon {
  final CouponRepository repo;

  SaveCoupon(this.repo);

  Future<Coupon> call(Coupon coupon) {
    if (coupon.id == 0) {
      return repo.createCoupon(coupon);
    } else {
      return repo.updateCoupon(coupon);
    }
  }
}
