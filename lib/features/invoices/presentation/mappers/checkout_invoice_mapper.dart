import 'package:build4front/features/checkout/data/models/checkout_summary_model.dart';
import 'package:build4front/features/checkout/domain/entities/checkout_entities.dart';

import '../../domain/entities/invoice_data.dart';

class CheckoutInvoiceMapper {
  static InvoiceData fromCheckout(
    CheckoutSummaryModel summary, {
    ShippingAddress? address,
    ShippingQuote? shipping,
    Map<int, String>? itemNameById,
  }) {
    String lineName(CheckoutLineSummaryModel l) {
      final backendName = (l.itemName ?? '').trim();
      if (backendName.isNotEmpty) return backendName;

      final fallback = (itemNameById?[l.itemId] ?? '').trim();
      if (fallback.isNotEmpty) return fallback;

      return 'Item';
    }

    double effectiveUnit(CheckoutLineSummaryModel l) {
      if (l.quantity <= 0) return l.unitPrice;
      return l.lineSubtotal / l.quantity;
    }

    return InvoiceData(
      orderId: summary.orderId,
      orderCode: (summary.orderCode ?? '').trim(),
      orderDateText: (summary.orderDate ?? '').trim(),
      currencySymbol: (summary.currencySymbol).trim(),
      paymentProvider: (summary.paymentProviderCode ?? '').trim(),
      paymentStatus: (summary.paymentStatus ?? '').trim(),
      providerReference: (summary.providerPaymentId ?? '').trim(),
      paymentMethod: (summary.paymentProviderCode ?? '').trim(),
      customerName: (address?.fullName ?? '').trim(),
      customerPhone: (address?.phone ?? '').trim(),
      customerEmail: '',
      addressLine: (address?.addressLine ?? '').trim(),
      city: (address?.city ?? '').trim(),
      postalCode: (address?.postalCode ?? '').trim(),
      shippingMethodName: (shipping?.methodName ?? '').trim(),
      itemsSubtotal: summary.itemsSubtotal,
      shippingTotal: summary.shippingTotal,
      itemTaxTotal: summary.itemTaxTotal,
      shippingTaxTotal: summary.shippingTaxTotal,
      couponCode: (summary.couponCode ?? '').trim(),
      couponDiscount: summary.couponDiscount ?? 0.0,
      grandTotal: summary.grandTotal,
      lines: summary.lines
          .map(
            (l) => InvoiceLineData(
              itemName: lineName(l),
              quantity: l.quantity,
              unitPrice: effectiveUnit(l),
              lineSubtotal: l.lineSubtotal,
            ),
          )
          .toList(),
    );
  }
}