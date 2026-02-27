import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/theme_cubit.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;

  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  // Lines + action
  final int maxLines;
  final int? minLines;
  final TextInputAction? textInputAction;

  // Focus + behavior
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;

  // Validation control (✅ NEW FIX)
  // If null => inherits Form.autovalidateMode (recommended).
  final AutovalidateMode? autovalidateMode;

  // Callbacks
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onEditingComplete;
  final FormFieldSetter<String>? onSaved;

  // Extra common options (optional but handy)
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final int? maxLength;

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

    // focus/behavior
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,

    // ✅ validation control
    this.autovalidateMode,

    // callbacks
    this.onChanged,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.onSaved,

    // extras
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
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
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If parent changes obscureText flag dynamically, sync state once
    if (oldWidget.obscureText != widget.obscureText) {
      _obscure = widget.obscureText;
    }
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

          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          readOnly: widget.readOnly,

          keyboardType: widget.keyboardType,
          obscureText: canToggleObscure ? _obscure : false,
          validator: widget.validator,
          onSaved: widget.onSaved,

          // ✅ THIS is the fix lever
          // null => inherit Form.autovalidateMode
          autovalidateMode: widget.autovalidateMode,

          maxLines: widget.maxLines,
          minLines: widget.minLines,
          textInputAction: widget.textInputAction,

          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          onEditingComplete: widget.onEditingComplete,

          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          maxLength: widget.maxLength,

          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: colors.surface,
            counterText: '', // cleaner when maxLength is used
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