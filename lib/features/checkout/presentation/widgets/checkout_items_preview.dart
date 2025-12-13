import 'package:build4front/features/checkout/models/entities/checkout_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/core/network/globals.dart' as g;



class CheckoutItemsPreview extends StatelessWidget {
  final CheckoutCart cart;

  const CheckoutItemsPreview({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final spacing = tokens.spacing;
    final colors = tokens.colors;
    final t = Theme.of(context).textTheme;

    return Column(
      children: cart.items.map((it) {
        final img = (it.imageUrl ?? '').trim();
        final resolved = img.isEmpty ? '' : g.resolveUrl(img);

        return Padding(
          padding: EdgeInsets.only(bottom: spacing.sm),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border.withOpacity(0.2)),
                  color: colors.background,
                  image: resolved.isEmpty
                      ? null
                      : DecorationImage(
                          image: NetworkImage(resolved),
                          fit: BoxFit.cover,
                        ),
                ),
                child: resolved.isEmpty
                    ? Icon(
                        Icons.image_not_supported_outlined,
                        color: colors.muted,
                      )
                    : null,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      it.itemName ?? 'Item #${it.itemId}',
                      style: t.bodyMedium?.copyWith(
                        color: colors.label,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      'x${it.quantity} • ${cart.currencySymbol ?? ''}${it.unitPrice.toStringAsFixed(2)}',
                      style: t.bodySmall?.copyWith(color: colors.body),
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              Text(
                '${cart.currencySymbol ?? ''}${it.lineTotal.toStringAsFixed(2)}',
                style: t.bodyMedium?.copyWith(
                  color: colors.label,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
