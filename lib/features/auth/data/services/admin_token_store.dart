import 'package:shared_preferences/shared_preferences.dart';

class AdminTokenStore {
  static const _kAdminToken = 'admin_token';
  static const _kAdminRole = 'admin_role';

  Future<void> save({required String token, required String role}) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kAdminToken, token);
    await sp.setString(_kAdminRole, role);
  }

  Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kAdminToken);
  }

  Future<String?> getRole() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kAdminRole);
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kAdminToken);
    await sp.remove(_kAdminRole);
  }
}
