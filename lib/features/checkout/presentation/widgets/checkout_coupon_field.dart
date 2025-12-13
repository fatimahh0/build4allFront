import 'package:flutter/material.dart';
import 'package:build4front/l10n/app_localizations.dart';
import 'package:build4front/common/widgets/app_text_field.dart';

class CheckoutCouponField extends StatefulWidget {
  final String initial;
  final ValueChanged<String> onChanged;

  const CheckoutCouponField({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<CheckoutCouponField> createState() => _CheckoutCouponFieldState();
}

class _CheckoutCouponFieldState extends State<CheckoutCouponField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);

    // ✅ THIS is what was missing: notify parent/bloc when user types
    _ctrl.addListener(() {
      widget.onChanged(_ctrl.text);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppTextField(
      label: l10n.checkoutCouponLabel,
      controller: _ctrl,
      hintText: l10n.checkoutCouponHint,
      textInputAction: TextInputAction.done,
    );
  }
}
