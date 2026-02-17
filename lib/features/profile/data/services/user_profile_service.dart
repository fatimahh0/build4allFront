import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:build4front/core/network/globals.dart' as g;
import 'package:build4front/core/config/env.dart';

class UserProfileService {
  final Dio _dio = g.appDio!;

  String _cleanToken(String token) {
    final t = token.trim();
    return t.toLowerCase().startsWith('bearer ') ? t.substring(7).trim() : t;
  }

  String get _apiRoot {
    final raw = g.appServerRoot.trim().isNotEmpty
        ? g.appServerRoot.trim()
        : Env.apiBaseUrl.trim();

    final noTrail = raw.replaceFirst(RegExp(r'/+$'), '');
    final noApi = noTrail.replaceFirst(RegExp(r'/api$'), '');
    return '$noApi/api';
  }

  String get _base => '$_apiRoot/users';

  // ---------- helpers ----------

  String _extractMessage(dynamic data) {
    // If backend returns JSON map
    if (data is Map) {
      final m = data.cast<String, dynamic>();
      return (m['error'] ?? m['message'] ?? m['detail'] ?? m['msg'] ?? '').toString();
    }

    // If backend returns a string (plain text OR JSON string)
    if (data is String) {
      final s = data.trim();
      if (s.isEmpty) return '';

      // Try decode JSON string safely
      if (s.startsWith('{') || s.startsWith('[')) {
        try {
          final decoded = jsonDecode(s);
          return _extractMessage(decoded);
        } catch (_) {
          // Not valid JSON, treat as plain
          return s;
        }
      }
      return s;
    }

    return '';
  }

  void _throwBadResponse(Response res) {
    final code = res.statusCode ?? 0;
    final msg = _extractMessage(res.data);
    final fallback = 'Request failed ($code)';

    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      type: DioExceptionType.badResponse,
      message: msg.isNotEmpty ? msg : fallback,
    );
  }

  // ---------- API ----------

  Future<Map<String, dynamic>> fetchProfileMap({
    required String token,
    required int userId,
    required int ownerProjectLinkId,
  }) async {
    final res = await _dio.get(
      '$_base/$userId',
      queryParameters: {'ownerProjectLinkId': ownerProjectLinkId},
      options: Options(
        headers: {'Authorization': 'Bearer ${_cleanToken(token)}'},
        responseType: ResponseType.json,
        receiveDataWhenStatusError: true,
        validateStatus: (s) => s != null && s >= 200 && s < 500,
      ),
    );

    if ((res.statusCode ?? 0) < 200 || (res.statusCode ?? 0) >= 300) {
      _throwBadResponse(res);
    }

    final data = res.data;
    if (data is Map) return data.cast<String, dynamic>();

    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      type: DioExceptionType.unknown,
      message: 'Invalid profile response: expected JSON object',
    );
  }

  /// visibility (keep plain, backend often returns text)
  Future<void> updateVisibility({
    required String token,
    required int userId,
    required bool isPublic,
    required int ownerProjectLinkId,
  }) async {
    final res = await _dio.put(
      '$_base/$userId/profile-visibility',
      queryParameters: {
        'isPublic': isPublic,
        'ownerProjectLinkId': ownerProjectLinkId,
      },
      data: const {},
      options: Options(
        headers: {'Authorization': 'Bearer ${_cleanToken(token)}'},
        responseType: ResponseType.plain,
        receiveDataWhenStatusError: true,
        validateStatus: (s) => s != null && s >= 200 && s < 500,
      ),
    );

    if ((res.statusCode ?? 0) < 200 || (res.statusCode ?? 0) >= 300) {
      _throwBadResponse(res);
    }
  }

  /// ✅ FIXED: status endpoint should NOT be ResponseType.json
  /// because backend usually returns plain text (or empty).
  Future<void> updateStatus({
    required String token,
    required int userId,
    required String status,
    required int ownerProjectLinkId,
    String? password,
  }) async {
    final body = <String, dynamic>{'status': status};

    if (status.toUpperCase() == 'INACTIVE' && (password?.isNotEmpty ?? false)) {
      body['password'] = password;
    }

    final res = await _dio.put(
      '$_base/$userId/status',
      queryParameters: {'ownerProjectLinkId': ownerProjectLinkId},
      data: body,
      options: Options(
        headers: {'Authorization': 'Bearer ${_cleanToken(token)}'},
        responseType: ResponseType.plain, // ✅ important
        receiveDataWhenStatusError: true, // ✅ keep body even on 400/401
        validateStatus: (s) => s != null && s >= 200 && s < 500,
      ),
    );

    if ((res.statusCode ?? 0) < 200 || (res.statusCode ?? 0) >= 300) {
      _throwBadResponse(res);
    }

    // success: ignore body (could be empty or text)
  }
}
