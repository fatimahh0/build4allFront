import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:build4front/core/network/globals.dart' as g;
import 'package:build4front/features/auth/data/services/auth_token_store.dart';
import 'package:build4front/features/auth/data/services/admin_token_store.dart';

class RefreshTokenInterceptor extends Interceptor {
  final Dio dio;
  final AuthTokenStore userStore;
  final AdminTokenStore adminStore;

  Completer<void>? _userRefreshing;
  Completer<void>? _adminRefreshing;

  RefreshTokenInterceptor({
    required this.dio,
    required this.userStore,
    required this.adminStore,
  });

  Dio _plain() {
    return Dio(
      BaseOptions(
        baseUrl: g.appServerRoot,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
  }

  bool _isAuthCall(RequestOptions o) {
    final p = o.path;
    return p.contains('/api/auth/refresh') ||
        p.contains('/api/auth/logout') ||
        p.contains('/api/auth/user/login') ||
        p.contains('/api/auth/user/login-phone') ||
        p.contains('/api/auth/admin/login') ||
        p.contains('/api/auth/admin/login/front') ||
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
      return map['role']?.toString().toUpperCase().trim();
    } catch (_) {
      return null;
    }
  }

  bool _isAdminRole(String? role) {
    if (role == null) return false;
    return role == 'OWNER' || role == 'SUPER_ADMIN' || role == 'MANAGER' || role == 'ADMIN';
  }

  String _currentTenantId() {
    return (g.ownerProjectLinkId ?? '').toString().trim();
  }

  Future<void> _refreshUser() async {
    if (_userRefreshing != null) return _userRefreshing!.future;
    _userRefreshing = Completer<void>();

    try {
      final refresh = (await userStore.getRefreshToken())?.trim() ?? '';
      if (refresh.isEmpty) throw Exception('NO_USER_REFRESH');

      final res = await _plain().post(
        '/api/auth/refresh',
        data: {'refreshToken': refresh},
      );

      final data = (res.data is Map)
          ? Map<String, dynamic>.from(res.data as Map)
          : <String, dynamic>{};

      final newAccess = (data['token'] ?? '').toString();
      final newRefresh = (data['refreshToken'] ?? '').toString();

      if (newAccess.isEmpty || newRefresh.isEmpty) {
        throw Exception('BAD_REFRESH_RESPONSE');
      }

      await userStore.saveToken(
        token: newAccess,
        wasInactive: false,
        refreshToken: newRefresh,
        tenantId: _currentTenantId(),
      );

      // ✅ updates dio default Authorization too
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
      final refresh = (await adminStore.getRefreshToken())?.trim() ?? '';
      if (refresh.isEmpty) throw Exception('NO_ADMIN_REFRESH');

      final res = await _plain().post(
        '/api/auth/refresh',
        data: {'refreshToken': refresh},
      );

      final data = (res.data is Map)
          ? Map<String, dynamic>.from(res.data as Map)
          : <String, dynamic>{};

      final newAccess = (data['token'] ?? '').toString();
      final newRefresh = (data['refreshToken'] ?? '').toString();

      if (newAccess.isEmpty || newRefresh.isEmpty) {
        throw Exception('BAD_REFRESH_RESPONSE');
      }

      final role = (await adminStore.getRole()) ?? '';

      await adminStore.save(
        token: newAccess,
        role: role,
        refreshToken: newRefresh,
        tenantId: _currentTenantId(),
      );

      // ✅ critical: so admin screens stop acting "logged out"
      g.setAuthToken(newAccess);

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

    // only handle auth failures, and never intercept auth endpoints themselves
    if ((status != 401 && status != 403) || _isAuthCall(req)) {
      return handler.next(err);
    }

    // prevent infinite retry
    if (req.extra['__retried'] == true) {
      return handler.next(err);
    }

    final authHeader = (req.headers['Authorization'] ?? '').toString();
    final raw = _rawTokenFromAuthHeader(authHeader.isEmpty ? g.readAuthToken() : authHeader);
    final role = _roleFromJwt(raw);

    try {
      if (_isAdminRole(role)) {
        await _refreshAdmin();
        final newAdminToken = (await adminStore.getToken())?.trim() ?? '';
        if (newAdminToken.isNotEmpty) {
          req.headers['Authorization'] = 'Bearer $newAdminToken';
        }
      } else {
        await _refreshUser();
        final newUserToken = (await userStore.getToken())?.trim() ?? '';
        if (newUserToken.isNotEmpty) {
          req.headers['Authorization'] = 'Bearer $newUserToken';
        }
      }

      req.extra['__retried'] = true;

      // ✅ retry with SAME dio instance (safe)
      final response = await dio.fetch(req);
      return handler.resolve(response);
    } catch (_) {
      // refresh failed -> hard logout
      await userStore.clear();
      await adminStore.clear();
      g.setAuthToken('');
      return handler.next(err);
    }
  }
}