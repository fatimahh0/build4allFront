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
    final serverRoot = (g.appServerRoot ?? '').trim();
    final raw = serverRoot.isNotEmpty ? serverRoot : Env.apiBaseUrl.trim();

    final noTrail = raw.replaceFirst(RegExp(r'/+$'), '');
    final noApi = noTrail.replaceFirst(RegExp(r'/api$'), '');
    return '$noApi/api';
  }

  // endpoint base (legacy)
  String get _baseSupport => '$_apiRoot/support';

  // endpoint base (new)
  String get _baseApps => '$_apiRoot/apps';

  bool _shouldFallback(DioException e) {
    final s = e.response?.statusCode;

    // network errors / invalid JSON / no response → try fallback
    if (s == null) return true;

    // if it's truly auth-related, don't mask it
    if (s == 401 || s == 403) return false;

    // common wrong-endpoint / legacy mismatch
    if (s == 400 || s == 404 || s == 405 || s == 410) return true;

    // ✅ YOUR CASE: server exploded
    if (s >= 500 && s < 600) return true;

    return false;
  }

  SupportInfo _parseSupport(dynamic data, int linkId, RequestOptions ro) {
    if (data is Map) {
      return SupportInfo.fromJson(Map<String, dynamic>.from(data), linkId);
    }

    throw DioException(
      requestOptions: ro,
      message: 'Invalid support response: expected JSON object',
    );
  }

  Future<Response<dynamic>> _get(
    String url, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) {
    return _dio.get(
      url,
      queryParameters: query,
      options: Options(
        headers: (headers == null || headers.isEmpty) ? null : headers,
        responseType: ResponseType.json,
        validateStatus: (s) => s != null && s >= 200 && s < 300,
      ),
    );
  }

  /// Fetch support info for a specific app instance (linkId)
  ///
  /// Tries:
  /// 1) GET /api/apps/{linkId}/support   ✅ (your Spring controller exists)
  /// 2) GET /api/support?ownerProjectLinkId=LINK&linkId=LINK  (legacy)
  Future<SupportInfo> fetchSupportInfo({
    String? token,
    required int ownerProjectLinkId,
  }) async {
    final headers = <String, String>{};
    final tk = (token ?? '').trim();
    if (tk.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${_cleanToken(tk)}';
    }

    // ---------- Try #1: /apps/{linkId}/support ----------
    try {
      final res1 = await _get(
        '$_baseApps/$ownerProjectLinkId/support',
        headers: headers,
      );
      return _parseSupport(res1.data, ownerProjectLinkId, res1.requestOptions);
    } on DioException catch (e) {
      // Only fallback when it's likely endpoint mismatch / server error / network error
      if (!_shouldFallback(e)) rethrow;
    }

    // ---------- Try #2: legacy /support?ownerProjectLinkId= ----------
    final res2 = await _get(
      _baseSupport,
      query: {
        'ownerProjectLinkId': ownerProjectLinkId,
        'linkId': ownerProjectLinkId, // keep it since your backend expects it sometimes
      },
      headers: headers,
    );

    return _parseSupport(res2.data, ownerProjectLinkId, res2.requestOptions);
  }
}