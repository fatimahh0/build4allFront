import 'package:build4front/core/config/env.dart';
import 'package:build4front/features/home/homebanner/domain/entities/home_banner.dart';
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

  Future<List<HomeBanner>> fetchActiveBanners({
    required int ownerProjectId,
    required String token,
  }) async {
    try {
      final response = await _dio.get(
        '/api/home-banners',
        queryParameters: {'ownerProjectId': ownerProjectId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (kDebugMode) {
        debugPrint(
          'HomeBannersApiService: status=${response.statusCode}, data=${response.data}',
        );
      }

      final data = response.data;
      if (data is List) {
        return data
            .map((e) => HomeBanner.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
          'HomeBannersApiService DioException: status=${e.response?.statusCode}, data=${e.response?.data}',
        );
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HomeBannersApiService error: $e');
      }
      rethrow;
    }
  }
}
