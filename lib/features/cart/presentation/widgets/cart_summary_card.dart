// lib/features/cart/presentation/widgets/cart_summary_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';

class CartSummaryCard extends StatelessWidget {
  final double itemsTotal;
  final double shippingTotal;
  final double taxTotal;
  final double? discountTotal;
  final double grandTotal;

  final String? currencySymbol;
  final bool isUpdating;
  final String checkoutLabel;
  final VoidCallback onCheckout;

  const CartSummaryCard({
    super.key,
    required this.itemsTotal,
    required this.shippingTotal,
    required this.taxTotal,
    required this.discountTotal,
    required this.grandTotal,
    required this.currencySymbol,
    required this.isUpdating,
    required this.checkoutLabel,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final themeState = context.read<ThemeCubit>().state;
    final spacing = themeState.tokens.spacing;

    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final currency = currencySymbol ?? '\$';

    final hasDiscount = (discountTotal ?? 0) > 0;

    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.outline.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: c.onSurface.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title + secure chip
          Row(
            children: [
              Text(
                'Order summary',
                style: t.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: c.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: c.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded, size: 14, color: c.primary),
                    SizedBox(width: spacing.xs),
                    Text(
                      'Secure checkout',
                      style: t.labelSmall?.copyWith(
                        color: c.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: spacing.md),

          _SummaryRow(
            label: 'Items subtotal',
            value: _format(currency, itemsTotal),
          ),
          SizedBox(height: spacing.xs),

          _SummaryRow(
            label: 'Shipping',
            value: shippingTotal > 0
                ? _format(currency, shippingTotal)
                : 'Free',
            valueColor: shippingTotal > 0 ? c.onSurface : Colors.green.shade700,
          ),
          SizedBox(height: spacing.xs),

          _SummaryRow(label: 'Tax', value: _format(currency, taxTotal)),

          if (hasDiscount) ...[
            SizedBox(height: spacing.xs),
            _SummaryRow(
              label: 'Discount',
              value: '- ${_format(currency, discountTotal ?? 0)}',
              valueColor: Colors.green.shade700,
            ),
          ],

          SizedBox(height: spacing.md),
          Divider(color: c.outline.withOpacity(0.16), height: 1),
          SizedBox(height: spacing.md),

          Row(
            children: [
              Text(
                'Total',
                style: t.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: c.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                _format(currency, grandTotal),
                style: t.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: c.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: spacing.lg),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isUpdating ? null : onCheckout,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: isUpdating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          checkoutLabel,
                          style: t.labelLarge?.copyWith(
                            color: c.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: spacing.sm),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
            ),
          ),

          SizedBox(height: spacing.sm),

          Text(
            'Taxes and shipping are calculated based on your address.',
            textAlign: TextAlign.center,
            style: t.bodySmall?.copyWith(color: c.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  String _format(String currency, double value) {
    return '$currency ${value.toStringAsFixed(2)}';
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;

    return Row(
      children: [
        Text(
          label,
          style: t.bodyMedium?.copyWith(color: c.onSurface.withOpacity(0.7)),
        ),
        SizedBox(width: spacing.xs),
        const Spacer(),
        Text(
          value,
          style: t.bodyMedium?.copyWith(
            color: valueColor ?? c.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
