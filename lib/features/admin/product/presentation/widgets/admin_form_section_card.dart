import 'package:flutter/material.dart';

class AdminFormSectionCard extends StatelessWidget {
  final dynamic tokens;
  final Widget child;

  const AdminFormSectionCard({
    super.key,
    required this.tokens,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final c = tokens.colors;
    final spacing = tokens.spacing;

    return Container(
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(tokens.card.radius),
        border: Border.all(color: c.border.withOpacity(0.4)),
      ),
      child: child,
    );
  }
}
