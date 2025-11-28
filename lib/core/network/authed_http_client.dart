import 'package:http/http.dart' as http;
import 'package:build4front/features/auth/data/services/auth_api_service.dart';

class AuthedHttpClient extends http.BaseClient {
  final http.Client _inner;
  final AuthApiService _authApi;

  AuthedHttpClient({required AuthApiService authApi, http.Client? inner})
    : _authApi = authApi,
      _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _authApi.getSavedToken();

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = token.startsWith('Bearer ')
          ? token
          : 'Bearer $token';
    }

    return _inner.send(request);
  }
}
