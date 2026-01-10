import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/excel_validation_result.dart';

class ExcelCountsCard extends StatelessWidget {
  final ExcelValidationResult validation;
  const ExcelCountsCard({super.key, required this.validation});

  @override
  Widget build(BuildContext context) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;

    Widget chip(String label, int value) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.border),
        ),
        child: Text(
          '$label: $value',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.body,
                fontWeight: FontWeight.w600,
              ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(tokens.card.radius),
        border: Border.all(color: colors.border),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          chip('Categories', validation.categories),
          chip('ItemTypes', validation.itemTypes),
          chip('Products', validation.products),
          chip('Tax', validation.taxRules),
          chip('Shipping', validation.shippingMethods),
          chip('Coupons', validation.coupons),
        ],
      ),
    );
  }
}
