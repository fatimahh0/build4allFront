// lib/features/profile/data/services/user_profile_service.dart

import 'package:dio/dio.dart';
import 'package:build4front/core/network/globals.dart' as g;
import 'package:build4front/core/config/env.dart';

class UserProfileService {
  final Dio _dio = g.appDio!;

  // ---- helpers ----
  String _cleanToken(String token) {
    final t = token.trim();
    return t.toLowerCase().startsWith('bearer ') ? t.substring(7).trim() : t;
  }

  String get _apiRoot {
    // g.appServerRoot might be "http://x:8080" OR "http://x:8080/api"
    final raw = g.appServerRoot.trim().isNotEmpty
        ? g.appServerRoot.trim()
        : Env.apiBaseUrl.trim();

    final noTrail = raw.replaceFirst(RegExp(r'/+$'), '');
    final noApi = noTrail.replaceFirst(RegExp(r'/api$'), '');
    return '$noApi/api';
  }

  String get _base => '$_apiRoot/users';

  // ---- API ----

  Future<Map<String, dynamic>> fetchProfileMap({
    required String token,
    required int userId,
  }) async {
    final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;

    final res = await _dio.get(
      '$_base/$userId',
      queryParameters: {'ownerProjectLinkId': ownerId},
      options: Options(
        headers: {'Authorization': 'Bearer ${_cleanToken(token)}'},
        responseType: ResponseType.json,
        validateStatus: (s) => s != null && s >= 200 && s < 300,
      ),
    );

    final data = res.data;
    if (data is Map) return data.cast<String, dynamic>();

    throw DioException(
      requestOptions: res.requestOptions,
      message: 'Invalid profile response: expected JSON object',
    );
  }

  /// ✅ FIXED: prevent JSON parsing crash when backend returns empty body (204/200 empty)
  Future<void> updateVisibility({
    required String token,
    required bool isPublic,
  }) async {
    final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;

    await _dio.put(
      '$_base/profile-visibility',
      queryParameters: {'isPublic': isPublic, 'ownerProjectLinkId': ownerId},

      // ✅ send empty json body (safe)
      data: const {},

      // ✅ critical: don't try to parse empty response as JSON
      options: Options(
        headers: {'Authorization': 'Bearer ${_cleanToken(token)}'},
        responseType: ResponseType.plain,
        validateStatus: (s) => s != null && s >= 200 && s < 300,
      ),
    );
  }

  Future<void> updateStatus({
    required String token,
    required int userId,
    required String status,
    String? password,
  }) async {
    final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;

    final body = <String, dynamic>{'status': status};
    if (status.toUpperCase() == 'INACTIVE' && (password?.isNotEmpty ?? false)) {
      body['password'] = password;
    }

    await _dio.put(
      '$_base/$userId/status',
      queryParameters: {'ownerProjectLinkId': ownerId},
      data: body,
      options: Options(
        headers: {'Authorization': 'Bearer ${_cleanToken(token)}'},
        responseType: ResponseType.json, // this one usually returns JSON
        validateStatus: (s) => s != null && s >= 200 && s < 300,
      ),
    );
  }
}
