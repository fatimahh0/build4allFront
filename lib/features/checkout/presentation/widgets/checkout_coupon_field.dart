import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';

class CheckoutCouponField extends StatefulWidget {
  final String draft;
  final String applied;

  final bool? isValid;
  final String? message;

  final ValueChanged<String> onDraftChanged;
  final ValueChanged<String> onApply;

  const CheckoutCouponField({
    super.key,
    required this.draft,
    required this.applied,
    required this.onDraftChanged,
    required this.onApply,
    this.isValid,
    this.message,
  });

  @override
  State<CheckoutCouponField> createState() => _CheckoutCouponFieldState();
}

class _CheckoutCouponFieldState extends State<CheckoutCouponField> {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.draft);
    _focus = FocusNode();
  }

  @override
  void didUpdateWidget(covariant CheckoutCouponField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.draft != widget.draft && _ctrl.text != widget.draft) {
      _ctrl.text = widget.draft;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _applyNow() {
    final v = _ctrl.text.trim();
    widget.onApply(v);
    FocusScope.of(context).unfocus();
  }

  void _clearAndApply() {
    _ctrl.clear();
    widget.onDraftChanged('');
    widget.onApply('');
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final c = tokens.colors;
    final spacing = tokens.spacing;
    final t = tokens.typography;

    final draft = _ctrl.text.trim();
    final applied = widget.applied.trim();
    final isDirty = draft.toUpperCase() != applied.toUpperCase();

    Color msgColor;
    if (widget.isValid == true) {
      msgColor = c.success;
    } else if (widget.isValid == false) {
      msgColor = c.danger;
    } else {
      msgColor = c.muted;
    }

    final cleanMessage = (widget.message ?? '').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.checkoutCouponHint,
                  filled: true,
                  fillColor: c.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.card.radius),
                    borderSide: BorderSide(color: c.border.withOpacity(0.25)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.card.radius),
                    borderSide: BorderSide(color: c.border.withOpacity(0.25)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.card.radius),
                    borderSide: BorderSide(color: c.primary, width: 1.4),
                  ),
                  suffixIcon: draft.isEmpty
                      ? null
                      : IconButton(
                          onPressed: _clearAndApply,
                          icon: Icon(Icons.close_rounded, color: c.muted),
                        ),
                ),
                onChanged: (v) {
                  widget.onDraftChanged(v);
                  setState(() {});
                },
                onSubmitted: (_) => _applyNow(),
              ),
            ),
            SizedBox(width: spacing.sm),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: draft.isEmpty ? null : (isDirty ? _applyNow : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: c.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.check_rounded),
              ),
            ),
          ],
        ),
        if (cleanMessage.isNotEmpty) ...[
          SizedBox(height: spacing.xs),
          Text(
            cleanMessage,
            style: t.bodySmall.copyWith(color: msgColor),
          ),
        ] else if (draft.isNotEmpty && isDirty) ...[
          SizedBox(height: spacing.xs),
          Text(
            'Not applied yet • tap ✓',
            style: t.bodySmall.copyWith(color: c.muted),
          ),
        ],
      ],
    );
  }
}