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

  Future<Response> _getWithFallback({
    required String basePath,
    String? status,
    required Options options,
  }) async {
    if (status == null || status.trim().isEmpty) {
      return _dio.get(basePath, options: options);
    }

    final s = status.trim().toUpperCase();
    return _dio.get('$basePath/status/$s', options: options);
  }

  Future<List<dynamic>> getOrdersRaw({String? status}) async {
    final token = await _requireToken();
    const base = '/api/orders/owner/orders';

    final res = await _getWithFallback(
      basePath: base,
      status: status,
      options: _auth(token),
    );

    final data = res.data;
    if (data is List) return data;
    return const [];
  }

  Future<Map<String, dynamic>> getOrderDetailsRaw({required int orderId}) async {
    final token = await _requireToken();
    final path = '/api/orders/owner/orders/$orderId';

    final res = await _dio.get(path, options: _auth(token));
    final data = res.data;
    if (data is Map) return data.cast<String, dynamic>();
    return const {};
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


Future<void> updateOrderPaymentStateRaw({
    required int orderId,
    required String paymentState,
  }) async {
    final token = await _requireToken();

    //  keep consistent with your status endpoint
    // If your backend path is different, change ONLY this line.
    final path = '/api/orders/owner/orders/$orderId/cash/mark-paid';

    await _dio.put(
      path,
      options: _auth(token),
      data: {'paymentState': paymentState.trim().toUpperCase()},
    );
  }
}
