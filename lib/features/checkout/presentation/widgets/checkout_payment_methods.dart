import 'package:build4front/features/checkout/models/entities/checkout_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';



class CheckoutPaymentMethods extends StatelessWidget {
  final List<PaymentMethod> methods;
  final String? selectedCode;
  final ValueChanged<String> onSelect;

  const CheckoutPaymentMethods({
    super.key,
    required this.methods,
    required this.selectedCode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final spacing = tokens.spacing;
    final colors = tokens.colors;

    final list = methods.isEmpty
        ? [PaymentMethod(code: 'CASH', name: l10n.checkoutPaymentCash)]
        : methods;

    return Column(
      children: [
        ...list.map((m) {
          final selected = (m.code == selectedCode);

          return Container(
            margin: EdgeInsets.only(bottom: spacing.xs),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? colors.primary.withOpacity(0.55)
                    : colors.border.withOpacity(0.2),
              ),
            ),
            child: ListTile(
              onTap: () => onSelect(m.code),
              leading: Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? colors.primary : colors.muted,
              ),
              title: Text(m.name),
              subtitle: Text(m.code.toUpperCase()),
            ),
          );
        }).toList(),
        SizedBox(height: spacing.sm),
        Text(
          l10n.checkoutStripeNote,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.muted),
        ),
      ],
    );
  }
}
