import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';

import '../../domain/entities/shipping_method.dart';

class AdminShippingMethodCard extends StatelessWidget {
  final ShippingMethod method;
  final VoidCallback onEdit;
  final VoidCallback onDisable;

  const AdminShippingMethodCard({
    super.key,
    required this.method,
    required this.onEdit,
    required this.onDisable,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final c = tokens.colors;
    final spacing = tokens.spacing;
    final text = tokens.typography;

    final isDisabled = !method.enabled;

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
            Container(
              padding: EdgeInsets.all(spacing.sm),
              decoration: BoxDecoration(
                color: c.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                color: c.primary,
                size: 20,
              ),
            ),
            SizedBox(width: spacing.sm),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: text.titleMedium.copyWith(
                      color: c.label,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if ((method.description ?? '').trim().isNotEmpty) ...[
                    SizedBox(height: spacing.xs),
                    Text(
                      method.description!,
                      style: text.bodySmall.copyWith(color: c.muted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: spacing.xs),
                  Text(
                    '${l.adminShippingTypeShort ?? "Type"}: ${method.methodType}',
                    style: text.bodySmall.copyWith(color: c.muted),
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    isDisabled
                        ? l.adminDisabledLabel
                        : l.adminActiveLabel,
                    style: text.bodySmall.copyWith(
                      color: isDisabled ? c.muted : (c.success ?? c.primary),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit, color: c.primary),
                  tooltip: l.adminEdit ?? 'Edit',
                ),
                IconButton(
                  onPressed: isDisabled ? null : onDisable,
                  icon: Icon(
                    Icons.block_rounded,
                    color: isDisabled ? c.muted : c.danger,
                  ),
                  tooltip: l.adminDisable,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}