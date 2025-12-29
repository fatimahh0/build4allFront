import 'package:build4front/features/admin/orders_admin/domain/entities/admin_order_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/common/widgets/app_toast.dart';
import 'package:build4front/l10n/app_localizations.dart';

import '../../domain/repositories/admin_orders_repository.dart';
import '../../domain/usecases/get_admin_order_details.dart';
import '../bloc/admin_order_details_bloc.dart';
import '../bloc/admin_order_details_event.dart';
import '../bloc/admin_order_details_state.dart';

class AdminOrderDetailsScreen extends StatefulWidget {
  final int orderId;
  const AdminOrderDetailsScreen({super.key, required this.orderId});

  @override
  State<AdminOrderDetailsScreen> createState() =>
      _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  late final AdminOrderDetailsBloc _bloc;

  bool _changed = false;

  static const _statusOptions = <String>[
    'PENDING',
    'CANCEL_REQUESTED',
    'CANCELED',
    'REJECTED',
    'REFUNDED',
    'COMPLETED',
  ];

  @override
  void initState() {
    super.initState();
    final repo = context.read<AdminOrdersRepository>();
    _bloc = AdminOrderDetailsBloc(
      getDetails: GetAdminOrderDetails(repo),
      repo: repo,
    )..add(AdminOrderDetailsStarted(widget.orderId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _toast(String msg, {bool error = false}) {
    final m = msg.trim();
    if (m.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppToast.show(context, m, isError: error);
    });
  }

  String _statusLabel(AppLocalizations l10n, String code) {
    switch (code) {
      case 'PENDING':
        return l10n.adminOrderStatusPending;
      case 'CANCEL_REQUESTED':
        return l10n.adminOrderStatusCancelRequested;
      case 'CANCELED':
        return l10n.adminOrderStatusCanceled;
      case 'REJECTED':
        return l10n.adminOrderStatusRejected;
      case 'REFUNDED':
        return l10n.adminOrderStatusRefunded;
      case 'COMPLETED':
        return l10n.adminOrderStatusCompleted;
      default:
        return code;
    }
  }

  Future<bool> _confirmMarkCashPaid({
    required BuildContext context,
    required AppLocalizations l10n,
    required dynamic tokens,
    required dynamic colors,
    required dynamic spacing,
  }) async {
    return (await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (_) {
            return AlertDialog(
              backgroundColor: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                l10n.adminMarkCashPaidTitle,
                style: tokens.typography.titleMedium.copyWith(
                  color: colors.label,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: Text(
                l10n.adminMarkCashPaidBody,
                style: tokens.typography.bodyMedium.copyWith(
                  color: colors.body,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    l10n.cancel,
                    style: tokens.typography.bodyMedium.copyWith(
                      color: colors.muted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.success,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.md,
                      vertical: spacing.sm,
                    ),
                  ),
                  child: Text(
                    l10n.confirm,
                    style: tokens.typography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            );
          },
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = AppLocalizations.of(context)!;

    final screenW = MediaQuery.sizeOf(context).width;
    final isWide = screenW >= 720;

    return BlocProvider.value(
      value: _bloc,
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, _changed);
          return false;
        },
        child: Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: colors.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, _changed),
            ),
            title: Text(
              l10n.adminOrderDetailsTitle(widget.orderId),
              style: tokens.typography.titleMedium.copyWith(
                color: colors.label,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          body: SafeArea(
            child: BlocConsumer<AdminOrderDetailsBloc, AdminOrderDetailsState>(
              listenWhen: (p, c) =>
                  p.error != c.error || p.message != c.message,
              listener: (context, state) {
                final err = (state.error ?? '').trim();
                if (err.isNotEmpty) {
                  _toast(err, error: true);
                  return;
                }
                final msg = (state.message ?? '').trim();
                if (msg.isNotEmpty) {
                  _changed = true;
                  _toast(msg);
                }
              },
              builder: (context, state) {
                if (state.loading && state.data == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = state.data;
                if (data == null) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(spacing.md),
                      child: Text(
                        state.error ?? l10n.adminOrderFailedToLoad,
                        style: tokens.typography.bodyMedium.copyWith(
                          color: colors.danger,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final o = data.order;

                final total = (o.payment.orderTotal <= 0)
                    ? o.totalPrice
                    : o.payment.orderTotal;
                final paid = o.payment.paidAmount;
                final progress =
                    total <= 0 ? 0.0 : (paid / total).clamp(0.0, 1.0);

                final currencySymbol = (o.currency?.symbol ?? '').trim();
                String money(double v) {
                  final txt = v.toStringAsFixed(2);
                  return currencySymbol.isEmpty ? txt : '$currencySymbol$txt';
                }

                Color payColor() {
                  final p = o.payment.paymentState.toUpperCase();
                  if (p == 'PAID') return colors.success;
                  if (p == 'PARTIAL') return colors.primary;
                  if (p == 'UNPAID') return colors.danger;
                  return colors.muted;
                }

                final paymentState = o.payment.paymentState.toUpperCase();
                final paymentMethod = (o.paymentMethod ?? '').toUpperCase();
                final isCash = paymentMethod == 'CASH';
                final canMarkCashPaid = isCash && paymentState != 'PAID';

                final currentStatus =
                    (o.status.isEmpty ? 'PENDING' : o.status).toUpperCase();
                final dropdownValue = _statusOptions.contains(currentStatus)
                    ? currentStatus
                    : _statusOptions.first;

                Widget paymentCard() {
                  return Container(
                    padding: EdgeInsets.all(spacing.md),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(tokens.card.radius),
                      border: Border.all(
                        color: colors.border.withOpacity(0.22),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.adminPaymentSummary,
                                style: tokens.typography.titleMedium.copyWith(
                                  color: colors.label,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: spacing.sm,
                                vertical: spacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: payColor().withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: payColor().withOpacity(0.35),
                                ),
                              ),
                              child: Text(
                                o.payment.paymentState,
                                style: tokens.typography.bodySmall.copyWith(
                                  color: payColor(),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: spacing.sm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: colors.border.withOpacity(0.25),
                          ),
                        ),
                        SizedBox(height: spacing.sm),
                        _kv(tokens, colors, l10n.adminOrderTotal, money(total)),
                        _kv(tokens, colors, l10n.adminPaid,
                            money(o.payment.paidAmount)),
                        if (!o.fullyPaid)
                          _kv(tokens, colors, l10n.adminRemaining,
                              money(o.payment.remainingAmount)),

                        // ✅ CASH button: ONLY triggers payment event
                        if (canMarkCashPaid) ...[
                          SizedBox(height: spacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: state.updating
                                      ? null
                                      : () async {
                                          final ok = await _confirmMarkCashPaid(
                                            context: context,
                                            l10n: l10n,
                                            tokens: tokens,
                                            colors: colors,
                                            spacing: spacing,
                                          );
                                          if (!ok) return;

                                          context
                                              .read<AdminOrderDetailsBloc>()
                                              .add(
                                                AdminOrderPaymentStateUpdateRequested(
                                                  orderId: o.id,
                                                  paymentState: 'PAID',
                                                ),
                                              );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.success,
                                    foregroundColor: colors.onPrimary,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: spacing.md,
                                      vertical: spacing.sm,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: Text(
                                    l10n.adminMarkCashPaidButton,
                                    style:
                                        tokens.typography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              if (state.updating) ...[
                                SizedBox(width: spacing.sm),
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }

                Widget orderInfoCard() {
                  return Container(
                    padding: EdgeInsets.all(spacing.md),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(tokens.card.radius),
                      border:
                          Border.all(color: colors.border.withOpacity(0.22)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.adminOrderInfo,
                          style: tokens.typography.titleMedium.copyWith(
                            color: colors.label,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: spacing.sm),
                        Text(
                          '${l10n.adminStatus}: ${o.statusUi}',
                          style: tokens.typography.bodyMedium
                              .copyWith(color: colors.body),
                        ),
                        SizedBox(height: spacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: dropdownValue,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: colors.background,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: spacing.md,
                                    vertical: spacing.sm,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: colors.border.withOpacity(0.35),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: colors.border.withOpacity(0.35),
                                    ),
                                  ),
                                ),
                                items: _statusOptions.map((code) {
                                  return DropdownMenuItem(
                                    value: code,
                                    child: Text(_statusLabel(l10n, code)),
                                  );
                                }).toList(),
                                onChanged: state.updating
                                    ? null
                                    : (v) {
                                        if (v == null) return;
                                        if (v.toUpperCase() == currentStatus) {
                                          return;
                                        }
                                        context
                                            .read<AdminOrderDetailsBloc>()
                                            .add(
                                              AdminOrderStatusUpdateRequested(
                                                orderId: o.id,
                                                status: v,
                                              ),
                                            );
                                      },
                              ),
                            ),
                            if (state.updating) ...[
                              SizedBox(width: spacing.sm),
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                }

                Widget itemsHeader() {
                  return Text(
                    l10n.adminItemsCount(data.itemsCount),
                    style: tokens.typography.titleMedium.copyWith(
                      color: colors.label,
                      fontWeight: FontWeight.w900,
                    ),
                  );
                }

                Widget itemCard(OrderDetailsItem it) {
                  final itemTotal = it.price * it.quantity;

                  return Container(
                    padding: EdgeInsets.all(spacing.md),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(tokens.card.radius),
                      border:
                          Border.all(color: colors.border.withOpacity(0.22)),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: (it.item.imageUrl == null)
                                ? Container(
                                    color: colors.border.withOpacity(0.2))
                                : Image.network(
                                    it.item.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: colors.border.withOpacity(0.2),
                                      child: Icon(Icons.image_not_supported,
                                          color: colors.muted),
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(width: spacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                it.item.itemName,
                                style: tokens.typography.bodyMedium.copyWith(
                                  color: colors.label,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: spacing.xs),
                              Text(
                                '${l10n.adminCustomer}: ${it.user.fullName}',
                                style: tokens.typography.bodySmall
                                    .copyWith(color: colors.muted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                l10n.adminQtyPriceLine(
                                    it.quantity, money(it.price)),
                                style: tokens.typography.bodySmall
                                    .copyWith(color: colors.muted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: spacing.sm),
                        Text(
                          money(itemTotal),
                          style: tokens.typography.bodyMedium.copyWith(
                            color: colors.label,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                Widget itemsList() {
                  if (!isWide) {
                    return Column(
                      children: data.items
                          .map((it) => Padding(
                                padding: EdgeInsets.only(bottom: spacing.sm),
                                child: itemCard(it),
                              ))
                          .toList(),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, c) {
                      final w = c.maxWidth;
                      final crossAxisCount = w >= 1024 ? 2 : 1;

                      const cardHeight = 92.0;
                      final cardWidth =
                          (w - (crossAxisCount - 1) * spacing.sm) /
                              crossAxisCount;
                      final aspect = cardWidth / cardHeight;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.items.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: spacing.sm,
                          crossAxisSpacing: spacing.sm,
                          childAspectRatio: aspect.clamp(2.8, 6.0),
                        ),
                        itemBuilder: (_, idx) => itemCard(data.items[idx]),
                      );
                    },
                  );
                }

                return ListView(
                  padding: EdgeInsets.all(spacing.md),
                  children: [
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: paymentCard()),
                          SizedBox(width: spacing.md),
                          Expanded(child: orderInfoCard()),
                        ],
                      )
                    else ...[
                      paymentCard(),
                      SizedBox(height: spacing.md),
                      orderInfoCard(),
                    ],
                    SizedBox(height: spacing.md),
                    itemsHeader(),
                    SizedBox(height: spacing.sm),
                    itemsList(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _kv(dynamic tokens, dynamic colors, String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              k,
              style: tokens.typography.bodySmall.copyWith(color: colors.muted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            v,
            style: tokens.typography.bodySmall.copyWith(
              color: colors.label,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
