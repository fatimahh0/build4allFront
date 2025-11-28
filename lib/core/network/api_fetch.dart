import 'package:dio/dio.dart';
import 'package:build4front/core/network/globals.dart' as g;
import 'package:build4front/core/network/api_methods.dart';

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

    switch (method) {
      case HttpMethod.get:
        return _dio.get('$url${_query(data)}', options: opts);
      case HttpMethod.post:
        return _dio.post(url, data: data, options: opts);
      case HttpMethod.put:
        return _dio.put(url, data: data, options: opts);
      case HttpMethod.delete:
        return _dio.delete(url, data: data, options: opts);
      case HttpMethod.patch:
        _token = CancelToken();
        return _dio.patch(url, data: data, options: opts, cancelToken: _token);
      default:
        throw ArgumentError('Invalid HTTP method: $method');
    }
  }
}
