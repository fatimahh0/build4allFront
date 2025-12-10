import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';
import '../../domain/entities/tax_rule.dart';

class AdminTaxRuleCard extends StatelessWidget {
  final TaxRule rule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminTaxRuleCard({
    super.key,
    required this.rule,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final c = tokens.colors;
    final spacing = tokens.spacing;
    final text = tokens.typography;

    final isDisabled = !rule.enabled;

    return Opacity(
      opacity: isDisabled ? 0.55 : 1,
      child: Container(
        padding: EdgeInsets.all(spacing.md),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(tokens.card.radius),
          border: Border.all(
            color: isDisabled
                ? c.border.withOpacity(0.12)
                : c.border.withOpacity(0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon bubble
            Container(
              padding: EdgeInsets.all(spacing.sm),
              decoration: BoxDecoration(
                color: c.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.percent_outlined, color: c.primary, size: 20),
            ),
            SizedBox(width: spacing.sm),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.name,
                    style: text.titleMedium.copyWith(
                      color: c.label,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: spacing.xs),

                  Text(
                    '${l.adminTaxRateShort ?? "Rate"}: ${rule.rate.toStringAsFixed(2)}%',
                    style: text.bodySmall.copyWith(color: c.muted),
                  ),
                  SizedBox(height: spacing.xs),

                  Text(
                    '${l.adminTaxAppliesToShippingShort ?? "Shipping"}: ${rule.appliesToShipping ? l.yes : l.no}',
                    style: text.bodySmall.copyWith(color: c.muted),
                  ),
                  SizedBox(height: spacing.xs),

                  Text(
                    isDisabled
                        ? (l.adminDisabled ?? 'Disabled')
                        : (l.adminActive ?? 'Active'),
                    style: text.bodySmall.copyWith(
                      color: isDisabled ? c.muted : (c.success ?? c.primary),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit, color: c.primary),
                  tooltip: l.adminEdit ?? 'Edit',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete, color: c.danger),
                  tooltip: l.adminDelete ?? 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
