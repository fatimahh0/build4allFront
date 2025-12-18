import 'package:flutter/material.dart';

class HomeCategoryChips extends StatelessWidget {
  /// Category names only (e.g. ["All", "Sports", "Music"])
  final List<String> categories;

  /// The currently selected category label (must match one of [categories])
  /// Example: "All" OR "Sports"
  final String? selectedCategory;

  /// Called when a chip is tapped, passes back the selected category name.
  final ValueChanged<String> onCategoryTap;

  const HomeCategoryChips({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.colorScheme;

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final name = categories[index];
          final isSelected = (selectedCategory ?? '') == name;

          return ChoiceChip(
            label: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onCategoryTap(name),
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? c.onPrimary : c.onSurface,
            ),
            backgroundColor: c.surface,
            selectedColor: c.primary,
            side: BorderSide(
              color: isSelected ? c.primary : c.outline.withOpacity(0.35),
            ),
            shape: const StadiumBorder(),
          );
        },
      ),
    );
  }
}
