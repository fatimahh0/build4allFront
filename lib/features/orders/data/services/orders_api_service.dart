import 'package:dio/dio.dart';
import 'package:build4front/features/auth/data/services/auth_token_store.dart';
import 'package:build4front/core/network/globals.dart' as g;

class OrdersApiService {
  final Dio _dio;
  final AuthTokenStore tokenStore;

  OrdersApiService({Dio? dio, required this.tokenStore})
      : _dio = dio ?? g.dio();

  Future<Map<String, String>> _authHeaders() async {
    final token = await tokenStore.getToken();

    if (token == null || token.trim().isEmpty) {
      // ✅ do NOT throw here
      // let the request go through so 401 can trigger refresh interceptor
      return {};
    }

    final t = token.trim();
    final bearer = t.toLowerCase().startsWith('bearer ') ? t : 'Bearer $t';
    return {'Authorization': bearer};
  }

  String _extractError(dynamic data, {int? statusCode}) {
    if (data is Map) {
      final err = data['error'] ?? data['message'];
      final reqId = data['requestId'];
      if (err != null && reqId != null) {
        return '${err.toString()} (requestId: ${reqId.toString()})';
      }
      if (err != null) return err.toString();
    }
    return 'Request failed${statusCode != null ? " (HTTP $statusCode)" : ""}.';
  }

  Future<List<dynamic>> getMyOrdersRaw() async {
    final headers = await _authHeaders();

    final res = await _dio.get(
      '/api/orders/myorders',
      options: Options(headers: headers),
    );

    final data = res.data;

    if (data is List) return data;

    if (data is Map) {
      final orders = data['orders'];
      if (orders is List) return orders;

      final inner = data['data'];
      if (inner is Map && inner['orders'] is List) {
        return inner['orders'] as List;
      }
    }

    return const [];
  }

  Future<Map<String, dynamic>> getOrderDetailsRaw(int orderId) async {
    final headers = await _authHeaders();

    final candidates = <String>[
   
      '/api/orders/myorders/$orderId',
    ];

    DioException? lastDioError;

    for (final path in candidates) {
      try {
        final res = await _dio.get(
          path,
          options: Options(headers: headers),
        );

        final data = res.data;
        if (data is Map) return data.cast<String, dynamic>();
        return {'data': data};
      } on DioException catch (e) {
        final sc = e.response?.statusCode ?? 0;

        // ✅ route not found? try next one
        if (sc == 404) continue;

        // ✅ auth issue? DO NOT swallow it
        // if refresh failed, let it bubble up
        if (sc == 401 || sc == 403) {
          rethrow;
        }

        // ✅ backend/server issue -> save and try next candidate
        if (sc >= 500) {
          lastDioError = e;
          continue;
        }

        // network/no-response or other 4xx
        throw Exception(
          _extractError(e.response?.data, statusCode: sc == 0 ? null : sc),
        );
      } catch (e) {
        throw Exception(e.toString());
      }
    }

    if (lastDioError != null) {
      throw Exception(
        _extractError(
          lastDioError!.response?.data,
          statusCode: lastDioError!.response?.statusCode,
        ),
      );
    }

    throw Exception('Order details endpoint not found (no matching route).');
  }
}