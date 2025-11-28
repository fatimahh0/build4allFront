// lib/features/home/presentation/widgets/home_category_chips.dart

import 'package:flutter/material.dart';

class HomeCategoryChips extends StatelessWidget {
  final List<String> categories;

  const HomeCategoryChips({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == 0; // later bind to state
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? c.primary : c.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? c.primary : c.outline.withOpacity(0.3),
              ),
            ),
            child: Text(
              categories[index],
              style: t.bodyMedium?.copyWith(
                color: isSelected ? c.onPrimary : c.onSurface,
              ),
            ),
          );
        },
      ),
    );
  }
}
