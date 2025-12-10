import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';
import 'package:build4front/features/admin/tax/presentation/screens/admin_tax_rules_screen.dart';

class AdminTaxTile extends StatelessWidget {
  final int ownerProjectId;

  const AdminTaxTile({super.key, required this.ownerProjectId});

  @override
  Widget build(BuildContext context) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final c = tokens.colors;
    final spacing = tokens.spacing;
    final text = tokens.typography;
    final l = AppLocalizations.of(context)!;

    return InkWell(
      borderRadius: BorderRadius.circular(tokens.card.radius),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminTaxRulesScreen(ownerProjectId: ownerProjectId),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(spacing.lg),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(tokens.card.radius),
          border: Border.all(color: c.border.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(spacing.sm),
              decoration: BoxDecoration(
                color: c.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.percent, color: c.primary),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.adminTaxRulesTitleShort ?? 'Tax',
                    style: text.titleMedium.copyWith(color: c.label),
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    l.adminTaxRulesSubtitle ?? 'Manage VAT and location rules',
                    style: text.bodySmall.copyWith(color: c.muted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: c.muted),
          ],
        ),
      ),
    );
  }
}
