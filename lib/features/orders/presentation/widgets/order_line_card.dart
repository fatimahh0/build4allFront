import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';

import '../../domain/entities/order_entities.dart';

class OrderLineCard extends StatelessWidget {
  final OrderLine line;
  const OrderLineCard({super.key, required this.line});

  String _prettyStatus(String raw) {
    final s = raw.trim().toUpperCase();
    if (s.isEmpty) return '';
    if (s == 'CANCEL_REQUESTED') return 'Cancel Requested';
    // PENDING -> Pending
    return s.substring(0, 1) + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;

    final rawStatus = (line.order.status ?? '').trim().toUpperCase();

    // UI label: prefer backend pretty field, else pretty raw
    final uiStatus = line.orderStatus.trim().isNotEmpty
        ? line.orderStatus.trim()
        : _prettyStatus(rawStatus);

    Color statusColor() {
      if (rawStatus == 'PENDING' || rawStatus == 'CANCEL_REQUESTED') {
        return colors.muted;
      }
      if (rawStatus == 'COMPLETED') return colors.success;
      if (rawStatus == 'CANCELED' || rawStatus == 'CANCELLED') {
        return colors.danger;
      }
      return colors.muted;
    }

    final paid = line.wasPaid;

    Widget badge(String text, Color c) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.xs,
        ),
        decoration: BoxDecoration(
          color: c.withOpacity(0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: c.withOpacity(0.35)),
        ),
        child: Text(
          text,
          style: tokens.typography.bodySmall.copyWith(
            color: c,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    String formatDateTime(DateTime dt) {
      final y = dt.year.toString().padLeft(4, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$y-$m-$d $hh:$mm';
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
                // Title + line id
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        line.item.itemName,
                        style: tokens.typography.titleMedium.copyWith(
                          color: colors.label,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: spacing.sm),
                    Text(
                      '#${line.id}',
                      style: tokens.typography.bodySmall.copyWith(
                        color: colors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: spacing.xs),

                // Badges (wrap to prevent overflow)
                Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.sm,
                  children: [
                    badge(
                      uiStatus.isEmpty ? _prettyStatus(rawStatus) : uiStatus,
                      statusColor(),
                    ),
                    badge(
                      paid ? l10n.ordersPaid : l10n.ordersUnpaid,
                      paid ? colors.success : colors.muted,
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

                // optional datetime (activities)
                if (line.item.startDatetime != null) ...[
                  SizedBox(height: spacing.xs),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: colors.muted),
                      SizedBox(width: spacing.xs),
                      Expanded(
                        child: Text(
                          formatDateTime(line.item.startDatetime!),
                          style: tokens.typography.bodySmall.copyWith(
                            color: colors.muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // optional location (activities)
                if (line.item.location != null &&
                    line.item.location!.trim().isNotEmpty) ...[
                  SizedBox(height: spacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: colors.muted,
                      ),
                      SizedBox(width: spacing.xs),
                      Expanded(
                        child: Text(
                          line.item.location!.trim(),
                          style: tokens.typography.bodySmall.copyWith(
                            color: colors.muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
        width: 76,
        height: 76,
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
