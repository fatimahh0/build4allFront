import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:build4front/core/theme/theme_cubit.dart';

class AuthCardShell extends StatelessWidget {
  final Widget child;
  final String title;
  final String subtitle;
  final IconData icon;

  const AuthCardShell({
    super.key,
    required this.child,
    required this.title,
    required this.subtitle,
    this.icon = Icons.lock_reset,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final card = tokens.card;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colors.primary.withOpacity(0.1),
                  child: Icon(icon, color: colors.primary, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: t.titleLarge?.copyWith(
                    color: colors.label,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: t.bodyMedium?.copyWith(color: colors.body),
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(card.padding),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(card.radius),
                    border: card.showBorder
                        ? Border.all(color: colors.border.withOpacity(0.15))
                        : null,
                    boxShadow: card.showShadow
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: card.elevation * 2,
                              offset: Offset(0, card.elevation * 0.6),
                            ),
                          ]
                        : null,
                  ),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
