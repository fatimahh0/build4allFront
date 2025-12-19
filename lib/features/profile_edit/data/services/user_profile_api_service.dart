import 'dart:io';
import 'package:dio/dio.dart';

class UserProfileApiService {
  final Dio dio;
  final String baseUrl;

  UserProfileApiService({required this.dio, required this.baseUrl});

  // ---- helpers ----
  String _cleanToken(String token) {
    final t = token.trim();
    return t.toLowerCase().startsWith('bearer ') ? t.substring(7).trim() : t;
  }

  // Ensures baseUrl ends as: http://IP:PORT/api
  String _apiRoot() {
    var b = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    b = b.replaceAll('/api/api', '/api');
    if (!b.endsWith('/api')) b = '$b/api';
    return b;
  }

  Options _authJson(String token) =>
      Options(headers: {'Authorization': 'Bearer ${_cleanToken(token)}'});

  Options _authMultipart(String token) => Options(
    headers: {'Authorization': 'Bearer ${_cleanToken(token)}'},
    contentType: Headers.multipartFormDataContentType,
  );

  // ---- API ----
  Future<Map<String, dynamic>> getUserById({
    required String token,
    required int userId,
    required int ownerProjectLinkId,
  }) async {
    final res = await dio.get(
      '${_apiRoot()}/users/$userId',
      queryParameters: {'ownerProjectLinkId': ownerProjectLinkId},
      options: _authJson(token),
    );
    return (res.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required int userId,
    required int ownerProjectLinkId,
    required String firstName,
    required String lastName,
    String? username,
    bool? isPublicProfile,
    String? imageFilePath,
    bool imageRemoved = false,
  }) async {
    final form = FormData.fromMap({
      'firstName': firstName,
      'lastName': lastName,

      // ✅ safest with Spring @RequestParam: send booleans as "true"/"false"
      if (username != null) 'username': username,
      if (isPublicProfile != null)
        'isPublicProfile': isPublicProfile.toString(),
      'imageRemoved': imageRemoved.toString(),

      if (imageFilePath != null)
        'profileImage': await MultipartFile.fromFile(
          imageFilePath,
          filename: File(imageFilePath).uri.pathSegments.last,
        ),
    });

    final res = await dio.put(
      '${_apiRoot()}/users/$userId/profile',
      queryParameters: {'ownerProjectLinkId': ownerProjectLinkId},
      data: form,
      options: _authMultipart(token),
    );

    return (res.data as Map).cast<String, dynamic>();
  }

  Future<void> deleteUser({
    required String token,
    required int userId,
    required String password,
  }) async {
    await dio.delete(
      '${_apiRoot()}/users/$userId',
      data: {'password': password},
      options: _authJson(token),
    );
  }
}
