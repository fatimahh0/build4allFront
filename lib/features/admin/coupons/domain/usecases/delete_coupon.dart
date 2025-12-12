import '../repositories/coupon_repository.dart';

class DeleteCoupon {
  final CouponRepository repo;

  DeleteCoupon(this.repo);

  Future<void> call(int id) => repo.deleteCoupon(id);
}
