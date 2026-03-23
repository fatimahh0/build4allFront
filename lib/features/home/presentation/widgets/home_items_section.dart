import 'package:build4front/features/catalog/cubit/money.dart';
import 'package:build4front/features/itemsDetails/presentation/screens/item_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/features/items/domain/entities/item_summary.dart';
import 'package:build4front/common/widgets/ItemCard.dart';
import 'home_section_header.dart';

import 'package:build4front/features/auth/presentation/login/bloc/auth_bloc.dart';
import 'package:build4front/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:build4front/features/cart/presentation/bloc/cart_event.dart';
import 'package:build4front/l10n/app_localizations.dart';
import 'package:build4front/common/widgets/app_toast.dart';

class HomeItemsSection extends StatelessWidget {
  final String title;
  final String layout;
  final List<ItemSummary> items;

  final IconData icon;
  final String? trailingText;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;

  final bool forceTwoColumns;

  const HomeItemsSection({
    super.key,
    required this.title,
    required this.layout,
    required this.items,
    this.icon = Icons.local_activity_outlined,
    this.trailingText,
    this.trailingIcon,
    this.onTrailingTap,
    this.forceTwoColumns = false,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;
    final isHorizontal =
        !forceTwoColumns && layout.toLowerCase() == 'horizontal';

    if (items.isEmpty) return const SizedBox.shrink();

    final hasProducts = items.any((e) => e.kind == ItemKind.product);

    return Container(
      margin: EdgeInsets.only(bottom: spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(
            title: title,
            icon: icon,
            trailingText: trailingText,
            trailingIcon: trailingIcon,
            onTrailingTap: onTrailingTap,
          ),
          SizedBox(height: spacing.sm),

          if (isHorizontal)
            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final double cardWidth =
                    (maxWidth * 0.56).clamp(175.0, 235.0);
                final double cardHeight =
                    hasProducts ? cardWidth * 1.78 : cardWidth * 1.56;

                return SizedBox(
                  height: cardHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => SizedBox(width: spacing.md),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final pricing = _pricingFor(context, item);

                      return SizedBox(
                        width: cardWidth,
                        child: ItemCard(
                          itemId: item.id,
                          title: item.title,
                          subtitle: _subtitleFor(item),
                          imageUrl: item.imageUrl,
                          imageFit: item.kind == ItemKind.product
                              ? BoxFit.contain
                              : BoxFit.cover,
                          badgeLabel: pricing.currentLabel,
                          oldPriceLabel: pricing.oldLabel,
                          tagLabel: pricing.tagLabel,
                          metaLabel: _metaLabelFor(context, item),
                          ctaLabel: _ctaLabelFor(context, item),
                          onTap: () => _openDetails(context, item.id),
                          onCtaPressed: () => _handleCtaPressed(context, item),
                        ),
                      );
                    },
                  ),
                );
              },
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;

                final cols =
                    forceTwoColumns ? 2 : (w < 520 ? 2 : (w < 900 ? 3 : 4));

                final double aspect;
                if (hasProducts) {
                  aspect = forceTwoColumns
                      ? (w < 520 ? 0.55 : 0.62)
                      : (w < 520 ? 0.58 : (w < 900 ? 0.64 : 0.72));
                } else {
                  aspect = forceTwoColumns
                      ? (w < 520 ? 0.72 : 0.80)
                      : (w < 520 ? 0.74 : (w < 900 ? 0.80 : 0.86));
                }

                final cardW = (w - ((cols - 1) * spacing.md)) / cols;
                final cardH = cardW / aspect;

                Widget card(ItemSummary item) {
                  final pricing = _pricingFor(context, item);

                  return SizedBox(
                    width: double.infinity,
                    child: ItemCard(
                      itemId: item.id,
                      title: item.title,
                      subtitle: _subtitleFor(item),
                      imageUrl: item.imageUrl,
                      imageFit: item.kind == ItemKind.product
                          ? BoxFit.contain
                          : BoxFit.cover,
                      badgeLabel: pricing.currentLabel,
                      oldPriceLabel: pricing.oldLabel,
                      tagLabel: pricing.tagLabel,
                      metaLabel: _metaLabelFor(context, item),
                      ctaLabel: _ctaLabelFor(context, item),
                      onTap: () => _openDetails(context, item.id),
                      onCtaPressed: () => _handleCtaPressed(context, item),
                    ),
                  );
                }

                if (forceTwoColumns && items.length == 1) {
                  return Center(
                    child: SizedBox(
                      width: cardW,
                      height: cardH,
                      child: card(items.first),
                    ),
                  );
                }

                if (forceTwoColumns && items.length == 2) {
                  return Row(
                    children: [
                      Expanded(
                        child: SizedBox(height: cardH, child: card(items[0])),
                      ),
                      SizedBox(width: spacing.md),
                      Expanded(
                        child: SizedBox(height: cardH, child: card(items[1])),
                      ),
                    ],
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: spacing.md,
                    crossAxisSpacing: spacing.md,
                    childAspectRatio: aspect,
                  ),
                  itemBuilder: (context, index) => card(items[index]),
                );
              },
            ),
        ],
      ),
    );
  }

  void _openDetails(BuildContext context, int itemId) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ItemDetailsPage(itemId: itemId)));
  }

  bool _isSaleActiveNow(ItemSummary item) {
    final now = DateTime.now();
    final start = item.saleStart;
    final end = item.saleEnd;

    if (start == null && end == null) return item.onSale;
    if (start != null && end == null) return !now.isBefore(start);
    if (start == null && end != null) return !now.isAfter(end);
    return !now.isBefore(start!) && !now.isAfter(end!);
  }

  _PricingView _pricingFor(BuildContext context, ItemSummary item) {
    final l10n = AppLocalizations.of(context)!;

    final saleActive = item.onSale && _isSaleActiveNow(item);

    final double? basePrice = item.price?.toDouble();
    final double? current = saleActive
        ? (item.effectivePrice ?? item.salePrice ?? item.price)?.toDouble()
        : basePrice;

    final currentLabel = current == null ? null : money(context, current);

    String? oldLabel;
    if (saleActive &&
        basePrice != null &&
        current != null &&
        basePrice > current) {
      oldLabel = money(context, basePrice);
    }

    String? tagLabel;
    if (saleActive && basePrice != null && current != null && basePrice > 0) {
      final percent = ((1 - (current / basePrice)) * 100).round();
      tagLabel = percent > 0 ? '-$percent%' : l10n.adminProductSalePriceLabel;
    }

    return _PricingView(
      currentLabel: currentLabel,
      oldLabel: oldLabel,
      tagLabel: tagLabel,
    );
  }

  String _ctaLabelFor(BuildContext context, ItemSummary item) {
    final l10n = AppLocalizations.of(context)!;

    switch (item.kind) {
      case ItemKind.product:
        return l10n.cart_add_button;
      case ItemKind.activity:
        return l10n.home_book_now_button;
      default:
        return l10n.home_view_details_button;
    }
  }

  String? _subtitleFor(ItemSummary item) {
    switch (item.kind) {
      case ItemKind.activity:
        return item.location;
      case ItemKind.product:
        return item.subtitle;
      default:
        return item.subtitle ?? item.location;
    }
  }

  String? _metaLabelFor(BuildContext context, ItemSummary item) {
    final l10n = AppLocalizations.of(context)!;

    switch (item.kind) {
      case ItemKind.activity:
        if (item.start == null) return null;
        final dt = item.start!.toLocal();
        final y = dt.year.toString().padLeft(4, '0');
        final m = dt.month.toString().padLeft(2, '0');
        final d = dt.day.toString().padLeft(2, '0');
        final hh = dt.hour.toString().padLeft(2, '0');
        final mm = dt.minute.toString().padLeft(2, '0');
        return '$d/$m/$y  $hh:$mm';

      case ItemKind.product:
        if (item.stock == null) return null;
        return l10n.common_stock_label(item.stock!);

      default:
        return null;
    }
  }

  void _handleCtaPressed(BuildContext context, ItemSummary item) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.read<AuthBloc>().state;

    if (!auth.isLoggedIn) {
      AppToast.error(context, l10n.cart_login_required_message);
      return;
    }

    if (item.kind == ItemKind.product) {
      context.read<CartBloc>().add(
            CartAddItemRequested(itemId: item.id, quantity: 1),
          );
      AppToast.success(context, l10n.cart_item_added_snackbar);
      return;
    }

    _openDetails(context, item.id);
  }
}

class _PricingView {
  final String? currentLabel;
  final String? oldLabel;
  final String? tagLabel;

  const _PricingView({
    required this.currentLabel,
    required this.oldLabel,
    required this.tagLabel,
  });
}