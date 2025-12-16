import 'package:shared_preferences/shared_preferences.dart';

class SessionRoleStore {
  static const _kRole = 'last_session_role'; // 'user' | 'admin'

  Future<void> saveRole(String role) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kRole, role);
  }

  Future<String?> getRole() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString(_kRole);
    return (v == null || v.trim().isEmpty) ? null : v;
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kRole);
  }
}
