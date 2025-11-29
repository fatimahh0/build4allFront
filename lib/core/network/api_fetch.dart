// lib/core/network/api_fetch.dart

import 'package:dio/dio.dart';
import 'package:build4front/core/network/globals.dart' as g;
import 'package:build4front/core/network/api_methods.dart';

import 'package:build4front/core/exceptions/app_exception.dart';
import 'package:build4front/core/exceptions/network_exception.dart';
import 'package:build4front/core/exceptions/auth_exception.dart';

class ApiFetch {
  final Dio _dio;
  CancelToken? _token;

  ApiFetch([Dio? dio])
    : _dio =
          dio ??
          g.appDio ??
          (throw StateError(
            'ERROR: appDio is NULL — did you call makeDefaultDio()?',
          ));

  void cancel() {
    _token?.cancel('Cancelled');
    _token = null;
  }

  String _query(Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) return '';
    final q = params.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent('${e.value}')}',
        )
        .join('&');
    return '?$q';
  }

  Map<String, dynamic>? _asQuery(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    throw ArgumentError(
      'GET query data must be Map<String, dynamic> or null. Got: ${data.runtimeType}',
    );
  }

  Future<Response> fetch(
    String method,
    String url, {
    dynamic data,
    Map<String, String>? headers,
    Duration? receiveTimeoutOverride,
    ResponseType? responseType,
  }) async {
    final opts = Options(
      headers: headers,
      receiveTimeout: receiveTimeoutOverride,
      responseType: responseType,
    );

    print("🔥 USING DIO INSTANCE: $_dio");
    print("🔥 INTERCEPTORS: ${_dio.interceptors}");

    try {
      Response res;

      switch (method) {
        case HttpMethod.get:
          // For GET we treat `data` as query parameters
          res = await _dio.get('$url${_query(_asQuery(data))}', options: opts);
          break;
        case HttpMethod.post:
          res = await _dio.post(url, data: data, options: opts);
          break;
        case HttpMethod.put:
          res = await _dio.put(url, data: data, options: opts);
          break;
        case HttpMethod.delete:
          res = await _dio.delete(url, data: data, options: opts);
          break;
        case HttpMethod.patch:
          _token = CancelToken();
          res = await _dio.patch(
            url,
            data: data,
            options: opts,
            cancelToken: _token,
          );
          break;
        default:
          throw ArgumentError('Invalid HTTP method: $method');
      }

      // If we reach here, the request succeeded
      // → mark connection as online (clear any serverDown state)
      g.connectionCubit?.setOnline();

      return res;
    } on DioException catch (e) {
      // Low-level network / connection problems (no route, timeout, DNS issues)
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        // Treat as "server unreachable" (Wi-Fi can be ON but backend down)
        g.connectionCubit?.setServerDown('Server is not responding');
        throw NetworkException(
          'No internet or server unreachable',
          original: e,
        );
      }

      final res = e.response;
      final status = res?.statusCode ?? 0;
      final data = res?.data;

      // Try to extract backend message
      String msg = 'Unexpected server error';
      String? code;

      if (data is Map) {
        if (data['error'] != null) msg = data['error'].toString();
        if (data['message'] != null) msg = data['message'].toString();
        if (data['code'] != null) code = data['code'].toString();
      } else if (data is String && data.isNotEmpty) {
        msg = data;
      }

      // Mark server as down for 5xx or missing response
      if (res == null || status >= 500) {
        g.connectionCubit?.setServerDown(msg);
      }

      // Auth-related errors
      if (status == 401 || status == 403) {
        throw AuthException(msg, code: code, original: e);
      }

      // Other HTTP errors
      throw ServerException(msg, statusCode: status, original: e, code: code);
    } catch (e) {
      // Any unexpected error
      throw AppException('Unexpected error', original: e);
    }
  }
}
