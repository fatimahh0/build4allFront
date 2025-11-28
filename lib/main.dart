import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/app/app.dart';
import 'package:build4front/core/config/env.dart';
import 'package:build4front/core/network/globals.dart';
import 'package:build4front/core/theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize global Dio + globals (ownerProjectLinkId, etc.)
  makeDefaultDio(Env.apiBaseUrl);

  // ThemeCubit at the root so BlocBuilder<ThemeCubit> in the app can see it
  runApp(
    BlocProvider(create: (_) => ThemeCubit(), child: const Build4AllFrontApp()),
  );
}
