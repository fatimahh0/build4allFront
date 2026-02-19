import '../entities/coupon.dart';
import '../repositories/coupon_repository.dart';

class GetCoupons {
  final CouponRepository repo;
  GetCoupons(this.repo);

  Future<List<Coupon>> call() => repo.listCoupons();
}
