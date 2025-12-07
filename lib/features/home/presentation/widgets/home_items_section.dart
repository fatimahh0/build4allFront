import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/features/items/domain/entities/item_summary.dart';
import 'package:build4front/common/widgets/ItemCard.dart';
import 'home_section_header.dart';

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
          SizedBox(
            height: isHorizontal ? 210 : null,
            child: isHorizontal
                ? ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => SizedBox(width: spacing.md),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ItemCard(
                        title: item.title,
                        subtitle: _subtitleFor(item),
                        imageUrl: item.imageUrl,
                        badgeLabel: item.price != null
                            ? '${item.price} \$'
                            : null,
                        metaLabel: _metaLabelFor(item),
                        onTap: () {
                          // TODO: navigate to item details
                        },
                      );
                    },
                  )
                : Column(
                    children: items
                        .map(
                          (item) => Padding(
                            padding: EdgeInsets.only(bottom: spacing.sm),
                            child: ItemCard(
                              title: item.title,
                              subtitle: _subtitleFor(item),
                              imageUrl: item.imageUrl,
                              badgeLabel: item.price != null
                                  ? '${item.price} \$'
                                  : null,
                              metaLabel: _metaLabelFor(item),
                              onTap: () {
                                // TODO: navigate to item details
                              },
                              ctaLabel: item.kind == ItemKind.product
                                  ? 'Add to cart'
                                  : 'Book now',
                              onCtaPressed: () {
                                // TODO: بعدين نربطها مع الـ CartBloc / booking
                                debugPrint(
                                  'CTA pressed for item ${item.id} (${item.kind})',
                                );
                              },
                              
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  /// Subtitle:
  /// - Activities: location
  /// - Products:  short description (subtitle)
  /// - Fallback:  description/location if available
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

  /// Meta label:
  /// - Activities: date/time
  /// - Products:  nothing (for now)
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
}
