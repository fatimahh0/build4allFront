import 'package:build4front/features/admin/orders_admin/domain/entities/admin_order_entities.dart';

import '../../domain/entities/invoice_data.dart';

class AdminOrderInvoiceMapper {
  static InvoiceData fromAdminOrder(OrderDetailsResponse data) {
    final o = data.order;

    final lines = data.items
        .map(
          (e) => InvoiceLineData(
            itemName: e.item.itemName.trim().isEmpty ? 'Item' : e.item.itemName.trim(),
            quantity: e.quantity,
            unitPrice: e.price,
            lineSubtotal: e.price * e.quantity,
          ),
        )
        .toList();

    final computedItemsSubtotal = lines.fold<double>(
      0,
      (sum, e) => sum + e.lineSubtotal,
    );

    final customerName = (o.shippingFullName ?? '').trim().isNotEmpty
        ? o.shippingFullName!.trim()
        : (data.items.isNotEmpty ? data.items.first.user.fullName.trim() : '');

    final currencySymbol = (o.currency?.symbol ?? '').trim();
    final grandTotal = (o.payment.orderTotal > 0) ? o.payment.orderTotal : o.totalPrice;

    return InvoiceData(
      orderId: o.id,
      orderCode: (o.orderCode ?? '').trim(),
      orderDateText: o.orderDate?.toIso8601String() ?? '',
      currencySymbol: currencySymbol,
      paymentProvider: (o.paymentMethod ?? '').trim(),
      paymentStatus: o.payment.paymentState.trim(),
      providerReference: '',
      paymentMethod: (o.paymentMethod ?? '').trim(),
      customerName: customerName,
      customerPhone: (o.shippingPhone ?? '').trim(),
      customerEmail: '',
      addressLine: (o.shippingAddress ?? '').trim(),
      city: (o.shippingCity ?? '').trim(),
      postalCode: (o.shippingPostalCode ?? '').trim(),
      shippingMethodName: (o.shippingMethodName ?? '').trim(),
      itemsSubtotal: computedItemsSubtotal,
      shippingTotal: o.shippingTotal ?? 0.0,
      itemTaxTotal: o.itemTaxTotal ?? 0.0,
      shippingTaxTotal: o.shippingTaxTotal ?? 0.0,
      couponCode: (o.couponCode ?? '').trim(),
      couponDiscount: o.couponDiscount ?? 0.0,
      grandTotal: grandTotal,
      lines: lines,
    );
  }
}