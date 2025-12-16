import 'package:build4front/features/catalog/cubit/money.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/core/network/globals.dart' as g;
import 'package:build4front/l10n/app_localizations.dart';


import 'package:build4front/features/checkout/domain/entities/checkout_entities.dart';

class CheckoutItemsPreview extends StatelessWidget {
  final CheckoutCart cart;

  const CheckoutItemsPreview({super.key, required this.cart});

  double _effectiveUnitPrice(CheckoutCartItem it) {
    if (it.quantity <= 0) return it.unitPrice;
    return it.lineTotal / it.quantity; // ✅ selling/effective unit price
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final spacing = tokens.spacing;
    final colors = tokens.colors;
    final t = Theme.of(context).textTheme;

    final sym = (cart.currencySymbol ?? '').toString().trim();

    return Column(
      children: cart.items.map((it) {
        final img = (it.imageUrl ?? '').trim();
        final resolved = img.isEmpty ? '' : g.resolveUrl(img);

        final unit = _effectiveUnitPrice(it);

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
                      (it.itemName ?? '').trim().isEmpty
                          ? l10n.itemNumber(it.itemId)
                          : it.itemName!,
                      style: t.bodyMedium?.copyWith(
                        color: colors.label,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      l10n.qtyPriceLine(
                        it.quantity,
                        money(context, unit, symbolFromApi: sym),
                      ),
                      style: t.bodySmall?.copyWith(color: colors.body),
                    ),
                  ],
                ),
              ),

              SizedBox(width: spacing.sm),

              Text(
                money(context, it.lineTotal, symbolFromApi: sym),
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
