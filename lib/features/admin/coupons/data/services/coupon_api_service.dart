import 'package:dio/dio.dart';
import 'package:build4front/core/network/api_client.dart';
import 'package:build4front/core/config/env.dart';

import '../models/coupon_model.dart';

class CouponApiService {
  final Dio _dio;

  CouponApiService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  String get _baseUrl => '${Env.apiBaseUrl}/api/coupons';

  Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  Future<List<CouponModel>> listCoupons({
    required int ownerProjectId,
    required String authToken,
  }) async {
    final resp = await _dio.get(
      _baseUrl,
      queryParameters: {'ownerProjectId': ownerProjectId},
      options: _auth(authToken),
    );

    final data = resp.data as List<dynamic>;
    return data
        .map((e) => CouponModel.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<CouponModel> createCoupon(
    CouponModel model, {
    required String authToken,
  }) async {
    final resp = await _dio.post(
      _baseUrl,
      data: model.toJson(),
      options: _auth(authToken),
    );
    return CouponModel.fromJson((resp.data as Map).cast<String, dynamic>());
  }

  Future<CouponModel> updateCoupon(
    CouponModel model, {
    required String authToken,
  }) async {
    final resp = await _dio.put(
      '$_baseUrl/${model.id}',
      data: model.toJson(),
      options: _auth(authToken),
    );
    return CouponModel.fromJson((resp.data as Map).cast<String, dynamic>());
  }

  Future<void> deleteCoupon(int id, {required String authToken}) async {
    await _dio.delete('$_baseUrl/$id', options: _auth(authToken));
  }
}
