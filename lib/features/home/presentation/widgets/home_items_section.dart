// lib/features/home/presentation/widgets/home_items_section.dart
import 'package:build4front/features/cart/presentation/bloc/cart_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/features/items/domain/entities/item_summary.dart';
import 'package:build4front/common/widgets/ItemCard.dart';
import 'home_section_header.dart';

// 🔥 Auth + Cart + l10n
import 'package:build4front/features/auth/presentation/login/bloc/auth_bloc.dart';
import 'package:build4front/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:build4front/l10n/app_localizations.dart';

class HomeItemsSection extends StatelessWidget {
  final String title;
  final String layout; // "horizontal" / "vertical"
  final List<ItemSummary> items;

  /// Icon used in the section header (different per section)
  final IconData icon;

  /// Optional trailing label / icon in the header.
  final String? trailingText;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;

  const HomeItemsSection({
    super.key,
    required this.title,
    required this.layout,
    required this.items,
    this.icon = Icons.local_activity_outlined,
    this.trailingText,
    this.trailingIcon,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    final isHorizontal = layout.toLowerCase() == 'horizontal';

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final themeState = context.read<ThemeCubit>().state;
    final spacing = themeState.tokens.spacing;

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

          // ====================
          //   HORIZONTAL LIST
          // ====================
          if (isHorizontal)
            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;

                // Card width ~55% of the section width, clamped for phones/tablets
                double cardWidth = maxWidth * 0.55;
                cardWidth = cardWidth.clamp(170.0, 230.0);

                // Enough height → no overflow
                final double cardHeight = cardWidth * 1.6;

                return SizedBox(
                  height: cardHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => SizedBox(width: spacing.md),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return SizedBox(
                        width: cardWidth,
                        child: ItemCard(
                          title: item.title,
                          subtitle: _subtitleFor(item),
                          imageUrl: item.imageUrl,
                          badgeLabel: item.price != null
                              ? '${item.price} \$'
                              : null,
                          metaLabel: _metaLabelFor(item),
                          ctaLabel: _ctaLabelFor(context, item),
                          onTap: () {
                            // TODO: navigate to item details
                          },
                          onCtaPressed: () {
                            _handleCtaPressed(context, item);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            )
          // ====================
          //   VERTICAL GRID (2 per row)
          // ====================
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final itemWidth = (maxWidth - spacing.md) / 2;

                return Wrap(
                  spacing: spacing.md,
                  runSpacing: spacing.md,
                  children: items.map((item) {
                    return SizedBox(
                      width: itemWidth,
                      child: ItemCard(
                        title: item.title,
                        subtitle: _subtitleFor(item),
                        imageUrl: item.imageUrl,
                        badgeLabel: item.price != null
                            ? '${item.price} \$'
                            : null,
                        metaLabel: _metaLabelFor(item),
                        ctaLabel: _ctaLabelFor(context, item),
                        onTap: () {
                          // TODO: navigate to item details
                        },
                        onCtaPressed: () {
                          _handleCtaPressed(context, item);
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  /// CTA label:
  /// - Products → Add to cart
  /// - Activities → Book now
  /// - Others   → View details
  String _ctaLabelFor(BuildContext context, ItemSummary item) {
    final l10n = AppLocalizations.of(context)!;

    switch (item.kind) {
      case ItemKind.product:
        // TODO: create a proper key in l10n
        return l10n
            .cart_add_button; // or just 'Add to cart' if key not yet created
      case ItemKind.activity:
        return l10n.home_book_now_button; // or a literal 'Book now'
      case ItemKind.service:
      case ItemKind.unknown:
      default:
        return l10n.home_view_details_button; // or 'View details'
    }
  }

  /// Subtitle:
  /// - Activities: location
  /// - Products:  short description
  /// - Fallback:  subtitle or location
  String? _subtitleFor(ItemSummary item) {
    switch (item.kind) {
      case ItemKind.activity:
        return item.location;
      case ItemKind.product:
        return item.subtitle;
      case ItemKind.service:
      case ItemKind.unknown:
      default:
        return item.subtitle ?? item.location;
    }
  }

  /// Meta label only for activities (date/time).
  String? _metaLabelFor(ItemSummary item) {
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
        return null;
      case ItemKind.service:
      case ItemKind.unknown:
      default:
        return null;
    }
  }

  /// 🔥 Handle "Add to cart" / "Book now" logic
  void _handleCtaPressed(BuildContext context, ItemSummary item) {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.read<AuthBloc>().state;

    // 1) Not logged in → show dialog
    if (!authState.isLoggedIn) {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(l10n.cart_login_required_title),
            content: Text(l10n.cart_login_required_message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.cancel_button),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  // TODO: navigate to your login route if you want
                  // Navigator.of(context).pushNamed('/login');
                },
                child: Text(l10n.login_button),
              ),
            ],
          );
        },
      );
      return;
    }

    // 2) If item is a PRODUCT → add to cart via CartBloc
    if (item.kind == ItemKind.product) {
      // This event name assumes your CartBloc has something like this.
      // If your events differ, just adapt:
      context.read<CartBloc>().add(
        CartAddItemRequested(itemId: item.id, quantity: 1),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cart_item_added_snackbar),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // 3) If item is an ACTIVITY → here you can later open booking flow
    if (item.kind == ItemKind.activity) {
      // Navigator.of(context).pushNamed('/activity-details', arguments: item.id);
      return;
    }

    // 4) Others → maybe open details
    // Navigator.of(context).pushNamed('/item-details', arguments: item.id);
  }
}
