import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';

import '../../domain/entities/order_entities.dart';

class OrderLineCard extends StatelessWidget {
  final OrderLine line;
  const OrderLineCard({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;

    final status = line.orderStatus.trim();
    final paid = line.wasPaid;

    Color badgeColor() {
      final s = status.toLowerCase();
      if (s == 'pending') return colors.muted;
      if (s == 'completed') return colors.success;
      if (s == 'canceled' || s == 'cancelled') return colors.danger;
      return colors.muted;
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(tokens.card.radius),
        border: Border.all(color: colors.border.withOpacity(0.25)),
        boxShadow: tokens.card.showShadow
            ? [
                BoxShadow(
                  blurRadius: tokens.card.elevation,
                  offset: const Offset(0, 2),
                  color: Colors.black.withOpacity(0.06),
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.all(tokens.card.padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ImageBox(url: line.item.imageUrl),
          SizedBox(width: spacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.item.itemName,
                  style: tokens.typography.titleMedium.copyWith(
                    color: colors.label,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing.xs),

                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.sm,
                        vertical: spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor().withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: badgeColor().withOpacity(0.35),
                        ),
                      ),
                      child: Text(
                        status,
                        style: tokens.typography.bodySmall.copyWith(
                          color: badgeColor(),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: spacing.sm),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.sm,
                        vertical: spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: (paid ? colors.success : colors.muted)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: (paid ? colors.success : colors.muted)
                              .withOpacity(0.35),
                        ),
                      ),
                      child: Text(
                        paid ? l10n.ordersPaid : l10n.ordersUnpaid,
                        style: tokens.typography.bodySmall.copyWith(
                          color: paid ? colors.success : colors.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: spacing.sm),

                Text(
                  '${l10n.ordersQty}: ${line.quantity}',
                  style: tokens.typography.bodyMedium.copyWith(
                    color: colors.body,
                  ),
                ),

                if (line.item.location != null &&
                    line.item.location!.trim().isNotEmpty) ...[
                  SizedBox(height: spacing.xs),
                  Text(
                    line.item.location!,
                    style: tokens.typography.bodySmall.copyWith(
                      color: colors.muted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageBox extends StatelessWidget {
  final String? url;
  const _ImageBox({required this.url});

  @override
  Widget build(BuildContext context) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 70,
        height: 70,
        color: colors.background,
        child: (url == null || url!.trim().isEmpty)
            ? Icon(Icons.image_not_supported_outlined, color: colors.muted)
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.broken_image_outlined, color: colors.muted),
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: progress.expectedTotalBytes == null
                            ? null
                            : progress.cumulativeBytesLoaded /
                                  (progress.expectedTotalBytes ?? 1),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
