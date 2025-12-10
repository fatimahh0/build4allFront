import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';
import 'package:build4front/core/config/env.dart';

import '../../domain/entities/home_banner.dart';

class AdminHomeBannerCard extends StatelessWidget {
  final HomeBanner banner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminHomeBannerCard({
    super.key,
    required this.banner,
    required this.onEdit,
    required this.onDelete,
  });

  String _resolveImageUrl(String? url) {
    final u = (url ?? '').trim();
    if (u.isEmpty) return '';

    // already absolute
    if (u.startsWith('http://') || u.startsWith('https://')) return u;

    // backend relative
    final base = (Env.apiBaseUrl ?? '').trim();
    // ✅ If your Env uses a different name, replace apiBaseUrl accordingly.

    if (base.isEmpty) return u;

    // avoid double slashes
    if (u.startsWith('/')) return '$base$u';
    return '$base/$u';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final c = tokens.colors;
    final spacing = tokens.spacing;
    final text = tokens.typography;

    final imageUrl = _resolveImageUrl(banner.imageUrl);

    return Container(
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(tokens.card.radius),
        border: Border.all(color: c.border.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl.isEmpty
                ? _fallback(c)
                : Image.network(
                    imageUrl,
                    width: 74,
                    height: 74,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallback(c),
                  ),
          ),
          SizedBox(width: spacing.sm),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (banner.title ?? '').isEmpty
                      ? (l.adminUntitled ?? 'Untitled banner')
                      : banner.title!,
                  style: text.titleMedium.copyWith(
                    color: c.label,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if ((banner.subtitle ?? '').trim().isNotEmpty) ...[
                  SizedBox(height: spacing.xs),
                  Text(
                    banner.subtitle!,
                    style: text.bodySmall.copyWith(color: c.muted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: spacing.xs),
                Text(
                  '${l.adminTargetShort ?? "Target"}: ${banner.targetType ?? "NONE"}',
                  style: text.bodySmall.copyWith(color: c.muted),
                ),
                Text(
                  '${l.adminSortShort ?? "Sort"}: ${banner.sortOrder}',
                  style: text.bodySmall.copyWith(color: c.muted),
                ),
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: Icon(Icons.edit, color: c.primary),
                tooltip: l.adminEdit ?? 'Edit',
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete, color: c.danger),
                tooltip: l.adminDelete ?? 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fallback(dynamic c) => Container(
    width: 74,
    height: 74,
    color: c.border.withOpacity(0.08),
    child: Icon(Icons.image_not_supported_outlined, color: c.muted),
  );
}
