import 'package:build4front/features/checkout/domain/entities/checkout_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';


class CheckoutOrderSummary extends StatelessWidget {
  final CheckoutCart cart;
  final ShippingQuote? selectedShipping;
  final TaxPreview? tax;

  const CheckoutOrderSummary({
    super.key,
    required this.cart,
    required this.selectedShipping,
    required this.tax,
  });

  double get _itemsSubtotal =>
      cart.items.fold(0.0, (sum, i) => sum + i.lineTotal);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final spacing = tokens.spacing;
    final colors = tokens.colors;
    final t = Theme.of(context).textTheme;

    final shipping = selectedShipping?.price ?? 0.0;
    final taxTotal = tax?.totalTax ?? 0.0;
    final total = _itemsSubtotal + shipping + taxTotal;

    Widget row(String label, String value, {bool bold = false}) {
      return Padding(
        padding: EdgeInsets.only(bottom: spacing.xs),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: t.bodyMedium?.copyWith(color: colors.body)),
            Text(
              value,
              style: t.bodyMedium?.copyWith(
                color: colors.label,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        row(
          l10n.checkoutSubtotal,
          '${cart.currencySymbol ?? ''}${_itemsSubtotal.toStringAsFixed(2)}',
        ),
        row(
          l10n.checkoutShipping,
          '${cart.currencySymbol ?? ''}${shipping.toStringAsFixed(2)}',
        ),
        row(
          l10n.checkoutTax,
          '${cart.currencySymbol ?? ''}${taxTotal.toStringAsFixed(2)}',
        ),
        SizedBox(height: spacing.sm),
        Divider(color: colors.border.withOpacity(0.2)),
        SizedBox(height: spacing.sm),
        row(
          l10n.checkoutTotal,
          '${cart.currencySymbol ?? ''}${total.toStringAsFixed(2)}',
          bold: true,
        ),
      ],
    );
  }
}
