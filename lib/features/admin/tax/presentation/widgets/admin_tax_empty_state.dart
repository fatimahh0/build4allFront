import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';

class AdminTaxEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const AdminTaxEmptyState({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final c = tokens.colors;
    final spacing = tokens.spacing;
    final text = tokens.typography;

    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(tokens.card.radius),
        border: Border.all(color: c.border.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, color: c.muted, size: 36),
          SizedBox(height: spacing.sm),
          Text(
            l.adminTaxNoRules,
            style: text.bodyMedium.copyWith(color: c.muted),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.md),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(l.adminTaxAddRule),
          ),
        ],
      ),
    );
  }
}
