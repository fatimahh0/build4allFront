import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminTokenStore {
  final FlutterSecureStorage _storage;

  const AdminTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _keyToken = 'admin_token';
  static const _keyRole = 'admin_role';

  Future<void> save({required String token, required String role}) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyRole, value: role);
  }

  Future<String?> getToken() => _storage.read(key: _keyToken);

  Future<String?> getRole() => _storage.read(key: _keyRole);

  Future<void> clear() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyRole);
  }
}
