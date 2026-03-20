import 'package:build4front/features/admin/orders_admin/data/models/cash_mark_paid_result_model.dart';
import 'package:dio/dio.dart';
import 'package:build4front/core/network/globals.dart' as g;

class AdminOrdersApiService {
  final Dio _dio;
  final Future<String?> Function() getToken;

  AdminOrdersApiService({Dio? dio, required this.getToken})
      : _dio = dio ?? g.dio();

  String _cleanToken(String token) {
    final t = token.trim();
    return t.toLowerCase().startsWith('bearer ')
        ? t.substring(7).trim()
        : t;
  }

  Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer ${_cleanToken(token)}'});

  Future<String> _requireToken() async {
    final token = await getToken();
    if (token == null || token.trim().isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/orders/owner/*'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/orders/owner/*'),
          statusCode: 401,
          data: {'error': 'No token found. Please login again.'},
        ),
        type: DioExceptionType.badResponse,
      );
    }
    return token;
  }

  Future<List<dynamic>> getOrdersRaw({String? status}) async {
    final token = await _requireToken();
    const base = '/api/orders/owner/orders';

    if (status == null || status.trim().isEmpty) {
      final res = await _dio.get(base, options: _auth(token));
      return res.data is List ? res.data : const [];
    }

    final s = status.trim().toUpperCase();
    final res = await _dio.get('$base/status/$s', options: _auth(token));
    return res.data is List ? res.data : const [];
  }

  Future<Map<String, dynamic>> getOrderDetailsRaw({required int orderId}) async {
    final token = await _requireToken();
    final path = '/api/orders/owner/orders/$orderId';
    final res = await _dio.get(path, options: _auth(token));
    return res.data is Map ? (res.data as Map).cast<String, dynamic>() : const {};
  }

  Future<void> updateOrderStatusRaw({
    required int orderId,
    required String status,
  }) async {
    final token = await _requireToken();
    final path = '/api/orders/owner/orders/$orderId/status';

    await _dio.put(
      path,
      options: _auth(token),
      data: {'status': status.trim().toUpperCase()},
    );
  }

  Future<Map<String, dynamic>> editOrderRaw({
  required int orderId,
  required Map<String, dynamic> body,
}) async {
  final token = await _requireToken();
  final path = '/api/orders/owner/orders/$orderId/edit';

  final res = await _dio.put(
    path,
    options: _auth(token),
    data: body,
  );

  return res.data is Map ? (res.data as Map).cast<String, dynamic>() : {};
}

  // ✅ NEW: CASH mark paid
  Future<Map<String, dynamic>> markCashPaidRaw({required int orderId}) async {
    final token = await _requireToken();
    final path = '/api/orders/owner/orders/$orderId/cash/mark-paid';

    final res = await _dio.put(path, options: _auth(token));
    return res.data is Map ? (res.data as Map).cast<String, dynamic>() : const {};
  }

  // ✅ NEW: CASH reset to unpaid
  Future<Map<String, dynamic>> resetCashToUnpaidRaw({required int orderId}) async {
    final token = await _requireToken();
    final path = '/api/orders/owner/orders/$orderId/cash/reset-to-unpaid';

    final res = await _dio.put(path, options: _auth(token));
    return res.data is Map ? (res.data as Map).cast<String, dynamic>() : const {};
  }

  // ✅ NEW: reopen order properly (backend decides status + cash behavior)
  Future<Map<String, dynamic>> reopenOrderRaw({required int orderId}) async {
    final token = await _requireToken();
    final path = '/api/orders/owner/orders/$orderId/reopen';

    final res = await _dio.put(path, options: _auth(token));
    return res.data is Map ? (res.data as Map).cast<String, dynamic>() : const {};
  }


  
}