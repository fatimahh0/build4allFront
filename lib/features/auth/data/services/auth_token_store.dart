import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenStore {
  final FlutterSecureStorage _storage;

  const AuthTokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _keyToken = 'auth_token';
  static const _keyWasInactive = 'was_inactive';
  static const _keyUserJson = 'auth_user_json';

  static const _keyUserId = 'auth_user_id';
  static const _keyRefreshToken = 'auth_refresh_token';

  // ✅ NEW (tenant binding)
  static const _keyTenantId = 'auth_tenant_id';

  Future<void> saveToken({
    required String token,
    bool wasInactive = false,
    String? refreshToken,
    String? tenantId,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyWasInactive, value: wasInactive.toString());

    if (refreshToken != null) {
      final v = refreshToken.trim();
      if (v.isEmpty) {
        await _storage.delete(key: _keyRefreshToken);
      } else {
        await _storage.write(key: _keyRefreshToken, value: v);
      }
    }

    if (tenantId != null) {
      final t = tenantId.trim();
      if (t.isEmpty) {
        await _storage.delete(key: _keyTenantId);
      } else {
        await _storage.write(key: _keyTenantId, value: t);
      }
    }
  }

  Future<String?> getToken() => _storage.read(key: _keyToken);

  Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);

  Future<String?> getTenantId() => _storage.read(key: _keyTenantId);

  Future<void> saveUserJson(Map<String, dynamic> json) async {
    await _storage.write(key: _keyUserJson, value: jsonEncode(json));
  }

  Future<Map<String, dynamic>?> getUserJson() async {
    final raw = await _storage.read(key: _keyUserJson);
    if (raw == null || raw.trim().isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    return decoded;
  }

  Future<void> saveUserId(int userId) async {
    await _storage.write(key: _keyUserId, value: userId.toString());
  }

  Future<int> getUserId() async {
    final v = await _storage.read(key: _keyUserId);
    return int.tryParse(v ?? '') ?? 0;
  }

  Future<bool> getWasInactive() async {
    final v = await _storage.read(key: _keyWasInactive);
    if (v == null) return false;
    return v.toLowerCase() == 'true';
  }

  Future<void> clear() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyWasInactive);
    await _storage.delete(key: _keyUserJson);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyTenantId);
  }
}