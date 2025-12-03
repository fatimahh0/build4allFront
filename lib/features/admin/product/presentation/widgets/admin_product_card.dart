import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/config/env.dart';
import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/features/admin/product/domain/entities/product.dart';

class AdminProductCard extends StatelessWidget {
  final Product product;

  const AdminProductCard({super.key, required this.product});

  String? _resolveImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;

    final trimmed = url.trim();

    // Already full URL
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    // Backend gives "/uploads/xyz.jpg" → prefix with API base URL
    return '${Env.apiBaseUrl}$trimmed';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final card = tokens.card;
    final text = tokens.typography;

    final showDiscountBadge = product.onSale;
    final imageUrl = _resolveImageUrl(product.imageUrl);

    Widget _imagePlaceholder() {
      return Container(
        color: colors.muted.withOpacity(0.08),
        child: Icon(
          Icons.image_outlined,
          color: colors.muted.withOpacity(0.7),
          size: 32,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(card.radius),
      child: Material(
        color: colors.surface,
        child: InkWell(
          onTap: () {
            // TODO: navigate to edit product
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top image area
              AspectRatio(
                aspectRatio: 4 / 3,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),

              // Bottom content – fills remaining height, no overflow
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(spacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showDiscountBadge)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'On sale',
                            style: text.bodySmall.copyWith(
                              color: colors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (showDiscountBadge) SizedBox(height: spacing.xs),

                      // Product name (takes flexible space)
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium.copyWith(
                          color: colors.label,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // Push price/status to bottom
                      const Spacer(),

                      // Price row
                      Row(
                        children: [
                          Text(
                            product.effectivePrice.toStringAsFixed(2),
                            style: text.bodyMedium.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (product.onSale && product.salePrice != null)
                            SizedBox(width: spacing.xs),
                          if (product.onSale && product.salePrice != null)
                            Text(
                              product.price.toStringAsFixed(2),
                              style: text.bodySmall.copyWith(
                                color: colors.muted,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: spacing.xs),

                      // Status text
                      Text(
                        product.status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall.copyWith(color: colors.muted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
