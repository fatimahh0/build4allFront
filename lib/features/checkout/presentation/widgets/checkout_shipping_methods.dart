import 'package:build4front/features/checkout/models/entities/checkout_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';


class CheckoutShippingMethods extends StatelessWidget {
  final List<ShippingQuote> quotes;
  final int? selectedMethodId;
  final ValueChanged<int?> onSelect;
  final VoidCallback onRefresh;

  const CheckoutShippingMethods({
    super.key,
    required this.quotes,
    required this.selectedMethodId,
    required this.onSelect,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final spacing = tokens.spacing;
    final colors = tokens.colors;
    final t = Theme.of(context).textTheme;

    if (quotes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.checkoutNoShippingMethods,
            style: t.bodyMedium?.copyWith(color: colors.muted),
          ),
          SizedBox(height: spacing.sm),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.checkoutRefreshShipping),
          ),
        ],
      );
    }

    return Column(
      children: [
        ...quotes.map((q) {
          final id = q.methodId; // can be null depending on backend
          final selected = id != null && id == selectedMethodId;

          return Container(
            margin: EdgeInsets.only(bottom: spacing.xs),
            child: RadioListTile<int?>(
              value: id,
              groupValue: selectedMethodId,
              onChanged: onSelect,
              title: Text(q.methodName),
              subtitle: Text(
                '${q.currencySymbol ?? ''}${q.price.toStringAsFixed(2)}',
                style: t.bodySmall?.copyWith(color: colors.body),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.trailing,
              selected: selected,
            ),
          );
        }).toList(),
        SizedBox(height: spacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onRefresh,
            icon: Icon(Icons.refresh_rounded, color: colors.primary),
            label: Text(
              l10n.checkoutRefreshShipping,
              style: TextStyle(color: colors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
