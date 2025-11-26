import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/theme_cubit.dart'; // adjust path if needed

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final colors = themeState.tokens.colors;
    final button = themeState.tokens.button;
    final textTheme = Theme.of(context).textTheme;

    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onPrimary,
              fontSize: button.textSize,
              fontWeight: FontWeight.w600,
            ),
          );

    return SizedBox(
      width: button.fullWidth ? double.infinity : null,
      height: button.height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(button.radius),
          ),
        ),
        child: child,
      ),
    );
  }
}
