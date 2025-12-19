import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';

class HomeBottomSection extends StatelessWidget {
  const HomeBottomSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;
    final l10n = AppLocalizations.of(context)!;

    // ✅ EXACT 2x2 like screenshot (doesn't stretch on wide screens)
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final iconSize = w < 360 ? 44.0 : 54.0;

            final items = <_Benefit>[
              _Benefit(
                icon: Icons.phone_rounded,
                label: l10n.home_footer_contact_title,
              ),
              _Benefit(
                icon: Icons.credit_card_rounded,
                label: l10n.home_bottom_slide_secure_title,
              ),
              _Benefit(
                icon: Icons.verified_rounded,
                label: l10n.home_bottom_benefit_authentic_products,
              ),
              _Benefit(
                icon: Icons.local_shipping_rounded,
                label: l10n.home_bottom_benefit_free_delivery_above("40"),
              ),
            ];

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: spacing.xl,
                crossAxisSpacing: spacing.xl,
                childAspectRatio: w < 360 ? 1.10 : 1.22,
              ),
              itemBuilder: (ctx, i) {
                final it = items[i];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      it.label,
                      style: t.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: spacing.md),
                    Icon(it.icon, size: iconSize, color: c.primary),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _Benefit {
  final IconData icon;
  final String label;
  const _Benefit({required this.icon, required this.label});
}
