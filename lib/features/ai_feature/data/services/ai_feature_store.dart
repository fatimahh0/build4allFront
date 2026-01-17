import 'package:shared_preferences/shared_preferences.dart';

class AiFeatureStore {
  static const _kPrefix = 'feature_ai_enabled_';

  String _key(String linkId) => '$_kPrefix$linkId';

  Future<void> saveAiEnabled(
      {required String linkId, required bool enabled}) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_key(linkId), enabled);
  }

  Future<bool?> readAiEnabled({required String linkId}) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_key(linkId));
  }
}
