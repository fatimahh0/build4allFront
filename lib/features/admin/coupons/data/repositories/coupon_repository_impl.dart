import 'package:build4front/features/admin/coupons/domain/entities/coupon.dart';
import 'package:build4front/features/admin/coupons/domain/repositories/coupon_repository.dart';

import '../models/coupon_model.dart';
import '../services/coupon_api_service.dart';

class CouponRepositoryImpl implements CouponRepository {
  final CouponApiService api;
  final Future<String?> Function() getToken;

  CouponRepositoryImpl({required this.api, required this.getToken});

  Future<String> _requireToken() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Missing auth token');
    }
    return token;
  }

  @override
  Future<List<Coupon>> listCoupons() async {
    final token = await _requireToken();

    final models = await api.listCoupons(authToken: token); // ✅ no ownerProjectId
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Coupon> createCoupon(Coupon coupon) async {
    final token = await _requireToken();
    final model = CouponModel.fromEntity(coupon);
    final created = await api.createCoupon(model, authToken: token);
    return created.toEntity();
  }

  @override
  Future<Coupon> updateCoupon(Coupon coupon) async {
    final token = await _requireToken();
    final model = CouponModel.fromEntity(coupon);
    final updated = await api.updateCoupon(model, authToken: token);
    return updated.toEntity();
  }

  @override
  Future<void> deleteCoupon(int id) async {
    final token = await _requireToken();
    return api.deleteCoupon(id, authToken: token);
  }
}
