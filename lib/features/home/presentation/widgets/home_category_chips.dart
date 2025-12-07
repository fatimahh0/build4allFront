import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:build4front/core/theme/theme_cubit.dart';

class HomeCategoryChips extends StatefulWidget {
  final List<String> categories;
  final ValueChanged<String>? onCategoryTap;

  const HomeCategoryChips({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  State<HomeCategoryChips> createState() => _HomeCategoryChipsState();
}

class _HomeCategoryChipsState extends State<HomeCategoryChips> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final themeState = context.watch<ThemeCubit>().state;
    final spacing = themeState.tokens.spacing;
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      margin: EdgeInsets.only(bottom: spacing.lg),
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.categories.length,
        separatorBuilder: (_, __) => SizedBox(width: spacing.sm),
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          final isSelected = _selected == category;

          return ChoiceChip(
            label: Text(
              category,
              style: t.bodySmall?.copyWith(
                color: isSelected ? c.onPrimary : c.onSurface,
              ),
            ),
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                _selected = category;
              });
              widget.onCategoryTap?.call(category);
            },
            selectedColor: c.primary,
            backgroundColor: c.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide(
                color: isSelected ? c.primary : c.outline.withOpacity(0.3),
              ),
            ),
          );
        },
      ),
    );
  }
}
