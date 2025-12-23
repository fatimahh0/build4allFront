import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale?> {
  static const _key = 'app_locale';

  LocaleCubit() : super(null) {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final sp = await SharedPreferences.getInstance();
    final code = sp.getString(_key);
    if (code == null || code.isEmpty) return;
    emit(Locale(code));
  }

  Future<void> setLocale(Locale? locale) async {
    emit(locale);

    final sp = await SharedPreferences.getInstance();
    if (locale == null) {
      await sp.remove(_key);
    } else {
      await sp.setString(_key, locale.languageCode);
    }
  }
}
