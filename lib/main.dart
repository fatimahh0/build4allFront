import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'core/theme/theme_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    BlocProvider(create: (_) => ThemeCubit(), child: const Build4AllFrontApp()),
  );
}
