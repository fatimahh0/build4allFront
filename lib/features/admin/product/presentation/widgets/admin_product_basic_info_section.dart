import 'package:flutter/material.dart';
import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';

import 'admin_form_section_card.dart';

class AdminProductBasicInfoSection extends StatelessWidget {
  final dynamic tokens;
  final AppLocalizations l;
  final TextEditingController nameCtrl;
  final TextEditingController descriptionCtrl;

  const AdminProductBasicInfoSection({
    super.key,
    required this.tokens,
    required this.l,
    required this.nameCtrl,
    required this.descriptionCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = tokens.spacing;
    final text = tokens.typography;

    return AdminFormSectionCard(
      tokens: tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------- Name --------
          Text(l.adminProductNameLabel, style: text.titleMedium),
          SizedBox(height: spacing.xs),
          TextFormField(
            controller: nameCtrl,
            decoration: InputDecoration(hintText: l.adminProductNameHint),
            validator: (v) => v == null || v.trim().isEmpty
                ? l.adminProductNameRequired
                : null,
          ),
          SizedBox(height: spacing.md),

          // -------- Description --------
          Text(l.adminProductDescriptionLabel, style: text.titleMedium),
          SizedBox(height: spacing.xs),
          TextFormField(
            controller: descriptionCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l.adminProductDescriptionHint,
            ),
          ),
        ],
      ),
    );
  }
}
