// lib/app/app.dart

import 'package:flutter/material.dart';
import '../core/config/app_config.dart';
import '../core/theme/theme_loader.dart';
import '../features/shell/presentation/screens/main_shell.dart';

class Build4AllFrontApp extends StatelessWidget {
  const Build4AllFrontApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1) Read config from Env (APP_NAME, NAV_JSON, ENABLED_FEATURES_JSON...)
    final appConfig = AppConfig.fromEnv();

    // 2) Build ThemeData from THEME_JSON (stored in DB as JSON column)
    final themeData = ThemeLoader.loadTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appConfig.appName,
      theme: themeData,
      home: MainShell(appConfig: appConfig),
    );
  }
}
