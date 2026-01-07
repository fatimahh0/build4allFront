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

  /// ✅ FIX: pass userId in path so backend doesn't rely on token identity
  Future<void> updateVisibility({
    required String token,
    required int userId,
    required bool isPublic,
    required int ownerProjectLinkId,
  }) async {
    await _dio.put(
      '$_base/$userId/profile-visibility',
      queryParameters: {
        'isPublic': isPublic,
        'ownerProjectLinkId': ownerProjectLinkId,
      },
      data: const {},
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
    required int ownerProjectLinkId,
    String? password,
  }) async {
    final body = <String, dynamic>{'status': status};
    if (status.toUpperCase() == 'INACTIVE' && (password?.isNotEmpty ?? false)) {
      body['password'] = password;
    }

    await _dio.put(
      '$_base/$userId/status',
      queryParameters: {'ownerProjectLinkId': ownerProjectLinkId},
      data: body,
      options: Options(
        headers: {'Authorization': 'Bearer ${_cleanToken(token)}'},
        responseType: ResponseType.json,
        validateStatus: (s) => s != null && s >= 200 && s < 300,
      ),
    );
  }
}
