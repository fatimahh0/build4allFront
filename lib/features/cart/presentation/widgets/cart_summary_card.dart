// lib/features/cart/presentation/widgets/cart_summary_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';

class CartSummaryCard extends StatelessWidget {
  final double totalPrice;
  final String? currencySymbol;
  final bool isUpdating;
  final String checkoutLabel;
  final VoidCallback onCheckout;

  const CartSummaryCard({
    super.key,
    required this.totalPrice,
    required this.currencySymbol,
    required this.isUpdating,
    required this.checkoutLabel,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;

    final currency = currencySymbol ?? '\$';

    return Container(
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.outline.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Total',
                style: t.bodyMedium?.copyWith(
                  color: c.onSurface.withOpacity(0.8),
                ),
              ),
              const Spacer(),
              Text(
                '$currency ${totalPrice.toStringAsFixed(2)}',
                style: t.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: c.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isUpdating ? null : onCheckout,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: isUpdating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      checkoutLabel,
                      style: t.labelLarge?.copyWith(
                        color: c.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
