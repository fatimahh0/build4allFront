// lib/common/widgets/app_toast.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/theme_cubit.dart';
import '../../core/exceptions/exception_mapper.dart';

enum AppToastType { success, error, info }

class AppToast {
  static void _show(
    BuildContext context,
    Object message, {
    required AppToastType type,
  }) {
    final themeState = context.read<ThemeCubit>().state;
    final colors = themeState.tokens.colors;

    final clean = ExceptionMapper.toMessage(message);

    Color bg;
    Color fg;

    switch (type) {
      case AppToastType.error:
        bg = colors.error;
        fg = colors.onPrimary;
        break;
      case AppToastType.success:
        bg = colors.primary;
        fg = colors.onPrimary;
        break;
      case AppToastType.info:
        bg = colors.primary;
        fg = colors.onPrimary;
        break;
    }

    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            clean,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: bg,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  static void success(BuildContext context, Object message) {
    _show(context, message, type: AppToastType.success);
  }

  static void error(BuildContext context, Object error) {
    _show(context, error, type: AppToastType.error);
  }

  static void info(BuildContext context, Object message) {
    _show(context, message, type: AppToastType.info);
  }
}