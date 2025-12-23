import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/config/env.dart';
import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';

import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_summary_card.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<CartBloc>();
      if (!bloc.state.isLoading && bloc.state.cart == null) {
        bloc.add(const CartStarted());
      }
    });
  }

  void _goHome() {
    // ✅ Force MainShell to open Home tab
    // IMPORTANT: Make sure "/" is your MainShell route.
    // If your MainShell route is "/shell" (for example), change it here too.
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (route) => false,
      arguments: const {'goHome': true},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.watch<ThemeCubit>().state.tokens.spacing;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cart_title)),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
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

          // ✅ Empty cart -> Browse must go HOME (not pop)
          if (cart == null || cart.items.isEmpty) {
            return _EmptyCartView(
              message: l10n.cart_empty_message,
              cta: l10n.cart_empty_cta,
              onGoShopping: _goHome,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CartBloc>().add(const CartRefreshed());
            },
            child: Padding(
              padding: EdgeInsets.all(spacing.lg),
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
                          currencySymbol: cart.currencySymbol, // kept, unused
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
                    itemsTotal: cart.itemsTotal,
                    shippingTotal: cart.shippingTotal,
                    taxTotal: cart.taxTotal,
                    discountTotal: cart.discountTotal,
                    grandTotal: cart.grandTotal,
                    currencySymbol: cart.currencySymbol, // kept, unused
                    isUpdating: state.isUpdating,
                    checkoutLabel: l10n.cart_checkout,
                    onCheckout: () {
                      final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;
                      final currencyId = int.tryParse(Env.currencyId) ?? 1;

                      Navigator.of(context).pushNamed(
                        '/checkout',
                        arguments: {
                          'ownerProjectId': ownerId,
                          'currencyId': currencyId,
                        },
                      );
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
