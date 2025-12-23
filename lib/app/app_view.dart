// lib/app/app_view.dart

import 'package:build4front/core/network/connecting(wifiORserver)/connection_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:build4front/l10n/app_localizations.dart';
import 'package:build4front/core/l10n/locale_cubit.dart'; // ✅ ADD

import '../core/config/app_config.dart';
import '../core/theme/theme_cubit.dart';

import 'app_router.dart';

class AppView extends StatelessWidget {
  final AppConfig appConfig;

  const AppView({super.key, required this.appConfig});

  @override
  Widget build(BuildContext context) {
    // ✅ Theme + Locale both rebuild MaterialApp
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<LocaleCubit, Locale?>(
          builder: (context, locale) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: appConfig.appName,
              theme: themeState.themeData,

              // ✅ THIS is what makes language actually change
              locale: locale,

              // Localization setup
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              localeResolutionCallback: (deviceLocale, supported) {
                // ✅ If user selected a locale, MaterialApp.locale wins anyway.
                // This callback is mainly for fallback when locale == null.
                if (deviceLocale == null) return supported.first;
                for (final l in supported) {
                  if (l.languageCode == deviceLocale.languageCode) return l;
                }
                return supported.first;
              },

              // Centralized routing
              initialRoute: AppRouter.initialRoute,
              onGenerateRoute: (settings) =>
                  AppRouter.onGenerateRoute(settings, appConfig),

              // Wrap the whole app with a top connection banner (like WhatsApp)
              builder: (context, child) {
                return Column(
                  children: [
                    const ConnectionBanner(),
                    Expanded(child: child ?? const SizedBox.shrink()),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
