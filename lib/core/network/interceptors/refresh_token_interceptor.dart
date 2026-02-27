import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:build4front/core/network/globals.dart' as g;
import 'package:build4front/features/auth/data/services/auth_token_store.dart';
import 'package:build4front/features/auth/data/services/admin_token_store.dart';

class RefreshTokenInterceptor extends Interceptor {
  final _userStore = AuthTokenStore();
  final _adminStore = AdminTokenStore();

  Completer<void>? _userRefreshing;
  Completer<void>? _adminRefreshing;

  Dio _plain() {
    return Dio(BaseOptions(
      baseUrl: g.appServerRoot,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));
  }

  bool _isAuthCall(RequestOptions o) {
    final p = o.path;
    return p.contains('/api/auth/refresh') ||
        p.contains('/api/auth/logout') ||
        p.contains('/api/auth/user/login') ||
        p.contains('/api/auth/user/login-phone') ||
        p.contains('/api/auth/admin/login') ||
        p.contains('/api/auth/manager/login') ||
        p.contains('/api/auth/superadmin/login');
  }

  String _rawTokenFromAuthHeader(String auth) {
    final t = auth.trim();
    if (t.toLowerCase().startsWith('bearer ')) return t.substring(7).trim();
    return t;
  }

  String? _roleFromJwt(String rawJwt) {
    try {
      final parts = rawJwt.split('.');
      if (parts.length < 2) return null;
      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = jsonDecode(decoded);
      if (map is! Map) return null;
      final role = map['role']?.toString();
      return role?.toUpperCase().trim();
    } catch (_) {
      return null;
    }
  }

  bool _isAdminRole(String? role) {
    if (role == null) return false;
    return role == 'OWNER' || role == 'SUPER_ADMIN' || role == 'MANAGER' || role == 'ADMIN';
  }

  Future<void> _refreshUser() async {
    if (_userRefreshing != null) return _userRefreshing!.future;
    _userRefreshing = Completer<void>();

    try {
      final refresh = (await _userStore.getRefreshToken())?.trim() ?? '';
      if (refresh.isEmpty) throw Exception('NO_USER_REFRESH');

      final res = await _plain().post('/api/auth/refresh', data: {'refreshToken': refresh});
      final data = (res.data is Map) ? Map<String, dynamic>.from(res.data as Map) : <String, dynamic>{};

      final newAccess = (data['token'] ?? '').toString();
      final newRefresh = (data['refreshToken'] ?? '').toString();
      if (newAccess.isEmpty || newRefresh.isEmpty) throw Exception('BAD_REFRESH_RESPONSE');

      await _userStore.saveToken(token: newAccess, wasInactive: false, refreshToken: newRefresh);

      // ✅ update global token (user flow uses globals a lot)
      g.setAuthToken(newAccess);

      _userRefreshing!.complete();
    } catch (e) {
      _userRefreshing!.completeError(e);
      rethrow;
    } finally {
      _userRefreshing = null;
    }
  }

  Future<void> _refreshAdmin() async {
    if (_adminRefreshing != null) return _adminRefreshing!.future;
    _adminRefreshing = Completer<void>();

    try {
      final refresh = (await _adminStore.getRefreshToken())?.trim() ?? '';
      if (refresh.isEmpty) throw Exception('NO_ADMIN_REFRESH');

      final res = await _plain().post('/api/auth/refresh', data: {'refreshToken': refresh});
      final data = (res.data is Map) ? Map<String, dynamic>.from(res.data as Map) : <String, dynamic>{};

      final newAccess = (data['token'] ?? '').toString();
      final newRefresh = (data['refreshToken'] ?? '').toString();
      if (newAccess.isEmpty || newRefresh.isEmpty) throw Exception('BAD_REFRESH_RESPONSE');

      final role = (await _adminStore.getRole()) ?? '';
      await _adminStore.save(token: newAccess, role: role, refreshToken: newRefresh);

      _adminRefreshing!.complete();
    } catch (e) {
      _adminRefreshing!.completeError(e);
      rethrow;
    } finally {
      _adminRefreshing = null;
    }
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode ?? 0;
    final req = err.requestOptions;

    if ((status != 401 && status != 403) || _isAuthCall(req)) {
      return handler.next(err);
    }

    // prevent infinite loops
    if (req.extra['__retried'] == true) {
      return handler.next(err);
    }

    // determine role from request auth header (admin screens pass token explicitly)
    final authHeader = (req.headers['Authorization'] ?? '').toString();
    final raw = _rawTokenFromAuthHeader(authHeader.isEmpty ? g.readAuthToken() : authHeader);
    final role = _roleFromJwt(raw);

    try {
      if (_isAdminRole(role)) {
        await _refreshAdmin();
        final newAdminToken = await _adminStore.getToken();
        if (newAdminToken != null && newAdminToken.isNotEmpty) {
          req.headers['Authorization'] = newAdminToken.startsWith('Bearer ') ? newAdminToken : 'Bearer $newAdminToken';
        }
      } else {
        await _refreshUser();
        final newUserToken = await _userStore.getToken();
        if (newUserToken != null && newUserToken.isNotEmpty) {
          req.headers['Authorization'] = newUserToken.startsWith('Bearer ') ? newUserToken : 'Bearer $newUserToken';
        }
      }

      // retry original request
      req.extra['__retried'] = true;
      final response = await g.dio().fetch(req);
      return handler.resolve(response);
    } catch (_) {
      // refresh failed -> clear local auth and bubble error
      await _userStore.clear();
      await _adminStore.clear();
      g.setAuthToken('');
      return handler.next(err);
    }
  }
}