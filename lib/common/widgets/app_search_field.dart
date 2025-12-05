// lib/common/widgets/app_search_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';

class AppSearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;

  const AppSearchField({
    super.key,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    // Read search & spacing tokens
    final themeState = context.read<ThemeCubit>().state;
    final searchTokens = themeState.tokens.search;
    final spacing = themeState.tokens.spacing;

    // Dense = slightly smaller vertical padding
    final verticalPadding = searchTokens.dense ? spacing.xs : spacing.sm;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: t.bodyMedium,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: c.surface,
        contentPadding: EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: spacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(searchTokens.radius),
          borderSide: BorderSide(
            color: c.outline.withOpacity(0.2),
            width: searchTokens.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(searchTokens.radius),
          borderSide: BorderSide(
            color: c.outline.withOpacity(0.2),
            width: searchTokens.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(searchTokens.radius),
          borderSide: BorderSide(
            color: c.primary,
            width: searchTokens.borderWidth + 0.3,
          ),
        ),
      ),
    );
  }
}
