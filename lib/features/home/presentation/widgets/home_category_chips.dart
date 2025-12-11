import 'package:flutter/material.dart';

class HomeCategoryChips extends StatelessWidget {
  /// Category names only (e.g. ["All", "Sports", "Music"])
  final List<String> categories;

  /// Called when a chip is tapped, passes back the selected category name.
  final ValueChanged<String> onCategoryTap;

  const HomeCategoryChips({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.colorScheme;

    // You can track selected chip outside (like you already do with _selectedCategoryId),
    // or add local selection here if needed.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((name) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(name),
              selected: false, // you can wire this with state if needed
              onSelected: (_) => onCategoryTap(name),
              labelStyle: theme.textTheme.bodyMedium,
              selectedColor: c.primary.withOpacity(0.1),
            ),
          );
        }).toList(),
      ),
    );
  }
}
