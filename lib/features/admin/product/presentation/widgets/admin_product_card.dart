import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/config/env.dart';
import 'package:build4front/core/theme/theme_cubit.dart';

import '../../domain/entities/product.dart';

class AdminProductCard extends StatefulWidget {
  final Product product;

  /// ✅ Provided by list screen (from CurrencySymbolCache warmed up).
  /// If null/empty => card shows placeholder "…16.00" until list updates.
  final String? currencySymbol;

  /// ✅ Optional: show tiny loader pill while list is warming currencies
  final bool currencyLoading;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AdminProductCard({
    super.key,
    required this.product,
    this.currencySymbol,
    this.currencyLoading = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<AdminProductCard> createState() => _AdminProductCardState();
}

class _AdminProductCardState extends State<AdminProductCard> {
  String? _resolveImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;

    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return '${Env.apiBaseUrl}$trimmed';
  }

  String _moneyStrict(num value, {int decimals = 2}) {
    final sym = (widget.currencySymbol ?? '').trim();
    final amount = value.toDouble().toStringAsFixed(decimals);

    // ✅ If symbol is ready
    if (sym.isNotEmpty) return '$sym$amount';

    // ✅ If not ready yet -> show placeholder
    // (so admin sees it’s loading, not wrong currency)
    return '…$amount';
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

    if (action == 'edit' && widget.onEdit != null) {
      widget.onEdit!();
    } else if (action == 'delete' && widget.onDelete != null) {
      widget.onDelete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final card = tokens.card;
    final text = tokens.typography;

    final showDiscountBadge = widget.product.onSale;
    final imageUrl = _resolveImageUrl(widget.product.imageUrl);

    Widget imagePlaceholder() {
      return Container(
        color: colors.muted.withOpacity(0.08),
        alignment: Alignment.center,
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => imagePlaceholder(),
                          )
                        : imagePlaceholder(),

                    // ✅ show loader only when list is warming AND this product has currencyId
                    if (widget.currencyLoading && widget.product.currencyId != null)
                      Positioned(
                        top: spacing.xs,
                        right: spacing.xs,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                  ],
                ),
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
                        widget.product.name,
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
                            _moneyStrict(widget.product.effectivePrice),
                            style: text.bodyMedium.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.product.onSale) SizedBox(width: spacing.xs),
                          if (widget.product.onSale)
                            Text(
                              _moneyStrict(widget.product.price),
                              style: text.bodySmall.copyWith(
                                color: colors.muted,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: spacing.xs),
                      Text(
                        widget.product.status,
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
