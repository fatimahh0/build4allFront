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
      // no token -> act like not logged in
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
    if (data is List) return data;
    return const [];
  }
}
