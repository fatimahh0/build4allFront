import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/config/env.dart';
import 'package:build4front/core/theme/theme_cubit.dart';

import '../../domain/entities/product.dart';

class AdminProductCard extends StatefulWidget {
  final Product product;
  final String? currencySymbol;
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

    if (sym.isNotEmpty) return '$sym$amount';
    return '…$amount';
  }

  int get _safeStock => widget.product.stock ?? 0;

  bool get _isOutOfStock => _safeStock <= 0;

  String get _availabilityText => _isOutOfStock ? 'Out of stock' : 'Available';

  Color _availabilityColor(dynamic colors) {
    return _isOutOfStock ? colors.danger : colors.success;
  }

  Future<void> _showActionsSheet(BuildContext context) async {
    final tokens = context.read<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final text = tokens.typography;

    final action = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.card.radius),
        ),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).padding.bottom;

        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              spacing.md,
              spacing.md,
              spacing.md,
              spacing.md + bottomInset,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: spacing.md),
                  decoration: BoxDecoration(
                    color: colors.muted.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.edit, color: colors.primary),
                  title: Text(
                    'Edit product',
                    style: text.bodyMedium.copyWith(color: colors.label),
                  ),
                  onTap: () => Navigator.of(ctx).pop('edit'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline, color: colors.danger),
                  title: Text(
                    'Delete product',
                    style: text.bodyMedium.copyWith(color: colors.danger),
                  ),
                  onTap: () => Navigator.of(ctx).pop('delete'),
                ),
                SizedBox(height: spacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: spacing.sm),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
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

                    if (widget.currencyLoading &&
                        widget.product.currencyId != null)
                      Positioned(
                        top: spacing.xs,
                        right: spacing.xs,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
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

                    Positioned(
                      left: spacing.xs,
                      top: spacing.xs,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.xs,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _availabilityColor(colors).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _availabilityText,
                          style: text.bodySmall.copyWith(
                            color: _availabilityColor(colors),
                            fontWeight: FontWeight.w700,
                          ),
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
                    mainAxisAlignment: MainAxisAlignment.start,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                          height: 1.18,
                        ),
                      ),

                      SizedBox(height: spacing.xs),

                      Text(
                        'Stock: $_safeStock',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall.copyWith(
                          color: _isOutOfStock ? colors.danger : colors.body,
                          fontWeight:
                              _isOutOfStock ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: spacing.xs),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              _moneyStrict(widget.product.effectivePrice),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodyMedium.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (widget.product.onSale) SizedBox(width: spacing.xs),
                          if (widget.product.onSale)
                            Flexible(
                              child: Text(
                                _moneyStrict(widget.product.price),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.bodySmall.copyWith(
                                  color: colors.muted,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                        ],
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