import 'dart:io';
import 'package:dio/dio.dart';
import 'package:build4front/core/network/globals.dart' as g;

class ExcelImportApiService {
  final Dio _dio;
  final Future<String?> Function() getToken;

  ExcelImportApiService({Dio? dio, required this.getToken})
      : _dio = dio ?? g.dio();

  String _cleanToken(String token) {
    final t = token.trim();
    return t.toLowerCase().startsWith('bearer ')
        ? t.substring(7).trim()
        : t;
  }

  Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer ${_cleanToken(token)}'});

  Future<String> _requireToken() async {
    final token = await getToken();
    if (token == null || token.trim().isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/admin/import/excel'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/admin/import/excel'),
          statusCode: 401,
          data: {'error': 'No token found. Please login again.'},
        ),
        type: DioExceptionType.badResponse,
      );
    }
    return token;
  }

  Future<Map<String, dynamic>> validateExcel(File file) async {
    final token = await _requireToken();

    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      ),
    });

    final res = await _dio.post(
      '/api/admin/import/excel/validate',
      data: form,
      options: _auth(token),
    );

    final data = res.data;
    if (data is Map) return data.cast<String, dynamic>();
    return const {};
  }

  Future<Map<String, dynamic>> importExcel({
    required File file,
    required bool replace,
    required String replaceScope, // TENANT | FULL
  }) async {
    final token = await _requireToken();

    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      ),
    });

    final res = await _dio.post(
      '/api/admin/import/excel',
      queryParameters: {
        'replace': replace,
        'replaceScope': replaceScope,
      },
      data: form,
      options: _auth(token),
    );

    final data = res.data;
    if (data is Map) return data.cast<String, dynamic>();
    return const {};
  }
}
