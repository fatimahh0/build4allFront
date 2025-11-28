// lib/features/auth/data/services/auth_token_store.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenStore {
  final FlutterSecureStorage _storage;

  const AuthTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _keyToken = 'auth_token';
  static const _keyWasInactive = 'was_inactive';

  
  Future<void> saveToken({
    required String token,
    bool wasInactive = false,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyWasInactive, value: wasInactive.toString());
  }

  
  Future<String?> getToken() => _storage.read(key: _keyToken);


  Future<bool> getWasInactive() async {
    final v = await _storage.read(key: _keyWasInactive);
    if (v == null) return false;
    return v.toLowerCase() == 'true';
  }

 
  Future<void> clear() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyWasInactive);
  }
}
