import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';

class AdminShippingFiltersBar extends StatelessWidget {
  final bool showAll;
  final ValueChanged<bool> onChangedShowAll;

  const AdminShippingFiltersBar({
    super.key,
    required this.showAll,
    required this.onChangedShowAll,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final spacing = tokens.spacing;
    final l = AppLocalizations.of(context)!;

    return Wrap(
      spacing: spacing.sm,
      runSpacing: spacing.sm,
      children: [
        FilterChip(
          label: Text(l.adminEnabledOnly ?? 'Enabled only'),
          selected: !showAll,
          onSelected: (_) => onChangedShowAll(false),
        ),
        FilterChip(
          label: Text(l.adminShowAll ?? 'Show all'),
          selected: showAll,
          onSelected: (_) => onChangedShowAll(true),
        ),
      ],
    );
  }
}
