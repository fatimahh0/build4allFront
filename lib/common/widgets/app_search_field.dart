// lib/common/widgets/app_search_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';

class AppSearchField extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Optional external controller.
  /// If provided, we will NOT create our own.
  final TextEditingController? controller;

  /// Optional initial value (used when no external controller provided).
  /// Perfect for ExploreScreen to pre-fill the search.
  final String? initialValue;

  const AppSearchField({
    super.key,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.initialValue,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  TextEditingController? _internalController;

  TextEditingController get _effectiveController {
    // If parent passed a controller → use it.
    if (widget.controller != null) {
      return widget.controller!;
    }

    // Otherwise create our own once, with initialValue.
    _internalController ??= TextEditingController(
      text: widget.initialValue ?? '',
    );
    return _internalController!;
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

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
      controller: _effectiveController,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      style: t.bodyMedium,
      decoration: InputDecoration(
        hintText: widget.hintText,
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
