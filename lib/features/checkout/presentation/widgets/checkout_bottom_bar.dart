import 'package:build4front/features/checkout/models/entities/checkout_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';
import 'package:build4front/common/widgets/primary_button.dart';


class CheckoutBottomBar extends StatelessWidget {
  final CheckoutCart cart;
  final ShippingQuote? selectedShipping;
  final TaxPreview? tax;
  final bool isPlacing;
  final VoidCallback onPlaceOrder;

  const CheckoutBottomBar({
    super.key,
    required this.cart,
    required this.selectedShipping,
    required this.tax,
    required this.isPlacing,
    required this.onPlaceOrder,
  });

  double get _itemsSubtotal =>
      cart.items.fold(0.0, (sum, i) => sum + i.lineTotal);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final spacing = tokens.spacing;
    final colors = tokens.colors;

    final shipping = selectedShipping?.price ?? 0.0;
    final taxTotal = tax?.totalTax ?? 0.0;
    final total = _itemsSubtotal + shipping + taxTotal;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.all(spacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(color: colors.border.withOpacity(0.2)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  l10n.checkoutTotal,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: colors.label),
                ),
                const Spacer(),
                Text(
                  '${cart.currencySymbol ?? ''}${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.label,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.sm),
            PrimaryButton(
              label: l10n.checkoutPlaceOrder,
              onPressed: onPlaceOrder,
              isLoading: isPlacing,
            ),
          ],
        ),
      ),
    );
  }
}
