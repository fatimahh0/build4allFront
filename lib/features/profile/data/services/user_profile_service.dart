import 'package:dio/dio.dart';
import 'package:build4front/core/network/globals.dart' as g;
import 'package:build4front/core/config/env.dart';

class UserProfileService {
  final Dio _dio = g.appDio!;

  String get _apiRoot {
    // g.appServerRoot might be "http://x:8080" OR "http://x:8080/api"
    final raw = (g.appServerRoot ?? '').trim().isNotEmpty
        ? (g.appServerRoot ?? '').trim()
        : Env.apiBaseUrl.trim();

    final noTrail = raw.replaceFirst(RegExp(r'/+$'), '');
    final noApi = noTrail.replaceFirst(RegExp(r'/api$'), '');
    return '$noApi/api';
  }

  String get _base => '$_apiRoot/users';

  Future<Map<String, dynamic>> fetchProfileMap({
    required String token,
    required int userId,
  }) async {
    final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;

    final res = await _dio.get(
      '$_base/$userId',
      queryParameters: {'ownerProjectLinkId': ownerId},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return (res.data as Map).cast<String, dynamic>();
  }

  Future<void> updateVisibility({
    required String token,
    required bool isPublic,
  }) async {
    final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;

    await _dio.put(
      '$_base/profile-visibility',
      queryParameters: {'isPublic': isPublic, 'ownerProjectLinkId': ownerId},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
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
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
