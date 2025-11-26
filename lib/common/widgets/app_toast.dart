// lib/common/widgets/app_toast.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/theme_cubit.dart';

class AppToast {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final themeState = context.read<ThemeCubit>().state;
    final colors = themeState.tokens.colors;

    final bg = isError ? colors.error : colors.primary;
    final fg = colors.onPrimary;

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(color: fg)),
          backgroundColor: bg,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}
