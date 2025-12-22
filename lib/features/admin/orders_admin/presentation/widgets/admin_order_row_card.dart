import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import '../../domain/entities/admin_order_entities.dart';

class AdminOrderRowCard extends StatelessWidget {
  final OrderHeaderRow row;
  final VoidCallback onTap;

  const AdminOrderRowCard({super.key, required this.row, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;

    Color statusColor() {
      final s = row.status.trim().toUpperCase();
      if (s == 'COMPLETED') return colors.success;
      if (s == 'CANCELED' || s == 'REFUNDED' || s == 'REJECTED')
        return colors.danger;
      return colors.muted; // pending-ish
    }

    Color payColor() {
      final p = row.payment.paymentState.trim().toUpperCase();
      if (p == 'PAID') return colors.success;
      if (p == 'PARTIAL') return colors.primary;
      if (p == 'UNPAID') return colors.danger;
      return colors.muted;
    }

    num ratio() {
      final total = row.payment.orderTotal;
      if (total <= 0) return 0;
      final r = row.payment.paidAmount / total;
      return (r.isNaN ? 0 : r).clamp(0.0, 1.0);
    }

    String fmtDate() {
      final d = row.orderDate;
      if (d == null) return '—';
      return d.toLocal().toString();
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.card.radius),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Order #${row.id}',
                  style: tokens.typography.titleMedium.copyWith(
                    color: colors.label,
                  ),
                ),
                const Spacer(),
                _badge(context, row.statusUi, statusColor()),
                SizedBox(width: spacing.sm),
                _badge(context, row.payment.paymentState, payColor()),
              ],
            ),
            SizedBox(height: spacing.xs),
            Text(
              fmtDate(),
              style: tokens.typography.bodySmall.copyWith(color: colors.muted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacing.sm),

            LinearProgressIndicator(
              value: ratio().toDouble(),
              minHeight: 10,
              backgroundColor: colors.border.withOpacity(0.25),
            ),

            SizedBox(height: spacing.sm),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Items: ${row.itemsCount}',
                    style: tokens.typography.bodyMedium.copyWith(
                      color: colors.body,
                    ),
                  ),
                ),
                Text(
                  row.fullyPaid
                      ? 'Paid'
                      : 'Remaining: ${row.payment.remainingAmount.toStringAsFixed(2)}',
                  style: tokens.typography.bodyMedium.copyWith(
                    color: row.fullyPaid ? colors.success : colors.danger,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(BuildContext context, String text, Color color) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final spacing = tokens.spacing;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Text(
        text,
        style: tokens.typography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
