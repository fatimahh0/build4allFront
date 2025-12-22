import 'package:dio/dio.dart';
import 'package:build4front/features/auth/data/services/auth_token_store.dart';
import 'package:build4front/core/network/globals.dart' as g;

class OrdersApiService {
  final Dio _dio;
  final AuthTokenStore tokenStore;

  OrdersApiService({Dio? dio, required this.tokenStore})
    : _dio = dio ?? g.dio();

  Future<List<dynamic>> getMyOrdersRaw() async {
    final token = await tokenStore.getToken();

    if (token == null || token.trim().isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/orders/myorders'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/orders/myorders'),
          statusCode: 401,
          data: {'error': 'No token found. Please login again.'},
        ),
        type: DioExceptionType.badResponse,
      );
    }

    final bearer = token.startsWith('Bearer ') ? token : 'Bearer $token';

    final res = await _dio.get(
      '/api/orders/myorders',
      options: Options(headers: {'Authorization': bearer}),
    );

    final data = res.data;

    // ✅ current backend: returns List مباشرة
    if (data is List) return data;

    // ✅ future-proof: sometimes backend wraps: { "orders": [ ... ] }
    if (data is Map) {
      final orders = data['orders'];
      if (orders is List) return orders;

      // fallback: { "data": { "orders": [...] } }
      final inner = data['data'];
      if (inner is Map && inner['orders'] is List) {
        return inner['orders'] as List;
      }
    }

    return const [];
  }
}
