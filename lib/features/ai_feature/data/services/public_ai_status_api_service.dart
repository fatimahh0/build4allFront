import 'package:dio/dio.dart';
import 'package:build4front/core/network/globals.dart' as g;

class PublicAiStatusApiService {
  Future<bool?> fetchAiEnabled({required int linkId}) async {
    try {
      final Dio dio = g.dio();
      final res = await dio.get(
        '/api/public/ai/status',
        queryParameters: {'linkId': linkId},
      );

      if (res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        final v = map['aiEnabled'];
        if (v is bool) return v;
        if (v is num) return v != 0;
        if (v is String) {
          final s = v.toLowerCase().trim();
          if (s == 'true' || s == '1') return true;
          if (s == 'false' || s == '0') return false;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
