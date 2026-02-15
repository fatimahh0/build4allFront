import 'package:build4front/core/network/globals.dart' as net;
import 'package:build4front/features/cart/domain/entities/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/features/catalog/cubit/money.dart';

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

    final resolvedImage = (item.imageUrl ?? '').trim().isNotEmpty
        ? net.resolveUrl(item.imageUrl!.trim())
        : null;

    final bool disabled = item.disabled == true;
    final String? reason =
        (item.blockingReason ?? '').trim().isEmpty ? null : item.blockingReason;

    return Opacity(
      opacity: disabled ? 0.75 : 1,
      child: Container(
        margin: EdgeInsets.only(bottom: spacing.md),
        padding: EdgeInsets.all(spacing.md),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: disabled
                ? c.error.withOpacity(0.25)
                : c.outline.withOpacity(0.12),
          ),
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
                    ? Image.network(
                        resolvedImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: c.surfaceVariant,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: c.onSurface.withOpacity(0.4),
                          ),
                        ),
                      )
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

            // Text + prices + reason
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (item.itemName).trim(),
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    money(context, item.unitPrice),
                    style: t.bodyMedium?.copyWith(
                      color:
                          disabled ? c.onSurface.withOpacity(0.6) : c.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    money(context, item.lineTotal),
                    style: t.bodySmall?.copyWith(
                      color: c.onSurface.withOpacity(0.7),
                    ),
                  ),
                  if (reason != null) ...[
                    SizedBox(height: spacing.sm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 16, color: c.error),
                        SizedBox(width: spacing.xs),
                        Expanded(
                          child: Text(
                            reason!,
                            style: t.bodySmall?.copyWith(color: c.error),
                          ),
                        ),
                      ],
                    ),
                  ],
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
                  disabled: disabled,
                  maxAllowedQuantity: item.maxAllowedQuantity,
                  onChanged: onQuantityChanged,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final bool disabled;
  final int? maxAllowedQuantity;
  final ValueChanged<int> onChanged;

  const _QuantitySelector({
    required this.quantity,
    required this.onChanged,
    required this.disabled,
    required this.maxAllowedQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;

    final canDec = !disabled && quantity > 1;
    final canInc = !disabled &&
        (maxAllowedQuantity == null || quantity < maxAllowedQuantity!);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.xs,
        vertical: spacing.xs / 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: disabled
              ? c.outline.withOpacity(0.2)
              : c.outline.withOpacity(0.4),
        ),
        color: disabled ? c.surfaceVariant.withOpacity(0.35) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(
            icon: Icons.remove_rounded,
            enabled: canDec,
            onTap: () => onChanged(quantity - 1),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.xs),
            child: Text(
              '$quantity',
              style: t.bodyMedium?.copyWith(
                color: disabled ? c.onSurface.withOpacity(0.5) : null,
              ),
            ),
          ),
          _QtyButton(
            icon: Icons.add_rounded,
            enabled: canInc,
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
  final bool enabled;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? c.onSurface.withOpacity(0.9)
              : c.onSurface.withOpacity(0.25),
        ),
      ),
    );
  }
}
