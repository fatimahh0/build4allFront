import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  /// Optional trailing label on the right (e.g. "Limited time", "See all").
  final String? trailingText;

  /// Optional trailing icon on the right (e.g. chevron).
  final IconData? trailingIcon;

  /// Optional tap callback for the trailing area.
  final VoidCallback? onTrailingTap;

  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.trailingText,
    this.trailingIcon,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    final themeState = context.read<ThemeCubit>().state;
    final spacing = themeState.tokens.spacing;

    final hasTrailing = trailingText != null || trailingIcon != null;

    Widget? trailing;
    if (hasTrailing) {
      final textStyle = t.bodySmall?.copyWith(
        color: c.onSurface.withOpacity(0.85),
        fontWeight: trailingText == 'Limited time'
            ? FontWeight.w500
            : FontWeight.w600,
      );

      trailing = InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTrailingTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null) Text(trailingText!, style: textStyle),
            if (trailingIcon != null) ...[
              SizedBox(width: spacing.xs),
              Icon(trailingIcon, size: 16, color: c.onSurface.withOpacity(0.8)),
            ],
          ],
        ),
      );
    }

    return Row(
      children: [
        Icon(icon, size: 20),
        SizedBox(width: spacing.sm),
        Expanded(child: Text(title, style: t.titleMedium)),
        if (trailing != null) trailing,
      ],
    );
  }
}
