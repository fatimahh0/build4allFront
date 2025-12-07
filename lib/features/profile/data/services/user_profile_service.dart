// lib/features/profile/data/services/user_profile_service.dart

import 'package:dio/dio.dart';
import 'package:build4front/core/network/globals.dart' as g;
import 'package:build4front/core/config/env.dart';

class UserProfileService {
  final Dio _dio = g.appDio!;
  String get _base => '${g.appServerRoot}/api/users';

  // GET /api/users/{id}?ownerProjectLinkId=...
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

  // PUT /api/users/profile-visibility?isPublic=true|false&ownerProjectLinkId=...
  Future<void> updateVisibility({
    required String token,
    required bool isPublic,
  }) async {
    final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;

    final res = await _dio.put(
      '$_base/profile-visibility',
      queryParameters: {'isPublic': isPublic, 'ownerProjectLinkId': ownerId},
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        responseType: ResponseType.plain,
      ),
    );

    if (res.statusCode != 200) {
      // backend often returns empty body for 403, so give a useful error
      throw Exception(
        'Failed to update visibility (status: ${res.statusCode})',
      );
    }
  }

  // PUT /api/users/{id}/status?ownerProjectLinkId=...   body:{status, password?}
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

    final res = await _dio.put(
      '$_base/$userId/status',
      queryParameters: {'ownerProjectLinkId': ownerId},
      data: body,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        responseType: ResponseType.plain,
      ),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update status (status: ${res.statusCode})');
    }
  }
}
