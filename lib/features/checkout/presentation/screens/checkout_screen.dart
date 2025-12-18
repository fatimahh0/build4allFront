import 'package:build4front/core/config/app_config.dart';
import 'package:build4front/core/config/env.dart';
import 'package:build4front/features/checkout/presentation/screens/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';
import 'package:build4front/common/widgets/app_toast.dart';
import 'package:build4front/common/widgets/primary_button.dart';

import 'package:build4front/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:build4front/features/cart/presentation/bloc/cart_event.dart';

import '../bloc/checkout_bloc.dart';
import '../bloc/checkout_event.dart';
import '../bloc/checkout_state.dart';

import '../widgets/checkout_section_card.dart';
import '../widgets/checkout_address_form.dart';
import '../widgets/checkout_coupon_field.dart';
import '../widgets/checkout_shipping_methods.dart';
import '../widgets/checkout_payment_methods.dart';
import '../widgets/checkout_items_preview.dart';
import '../widgets/checkout_order_summary.dart';
import '../widgets/checkout_bottom_bar.dart';

class CheckoutScreen extends StatefulWidget {
  final AppConfig appConfig;
  final int? ownerProjectId;

  const CheckoutScreen({
    super.key,
    required this.appConfig,
    this.ownerProjectId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CheckoutBloc>().add(const CheckoutStarted());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final spacing = tokens.spacing;
    final colors = tokens.colors;

    return BlocListener<CheckoutBloc, CheckoutState>(
      listenWhen: (prev, curr) =>
          prev.error != curr.error || prev.orderSummary != curr.orderSummary,
      listener: (context, state) {
        if (state.error != null && state.error!.trim().isNotEmpty) {
          AppToast.show(context, state.error!, isError: true);
        }

        if (state.orderSummary != null) {
          final id = state.orderSummary!.orderId;

          AppToast.show(context, l10n.checkoutOrderPlacedToast(id));

          context.read<CartBloc>().add(const CartRefreshed());

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsScreen(summary: state.orderSummary!),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.checkoutTitle)),
        body: BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, state) {
            if (state.loading) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(spacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      SizedBox(height: spacing.md),
                      Text(
                        l10n.checkoutLoading,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: colors.body),
                      ),
                    ],
                  ),
                ),
              );
            }

            final cart = state.cart;
            if (cart == null || cart.items.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(spacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 44,
                        color: colors.muted,
                      ),
                      SizedBox(height: spacing.sm),
                      Text(
                        l10n.checkoutEmptyCart,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: colors.label),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: spacing.lg),
                      PrimaryButton(
                        label: l10n.checkoutGoBack,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CheckoutBloc>().add(
                  const CheckoutRefreshRequested(),
                );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(spacing.md),
                children: [
                  CheckoutSectionCard(
                    title: l10n.checkoutItemsTitle,
                    child: CheckoutItemsPreview(cart: cart),
                  ),
                  SizedBox(height: spacing.md),

                  CheckoutSectionCard(
                    title: l10n.checkoutAddressTitle,
                    child: CheckoutAddressForm(
                      initial: state.address,
                      onApply: (addr) {
                        context.read<CheckoutBloc>().add(
                          CheckoutAddressChanged(addr),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: spacing.md),

                  CheckoutSectionCard(
                    title: l10n.checkoutCouponTitle,
                    child: CheckoutCouponField(
                      initial: state.coupon,
                      onChanged: (v) {
                        context.read<CheckoutBloc>().add(
                          CheckoutCouponChanged(v),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: spacing.md),

                  CheckoutSectionCard(
                    title: l10n.checkoutShippingTitle,
                    child: CheckoutShippingMethods(
                      quotes: state.shippingQuotes,
                      selectedMethodId: state.selectedShippingMethodId,
                      onSelect: (id) => context.read<CheckoutBloc>().add(
                        CheckoutShippingSelected(id),
                      ),
                      onRefresh: () => context.read<CheckoutBloc>().add(
                        const CheckoutRefreshRequested(),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.md),

                  // ✅ Payment section wrapped in card again (consistent UI)
                  CheckoutSectionCard(
                    title: l10n.checkoutPaymentTitle,
                    child: CheckoutPaymentMethods(
                      methods: state.paymentMethods,
                      selectedIndex: state.selectedPaymentIndex,
                      onSelectIndex: (i) => context.read<CheckoutBloc>().add(
                        CheckoutPaymentSelected(i),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.md),

                  CheckoutSectionCard(
                    title: l10n.checkoutSummaryTitle,
                    child: CheckoutOrderSummary(
                      cart: cart,
                      selectedShipping: state.selectedQuote,
                      tax: state.tax,
                    ),
                  ),
                  SizedBox(height: spacing.xl),
                ],
              ),
            );
          },
        ),

        bottomNavigationBar: BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, state) {
            final cart = state.cart;
            if (cart == null || cart.items.isEmpty) {
              return const SizedBox.shrink();
            }

            return CheckoutBottomBar(
              cart: cart,
              selectedShipping: state.selectedQuote,
              tax: state.tax,
              isPlacing: state.placing,
             onPlaceOrder: () {
                final s = context.read<CheckoutBloc>().state;

                // ✅ stop spam taps
                if (s.placing) return;

                if (s.selectedPaymentIndex == null) {
                  AppToast.show(
                    context,
                    l10n.checkoutSelectPayment,
                    isError: true,
                  );
                  return;
                }

                if (s.shippingQuotes.isNotEmpty &&
                    s.selectedShippingMethodId == null) {
                  AppToast.show(
                    context,
                    l10n.checkoutSelectShipping,
                    isError: true,
                  );
                  return;
                }

                // ✅ extra: if Stripe selected but key missing
                final idx = s.selectedPaymentIndex!;
                final code = (idx >= 0 && idx < s.paymentMethods.length)
                    ? s.paymentMethods[idx].code.trim().toUpperCase()
                    : '';

                if (code == 'STRIPE' && Env.stripePublishableKey.isEmpty) {
                  AppToast.show(
                    context,
                    'Stripe key is missing in build config',
                    isError: true,
                  );
                  return;
                }

                context.read<CheckoutBloc>().add(
                  const CheckoutPlaceOrderPressed(),
                );
              },

            );
          },
        ),
      ),
    );
  }
}
