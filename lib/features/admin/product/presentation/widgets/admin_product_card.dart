import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/config/env.dart';
import 'package:build4front/core/theme/theme_cubit.dart';
import '../../domain/entities/product.dart';

class AdminProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AdminProductCard({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
  });

  String? _resolveImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;

    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return '${Env.apiBaseUrl}$trimmed';
  }

  Future<void> _showActionsSheet(BuildContext context) async {
    final tokens = context.read<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final text = tokens.typography;

    final action = await showModalBottomSheet<String>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.card.radius),
        ),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: colors.primary),
                title: Text(
                  'Edit product',
                  style: text.bodyMedium.copyWith(color: colors.label),
                ),
                onTap: () => Navigator.of(ctx).pop('edit'),
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: colors.danger),
                title: Text(
                  'Delete product',
                  style: text.bodyMedium.copyWith(color: colors.danger),
                ),
                onTap: () => Navigator.of(ctx).pop('delete'),
              ),
              SizedBox(height: spacing.sm),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );

    if (action == 'edit' && onEdit != null) {
      onEdit!();
    } else if (action == 'delete' && onDelete != null) {
      onDelete!();
    }
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

    Widget imagePlaceholder() {
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
          onTap: () => _showActionsSheet(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => imagePlaceholder(),
                      )
                    : imagePlaceholder(),
              ),
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
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium.copyWith(
                          color: colors.label,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
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
