import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExcelIssuesList extends StatelessWidget {
  final String title;
  final List<String> items;
  final bool isError;

  const ExcelIssuesList({
    super.key,
    required this.title,
    required this.items,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(tokens.card.radius),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isError ? Icons.error_outline : Icons.info_outline,
                  color: isError ? Colors.red : colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$title (${items.length})',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.label,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.take(30).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• $e',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.body,
                      ),
                ),
              )),
          if (items.length > 30)
            Text(
              '… +${items.length - 30} more',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.body,
                    fontWeight: FontWeight.w700,
                  ),
            ),
        ],
      ),
    );
  }
}
