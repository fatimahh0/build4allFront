import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:build4front/core/theme/theme_cubit.dart';

class CheckoutSectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const CheckoutSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final card = tokens.card;
    final spacing = tokens.spacing;
    final t = Theme.of(context).textTheme;

    final shadow = card.showShadow
        ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: card.elevation * 2,
              offset: const Offset(0, 4),
            ),
          ]
        : <BoxShadow>[];

    return Container(
      padding: EdgeInsets.all(card.padding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(card.radius),
        border: card.showBorder
            ? Border.all(color: colors.border.withOpacity(0.25))
            : null,
        boxShadow: shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: t.titleMedium?.copyWith(color: colors.label)),
          SizedBox(height: spacing.sm),
          child,
        ],
      ),
    );
  }
}
