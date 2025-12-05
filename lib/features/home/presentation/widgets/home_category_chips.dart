// lib/features/home/presentation/widgets/home_category_chips.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';

class HomeCategoryChips extends StatelessWidget {
  final List<String> categories;

  const HomeCategoryChips({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final themeState = context.read<ThemeCubit>().state;
    final spacing = themeState.tokens.spacing;

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: spacing.lg),
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: spacing.sm),
        itemBuilder: (context, index) {
          final isSelected = index == 0; // later bind to state
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected ? c.primary : c.surface,
              borderRadius: BorderRadius.circular(spacing.lg + spacing.sm),
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
