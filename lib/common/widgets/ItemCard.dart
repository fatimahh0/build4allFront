// lib/features/items/presentation/widgets/item_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/network/globals.dart' as net;
import 'package:build4front/core/theme/theme_cubit.dart';

class ItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? badgeLabel;
  final String? metaLabel;
  final double? width;
  final VoidCallback? onTap;

  /// NEW: label for CTA button (e.g. "Add to cart", "Book now")
  final String? ctaLabel;

  /// NEW: callback when CTA button is pressed
  final VoidCallback? onCtaPressed;

  const ItemCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.badgeLabel,
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

    // Read design tokens from ThemeCubit (card + spacing)
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
              // ---------- IMAGE AREA ----------
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
                            // Fallback if image fails to load
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    c.errorContainer.withOpacity(0.1),
                                    c.error.withOpacity(0.15),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: c.error,
                                size: 32,
                              ),
                            );
                          },
                        )
                      else
                        // Fallback if no image URL at all
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                c.primary.withOpacity(0.18),
                                c.primaryContainer.withOpacity(0.25),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            Icons.image_outlined,
                            color: c.primary.withOpacity(0.9),
                            size: 32,
                          ),
                        ),

                      // Price / badge (top-right)
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
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ---------- CONTENT AREA ----------
              Padding(
                padding: EdgeInsets.all(cardTokens.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: t.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: spacing.xs),

                    // Subtitle (optional, e.g. location / short desc)
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      Text(
                        subtitle!,
                        style: t.bodySmall?.copyWith(
                          color: c.onSurface.withOpacity(0.75),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: spacing.xs),
                    ],

                    // Meta info (optional, e.g. date/time)
                    if (metaLabel != null && metaLabel!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
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

                    // ---------- CTA BUTTON (optional) ----------
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
                              fontWeight: FontWeight.w600,
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
