import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';

enum ShippingMethodsFilter {
  enabledOnly,
  disabledOnly,
  all,
}

class AdminShippingFiltersBar extends StatelessWidget {
  final ShippingMethodsFilter filter;
  final ValueChanged<ShippingMethodsFilter> onChanged;

  const AdminShippingFiltersBar({
    super.key,
    required this.filter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final spacing = tokens.spacing;

    return Wrap(
      spacing: spacing.sm,
      runSpacing: spacing.sm,
      children: [
        ChoiceChip(
          label: Text(l.adminEnabledOnly),
          selected: filter == ShippingMethodsFilter.enabledOnly,
          onSelected: (_) => onChanged(ShippingMethodsFilter.enabledOnly),
        ),
        ChoiceChip(
          label: Text(l.adminDisabledOnly),
          selected: filter == ShippingMethodsFilter.disabledOnly,
          onSelected: (_) => onChanged(ShippingMethodsFilter.disabledOnly),
        ),
        ChoiceChip(
          label: Text(l.adminAllLabel),
          selected: filter == ShippingMethodsFilter.all,
          onSelected: (_) => onChanged(ShippingMethodsFilter.all),
        ),
      ],
    );
  }
}