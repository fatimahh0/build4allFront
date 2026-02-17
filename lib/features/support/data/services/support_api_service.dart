import 'package:build4front/features/support/domain/support_info.dart';
import 'package:dio/dio.dart';
import 'package:build4front/core/network/globals.dart' as g;
import 'package:build4front/core/config/env.dart';



class OwnerSupportService {
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

  // ✅ endpoint base (variant A)
  String get _baseSupport => '$_apiRoot/support';

  // ✅ endpoint base (variant B)
  String get _baseApps => '$_apiRoot/apps';

  /// ✅ Fetch support info for a specific app instance (linkId)
  ///
  /// Tries:
  /// 1) GET /api/support?ownerProjectLinkId=LINK
  /// 2) GET /api/apps/LINK/support
  ///
  /// Returns SupportInfo (ownerName/email/phoneNumber)
  Future<SupportInfo> fetchSupportInfo({
    String? token,
    required int ownerProjectLinkId,
  }) async {
    final headers = <String, String>{};
    final tk = (token ?? '').trim();
    if (tk.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${_cleanToken(tk)}';
    }

    // ---------- Try #1: /support?ownerProjectLinkId= ----------
    try {
    final res = await _dio.get(
  _baseSupport,
  queryParameters: {
    'ownerProjectLinkId': ownerProjectLinkId,
    'linkId': ownerProjectLinkId, // ✅ add this
  },
  options: Options(
    headers: headers.isEmpty ? null : headers,
    responseType: ResponseType.json,
    validateStatus: (s) => s != null && s >= 200 && s < 300,
  ),
);


      final data = res.data;
      if (data is Map) {
        return SupportInfo.fromJson(data.cast<String, dynamic>(), ownerProjectLinkId);
      }

      throw DioException(
        requestOptions: res.requestOptions,
        message: 'Invalid support response: expected JSON object',
      );
    } on DioException catch (e) {
      // ---------- Try #2: /apps/{linkId}/support ----------
      // Only fallback on common "not found/wrong endpoint" types
      final status = e.response?.statusCode;
      final shouldFallback = status == 404 || status == 400;

      if (!shouldFallback) rethrow;

      final res2 = await _dio.get(
        '$_baseApps/$ownerProjectLinkId/support',
        options: Options(
          headers: headers.isEmpty ? null : headers,
          responseType: ResponseType.json,
          validateStatus: (s) => s != null && s >= 200 && s < 300,
        ),
      );

      final data2 = res2.data;
      if (data2 is Map) {
        return SupportInfo.fromJson(
          data2.cast<String, dynamic>(),
          ownerProjectLinkId,
        );
      }

      throw DioException(
        requestOptions: res2.requestOptions,
        message: 'Invalid support response: expected JSON object',
      );
    }
  }
}
