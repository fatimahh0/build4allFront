import 'package:dio/dio.dart';
import 'package:build4front/core/network/globals.dart' as g;

class ApiClient {
  final Dio dio;

  ApiClient()
    : dio =
          g.appDio ??
          (throw Exception('appDio is null — call makeDefaultDio() first!'));

  void setToken(String token) {
    dio.options.headers['Authorization'] = token.startsWith('Bearer ')
        ? token
        : 'Bearer $token';
  }
}
