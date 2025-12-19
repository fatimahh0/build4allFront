
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final themeState = context.watch<ThemeCubit>().state;
    final spacing = themeState.tokens.spacing;

    Widget section({
      required String title,
      required String body,
      IconData icon = Icons.privacy_tip_outlined,
    }) {
      return Container(
        margin: EdgeInsets.only(bottom: spacing.md),
        padding: EdgeInsets.all(spacing.lg),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.outline.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: c.onSurface.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: c.primary),
            SizedBox(width: spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    body,
                    style: t.bodySmall?.copyWith(
                      color: c.onSurface.withOpacity(0.75),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacy_policy_title),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            spacing.lg,
            spacing.lg,
            spacing.lg,
            spacing.xl,
          ),
          children: [
            Text(
              l10n.privacy_policy_intro_title,
              style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            SizedBox(height: spacing.xs),
            Text(
              l10n.privacy_policy_intro_body,
              style: t.bodyMedium?.copyWith(
                color: c.onSurface.withOpacity(0.75),
                height: 1.4,
              ),
            ),
            SizedBox(height: spacing.lg),

            section(
              title: l10n.privacy_policy_collect_title,
              body: l10n.privacy_policy_collect_body,
              icon: Icons.storage_rounded,
            ),
            section(
              title: l10n.privacy_policy_use_title,
              body: l10n.privacy_policy_use_body,
              icon: Icons.auto_fix_high_rounded,
            ),
            section(
              title: l10n.privacy_policy_share_title,
              body: l10n.privacy_policy_share_body,
              icon: Icons.share_outlined,
            ),
            section(
              title: l10n.privacy_policy_security_title,
              body: l10n.privacy_policy_security_body,
              icon: Icons.lock_outline_rounded,
            ),
            section(
              title: l10n.privacy_policy_choices_title,
              body: l10n.privacy_policy_choices_body,
              icon: Icons.tune_rounded,
            ),
            section(
              title: l10n.privacy_policy_contact_title,
              body: l10n.privacy_policy_contact_body,
              icon: Icons.support_agent_rounded,
            ),

            SizedBox(height: spacing.lg),
            Text(
              l10n.privacy_policy_last_updated,
              style: t.bodySmall?.copyWith(
                color: c.onSurface.withOpacity(0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
