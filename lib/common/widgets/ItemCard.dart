import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/network/globals.dart' as net;
import 'package:build4front/core/theme/theme_cubit.dart';

class ItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;

  /// Current price label (top-right overlay)
  final String? badgeLabel;

  /// Old price label (shown inside card with line-through)
  final String? oldPriceLabel;

  /// Small tag on image (top-left): e.g. "SALE" or "-30%"
  final String? tagLabel;

  final String? metaLabel;
  final double? width;
  final VoidCallback? onTap;

  final String? ctaLabel;
  final VoidCallback? onCtaPressed;

  const ItemCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.badgeLabel,
    this.oldPriceLabel,
    this.tagLabel,
    this.metaLabel,
    this.width,
    this.onTap,
    this.ctaLabel,
    this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final themeState = context.read<ThemeCubit>().state;
    final cardTokens = themeState.tokens.card;
    final spacing = themeState.tokens.spacing;

    String? resolvedImageUrl;
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      resolvedImageUrl = net.resolveUrl(imageUrl!);
    }

    final hasCta = ctaLabel != null && ctaLabel!.trim().isNotEmpty;

    return SizedBox(
      width: width ?? 160,
      child: InkWell(
        borderRadius: BorderRadius.circular(cardTokens.radius),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(cardTokens.radius),
            border: cardTokens.showBorder
                ? Border.all(color: c.outline.withOpacity(0.18))
                : null,
            boxShadow: cardTokens.showShadow
                ? [
                    BoxShadow(
                      color: c.shadow.withOpacity(0.04),
                      blurRadius: cardTokens.elevation * 2,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(cardTokens.radius),
                ),
                child: SizedBox(
                  height: cardTokens.imageHeight,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (resolvedImageUrl != null &&
                          resolvedImageUrl!.isNotEmpty)
                        Image.network(
                          resolvedImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: c.surface,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: c.error,
                                size: 32,
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          color: c.surface,
                          child: Icon(
                            Icons.image_outlined,
                            color: c.primary,
                            size: 32,
                          ),
                        ),

                      // TAG (top-left)
                      if (tagLabel != null && tagLabel!.trim().isNotEmpty)
                        Positioned(
                          top: spacing.xs,
                          left: spacing.xs,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: spacing.sm,
                              vertical: spacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              tagLabel!,
                              style: t.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                      // PRICE (top-right)
                      if (badgeLabel != null && badgeLabel!.isNotEmpty)
                        Positioned(
                          top: spacing.xs,
                          right: spacing.xs,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: spacing.sm,
                              vertical: spacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              badgeLabel!,
                              style: t.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // CONTENT
              Padding(
                padding: EdgeInsets.all(cardTokens.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: t.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: spacing.xs),

                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      Text(
                        subtitle!,
                        style: t.bodySmall?.copyWith(
                          color: c.onSurface.withOpacity(0.75),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: spacing.xs),
                    ],

                    // Old price line-through (if sale)
                    if (oldPriceLabel != null && oldPriceLabel!.isNotEmpty) ...[
                      Text(
                        oldPriceLabel!,
                        style: t.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: c.onSurface.withOpacity(0.55),
                        ),
                      ),
                      SizedBox(height: spacing.xs),
                    ],

                    if (metaLabel != null && metaLabel!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: c.onSurface.withOpacity(0.6),
                          ),
                          SizedBox(width: spacing.xs),
                          Expanded(
                            child: Text(
                              metaLabel!,
                              style: t.bodySmall?.copyWith(
                                color: c.onSurface.withOpacity(0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: hasCta ? spacing.sm : 0),
                    ],

                    if (hasCta)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onCtaPressed,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: spacing.sm),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                cardTokens.radius / 1.5,
                              ),
                            ),
                            elevation: 0,
                            backgroundColor: c.primary,
                            foregroundColor: c.onPrimary,
                          ),
                          child: Text(
                            ctaLabel!,
                            style: t.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
