// lib/features/cart/presentation/widgets/cart_item_tile.dart
import 'package:build4front/core/network/globals.dart' as net;
import 'package:build4front/features/cart/domain/entities/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';


class CartItemTile extends StatelessWidget {
  final CartItem item;
  final String? currencySymbol;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChanged;

  const CartItemTile({
    super.key,
    required this.item,
    required this.currencySymbol,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themeState = context.read<ThemeCubit>().state;
    final spacing = themeState.tokens.spacing;
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final resolvedImage = item.imageUrl != null && item.imageUrl!.isNotEmpty
        ? net.resolveUrl(item.imageUrl!)
        : null;

    return Container(
      margin: EdgeInsets.only(bottom: spacing.md),
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.outline.withOpacity(0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72,
              height: 72,
              child: resolvedImage != null
                  ? Image.network(resolvedImage, fit: BoxFit.cover)
                  : Container(
                      color: c.surfaceVariant,
                      child: Icon(
                        Icons.image_outlined,
                        color: c.onSurface.withOpacity(0.4),
                      ),
                    ),
            ),
          ),
          SizedBox(width: spacing.md),

          // Text + quantity
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing.xs),
                Text(
                  _formatPrice(item.unitPrice, currencySymbol),
                  style: t.bodyMedium?.copyWith(
                    color: c.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  _formatLineTotal(item.lineTotal, currencySymbol),
                  style: t.bodySmall?.copyWith(
                    color: c.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: spacing.sm),

          // Quantity controls + delete
          Column(
            children: [
              IconButton(
                iconSize: 20,
                icon: const Icon(Icons.close_rounded),
                onPressed: onRemove,
              ),
              SizedBox(height: spacing.sm),
              _QuantitySelector(
                quantity: item.quantity,
                onChanged: onQuantityChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price, String? symbol) {
    final currency = symbol ?? '\$';
    return '$currency ${price.toStringAsFixed(2)}';
  }

  String _formatLineTotal(double total, String? symbol) {
    final currency = symbol ?? '\$';
    return '$currency ${total.toStringAsFixed(2)} total';
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _QuantitySelector({required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.xs,
        vertical: spacing.xs / 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.outline.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(
            icon: Icons.remove_rounded,
            onTap: () {
              if (quantity > 1) onChanged(quantity - 1);
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.xs),
            child: Text('$quantity', style: t.bodyMedium),
          ),
          _QtyButton(
            icon: Icons.add_rounded,
            onTap: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 18, color: c.onSurface.withOpacity(0.9)),
      ),
    );
  }
}
