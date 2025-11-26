import 'package:build4front/features/auth/data/repository/auth_repository_impl.dart';
import 'package:build4front/features/auth/data/services/auth_api_service.dart';
import 'package:build4front/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


import '../core/config/app_config.dart';
import '../core/theme/theme_cubit.dart';

import '../features/auth/domain/usecases/login_with_email.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/screens/user_login_screen.dart';

class Build4AllFrontApp extends StatelessWidget {
  const Build4AllFrontApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appConfig = AppConfig.fromEnv();

    final apiService = AuthApiService();
    final authRepo = AuthRepositoryImpl(api: apiService);
    final loginUsecase = LoginWithEmail(authRepo);

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (_) => AuthBloc(loginWithEmail: loginUsecase),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: appConfig.appName,
            theme: themeState.themeData,

        
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,

            localeResolutionCallback: (locale, supported) {
              if (locale == null) return supported.first;
              for (final l in supported) {
                if (l.languageCode == locale.languageCode) {
                  return l;
                }
              }
              return supported.first;
            },

            home: UserLoginScreen(appConfig: appConfig),
          ),
        );
      },
    );
  }
}
