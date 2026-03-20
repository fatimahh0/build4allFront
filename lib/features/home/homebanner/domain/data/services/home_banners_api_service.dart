import 'package:build4front/core/config/env.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class HomeBannersApiService {
  final Dio _dio;

  HomeBannersApiService(this._dio);

  factory HomeBannersApiService.create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    return HomeBannersApiService(dio);
  }

  Future<List<Map<String, dynamic>>> fetchActiveBanners({
    required String token,
  }) async {
    try {
      final trimmedToken = token.trim();

      final headers = <String, dynamic>{};
      if (trimmedToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $trimmedToken';
      }

      final res = await _dio.get(
        '/api/home-banners',
        options: Options(headers: headers.isEmpty ? null : headers),
      );

      if (kDebugMode) {
        debugPrint('HomeBannersApiService: status=${res.statusCode}');
      }

      final data = res.data;

      if (data == null) return const [];

      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }

      return const [];
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      if (kDebugMode) {
        debugPrint(
          'HomeBannersApiService DioException: status=$status, data=${e.response?.data}',
        );
      }

      if (status == 404) {
        return const [];
      }

      rethrow;
    }
  }
}