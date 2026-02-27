import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminTokenStore {
  final FlutterSecureStorage _storage;

  const AdminTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _keyToken = 'admin_token';
  static const _keyRole = 'admin_role';
static const _keyRefreshToken = 'admin_refresh_token';

Future<void> save({
  required String token,
  required String role,
  String? refreshToken, // ✅ NEW
}) async {
  await _storage.write(key: _keyToken, value: token);
  await _storage.write(key: _keyRole, value: role);

  if (refreshToken != null) {
    final v = refreshToken.trim();
    if (v.isEmpty) {
      await _storage.delete(key: _keyRefreshToken);
    } else {
      await _storage.write(key: _keyRefreshToken, value: v);
    }
  }
}

Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);



  Future<String?> getToken() => _storage.read(key: _keyToken);

  Future<String?> getRole() => _storage.read(key: _keyRole);

Future<void> clear() async {
  await _storage.delete(key: _keyToken);
  await _storage.delete(key: _keyRole);
  await _storage.delete(key: _keyRefreshToken); // ✅ NEW
}
}
