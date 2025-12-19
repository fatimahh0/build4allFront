import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenStore {
  final FlutterSecureStorage _storage;

  const AuthTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _keyToken = 'auth_token';
  static const _keyWasInactive = 'was_inactive';
  static const _keyUserJson = 'auth_user_json';

  // ✅ NEW
  static const _keyUserId = 'auth_user_id';

  Future<void> saveToken({
    required String token,
    bool wasInactive = false,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyWasInactive, value: wasInactive.toString());
  }

  Future<String?> getToken() => _storage.read(key: _keyToken);

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

  // ✅ NEW: save/get userId directly (super reliable)
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
  }
}
