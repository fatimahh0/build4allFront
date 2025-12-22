import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import '../../../orders_admin/domain/entities/admin_order_entities.dart';

class PaymentSummaryCard extends StatelessWidget {
  final PaymentSummary payment;
  final String? currencySymbol;

  const PaymentSummaryCard({
    super.key,
    required this.payment,
    this.currencySymbol,
  });

  double _ratio() {
    final total = payment.orderTotal;
    if (total <= 0) return 0;
    final r = payment.paidAmount / total;
    if (r.isNaN) return 0;
    return r.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;

    Color stateColor() {
      final s = payment.paymentState.trim().toUpperCase();
      if (s == 'PAID') return colors.success;
      if (s == 'PARTIAL') return colors.primary;
      if (s == 'UNPAID') return colors.danger;
      return colors.muted;
    }

    String money(double v) {
      final sym = (currencySymbol ?? '').trim();
      final txt = v.toStringAsFixed(2);
      return sym.isEmpty ? txt : '$sym$txt';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Payment Summary',
                style: tokens.typography.titleMedium.copyWith(
                  color: colors.label,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: stateColor().withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: stateColor().withOpacity(0.30)),
                ),
                child: Text(
                  payment.paymentState,
                  style: tokens.typography.bodySmall.copyWith(
                    color: stateColor(),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),

          LinearProgressIndicator(
            value: _ratio(),
            minHeight: 10,
            backgroundColor: colors.border.withOpacity(0.25),
          ),

          SizedBox(height: spacing.sm),

          Row(
            children: [
              Expanded(child: _kv(context, 'Total', money(payment.orderTotal))),
              SizedBox(width: spacing.md),
              Expanded(child: _kv(context, 'Paid', money(payment.paidAmount))),
            ],
          ),

          if (!payment.fullyPaid) ...[
            SizedBox(height: spacing.xs),
            _kv(
              context,
              'Remaining',
              money(payment.remainingAmount),
              emphasize: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _kv(
    BuildContext context,
    String k,
    String v, {
    bool emphasize = false,
  }) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          k,
          style: tokens.typography.bodySmall.copyWith(color: colors.muted),
        ),
        Text(
          v,
          style: tokens.typography.bodyMedium.copyWith(
            color: emphasize ? colors.danger : colors.label,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
