import 'package:build4front/features/checkout/data/models/checkout_summary_model.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';


import '../utils/invoice_pdf.dart';

class OrderDetailsScreen extends StatelessWidget {
  final CheckoutSummaryModel summary;
  const OrderDetailsScreen({super.key, required this.summary});

  String money(double v) => "${summary.currencySymbol}${v.toStringAsFixed(2)}";

  @override
  Widget build(BuildContext context) {
    final totalTax = summary.itemTaxTotal + summary.shippingTaxTotal;

    final couponCode = (summary.couponCode ?? '').trim();
    final discount = summary.couponDiscount ?? 0.0;
    final showCoupon = couponCode.isNotEmpty; // ✅ show even if discount = 0

    return Scaffold(
      appBar: AppBar(title: Text("Order #${summary.orderId}")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Date: ${summary.orderDate ?? '-'}"),
          const SizedBox(height: 12),

          const Text(
            "Items",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),

          ...summary.lines.map(
            (l) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ((l.itemName ?? '').trim().isEmpty)
                              ? 'Item #${l.itemId}'
                              : l.itemName!,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Qty: ${l.quantity}  •  Unit: ${money(l.unitPrice)}",
                        ),
                      ],
                    ),
                  ),
                  Text(
                    money(l.lineSubtotal),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 24),

          _row("Subtotal", money(summary.itemsSubtotal)),
          _row("Shipping", money(summary.shippingTotal)),
          _row("Tax", money(totalTax)),
          if (showCoupon) _row("Coupon ($couponCode)", "-${money(discount)}"),

          const SizedBox(height: 6),
          _row("Grand Total", money(summary.grandTotal), bold: true),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () async {
              final bytes = await InvoicePdf.build(summary);
              await Printing.sharePdf(
                bytes: bytes,
                filename: "invoice-${summary.orderId}.pdf",
              );
            },
            child: const Text("Download Invoice PDF"),
          ),
        ],
      ),
    );
  }

  Widget _row(String left, String right, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: style),
          Text(right, style: style),
        ],
      ),
    );
  }
}
