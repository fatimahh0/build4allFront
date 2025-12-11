// lib/features/cart/presentation/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';

import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_summary_card.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeState = context.watch<ThemeCubit>().state;
    final spacing = themeState.tokens.spacing;

    // trigger load on first open
    final cartBloc = context.read<CartBloc>();
    if (!cartBloc.state.isLoading && cartBloc.state.cart == null) {
      cartBloc.add(const CartStarted());
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cart_title)),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state.lastMessage != null) {
            final msgKey = state.lastMessage;
            String text;
            switch (msgKey) {
              case 'cart_item_added':
                text = l10n.cart_item_added;
                break;
              case 'cart_item_updated':
                text = l10n.cart_item_updated;
                break;
              case 'cart_item_removed':
                text = l10n.cart_item_removed;
                break;
              case 'cart_cleared':
                text = l10n.cart_cleared;
                break;
              default:
                text = '';
            }
            if (text.isNotEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(text)));
            }
          }

          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.cart == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final cart = state.cart;
          if (cart == null || cart.items.isEmpty) {
            return _EmptyCartView(
              message: l10n.cart_empty_message,
              cta: l10n.cart_empty_cta,
              onGoShopping: () {
                Navigator.of(context).pop(); // back to home
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CartBloc>().add(const CartRefreshed());
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.lg,
                spacing.lg,
                spacing.lg,
                spacing.lg,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return CartItemTile(
                          item: item,
                          currencySymbol: cart.currencySymbol,
                          onRemove: () {
                            context.read<CartBloc>().add(
                              CartItemRemoved(cartItemId: item.cartItemId),
                            );
                          },
                          onQuantityChanged: (q) {
                            context.read<CartBloc>().add(
                              CartItemQuantityChanged(
                                cartItemId: item.cartItemId,
                                quantity: q,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: spacing.md),
                  CartSummaryCard(
                    totalPrice: cart.totalPrice,
                    currencySymbol: cart.currencySymbol,
                    isUpdating: state.isUpdating,
                    checkoutLabel: l10n.cart_checkout,
                    onCheckout: () {
                      // TODO: navigate to Checkout flow later
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  final String message;
  final String cta;
  final VoidCallback onGoShopping;

  const _EmptyCartView({
    required this.message,
    required this.cta,
    required this.onGoShopping,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: c.onSurface.withOpacity(0.4),
            ),
            SizedBox(height: spacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: t.bodyLarge?.copyWith(color: c.onSurface.withOpacity(0.8)),
            ),
            SizedBox(height: spacing.lg),
            SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: onGoShopping,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(cta),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
