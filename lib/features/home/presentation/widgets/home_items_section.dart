import 'package:build4front/common/widgets/ItemCard.dart';
import 'package:flutter/material.dart';

import 'package:build4front/features/items/domain/entities/item_summary.dart';

import 'home_section_header.dart';

class HomeItemsSection extends StatelessWidget {
  final String title;
  final String layout; // "horizontal" / "vertical"
  final List<ItemSummary> items;

  const HomeItemsSection({
    super.key,
    required this.title,
    required this.layout,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isHorizontal = layout.toLowerCase() == 'horizontal';

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(title: title, icon: Icons.local_activity_outlined),
          const SizedBox(height: 8),
          SizedBox(
            height: isHorizontal ? 190 : null,
            child: isHorizontal
                ? ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ItemCard(
                        title: item.title,
                        subtitle: item.location,
                        imageUrl: item.imageUrl,
                        badgeLabel: item.price != null
                            ? '${item.price} \$'
                            : null,
                        metaLabel: _buildMetaLabel(item),
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
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ItemCard(
                              title: item.title,
                              subtitle: item.location,
                              imageUrl: item.imageUrl,
                              badgeLabel: item.price != null
                                  ? '${item.price} \$'
                                  : null,
                              metaLabel: _buildMetaLabel(item),
                              onTap: () {
                                // TODO: navigate to item details
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

  String? _buildMetaLabel(ItemSummary item) {
    if (item.start != null) {
      // later: use intl + l10n
      return item.start!.toLocal().toString().substring(0, 16);
    }
    return null;
  }
}
