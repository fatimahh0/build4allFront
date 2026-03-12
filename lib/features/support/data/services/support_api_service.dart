import 'package:dio/dio.dart';
import 'package:build4front/core/network/globals.dart' as g;
import 'package:build4front/core/config/env.dart';
import 'package:build4front/features/support/domain/support_info.dart';

class OwnerSupportService {
  final Dio _dio;

  OwnerSupportService({Dio? dio}) : _dio = dio ?? g.appDio!;

  String _cleanToken(String token) {
    final t = token.trim();
    return t.toLowerCase().startsWith('bearer ')
        ? t.substring(7).trim()
        : t;
  }

  String get _apiRoot {
    final serverRoot = (g.appServerRoot ?? '').trim();
    final raw = serverRoot.isNotEmpty ? serverRoot : Env.apiBaseUrl.trim();
    final noTrail = raw.replaceFirst(RegExp(r'/+$'), '');
    final noApi = noTrail.replaceFirst(RegExp(r'/api$'), '');
    return '$noApi/api';
  }

  SupportInfo _parseSupport(dynamic data, RequestOptions ro) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      final linkId = (map['linkId'] is num)
          ? (map['linkId'] as num).toInt()
          : int.tryParse('${map['linkId']}') ?? 0;

      return SupportInfo.fromJson(map, linkId);
    }

    throw DioException(
      requestOptions: ro,
      message: 'Invalid support response: expected JSON object',
    );
  }

  Future<SupportInfo> fetchSupportInfo({String? token}) async {
    final tk = token?.trim() ?? '';

    final res = await _dio.get(
      '$_apiRoot/apps/support',
      options: Options(
        headers: tk.isEmpty
            ? null
            : {'Authorization': 'Bearer ${_cleanToken(tk)}'},
        responseType: ResponseType.json,
        receiveDataWhenStatusError: true,
      ),
    );

    return _parseSupport(res.data, res.requestOptions);
  }
}