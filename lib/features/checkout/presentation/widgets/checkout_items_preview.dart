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

  @override
  Widget build(BuildContext context) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final spacing = tokens.spacing;

    final sym = (cart.currencySymbol ?? '').toString().trim();

    // ✅ IMPORTANT:
    // We avoid calling money(context, ...) directly inside this "map/loop"
    // because money() likely uses context.select(), and that can crash inside
    // SliverList/SliverGrid builds.
    //
    // Instead we render a dedicated widget per row, and money() is called
    // inside that widget’s build method.
    return Column(
      children: List.generate(cart.items.length, (index) {
        final it = cart.items[index];

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == cart.items.length - 1 ? 0 : spacing.sm,
          ),
          child: _CheckoutItemPreviewRow(item: it, currencySymbolFromApi: sym),
        );
      }),
    );
  }
}

class _CheckoutItemPreviewRow extends StatelessWidget {
  final CheckoutCartItem item;
  final String currencySymbolFromApi;

  const _CheckoutItemPreviewRow({
    required this.item,
    required this.currencySymbolFromApi,
  });

  double _effectiveUnitPrice(CheckoutCartItem it) {
    if (it.quantity <= 0) return it.unitPrice;
    return it.lineTotal / it.quantity; // selling/effective unit price
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final spacing = tokens.spacing;
    final colors = tokens.colors;
    final t = Theme.of(context).textTheme;

    final img = (item.imageUrl ?? '').trim();
    final resolved = img.isEmpty ? '' : g.resolveUrl(img);

    final unit = _effectiveUnitPrice(item);

    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border.withOpacity(0.2)),
            color: colors.background,
          ),
          clipBehavior: Clip.antiAlias,
          child: resolved.isEmpty
              ? Icon(Icons.image_not_supported_outlined, color: colors.muted)
              : Image.network(
                  resolved,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.broken_image_outlined, color: colors.muted),
                ),
        ),
        SizedBox(width: spacing.sm),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (item.itemName ?? '').trim().isEmpty
                    ? l10n.itemNumber(item.itemId)
                    : item.itemName!,
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
                  item.quantity,
                  money(context, unit, symbolFromApi: currencySymbolFromApi),
                ),
                style: t.bodySmall?.copyWith(color: colors.body),
              ),
            ],
          ),
        ),

        SizedBox(width: spacing.sm),

        Text(
          money(context, item.lineTotal, symbolFromApi: currencySymbolFromApi),
          style: t.bodyMedium?.copyWith(
            color: colors.label,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
