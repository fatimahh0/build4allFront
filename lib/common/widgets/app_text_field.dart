import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/theme_cubit.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  // ✅ NEW (already in your code)
  final int maxLines;
  final int? minLines;
  final TextInputAction? textInputAction;

  // ✅ ADDED
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.maxLines = 1,
    this.minLines,
    this.textInputAction,

    // ✅ added
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.onChanged,
    this.onFieldSubmitted,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final colors = themeState.tokens.colors;
    final card = themeState.tokens.card;
    final t = Theme.of(context).textTheme;

    final canToggleObscure = widget.obscureText && widget.maxLines == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: t.bodyMedium?.copyWith(color: colors.label)),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode, // ✅ here
          autofocus: widget.autofocus, // ✅ optional
          enabled: widget.enabled, // ✅ optional

          keyboardType: widget.keyboardType,
          obscureText: canToggleObscure ? _obscure : false,
          validator: widget.validator,

          maxLines: widget.maxLines,
          minLines: widget.minLines,
          textInputAction: widget.textInputAction,

          onChanged: widget.onChanged, // ✅ optional
          onFieldSubmitted: widget.onFieldSubmitted, // ✅ optional

          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: colors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(card.radius),
              borderSide: BorderSide(color: colors.border.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(card.radius),
              borderSide: BorderSide(color: colors.border.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(card.radius),
              borderSide: BorderSide(color: colors.primary, width: 1.4),
            ),
            suffixIcon: canToggleObscure
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: colors.body.withOpacity(0.8),
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
