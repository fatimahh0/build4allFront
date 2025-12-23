import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import 'package:build4front/l10n/app_localizations.dart';

import 'package:build4front/features/checkout/data/models/checkout_summary_model.dart';
import '../utils/invoice_pdf.dart';

// ✅ currency formatter (like Explore)
import 'package:build4front/features/catalog/cubit/money.dart';

class OrderDetailsScreen extends StatelessWidget {
  final CheckoutSummaryModel summary;
  const OrderDetailsScreen({super.key, required this.summary});

  double _effectiveUnit(CheckoutLineSummaryModel l) {
    if (l.quantity <= 0) return l.unitPrice;
    return l.lineSubtotal / l.quantity; // selling/effective
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final totalTax = summary.itemTaxTotal + summary.shippingTaxTotal;

    final couponCode = (summary.couponCode ?? '').trim();
    final discount = summary.couponDiscount ?? 0.0;
    final showCoupon = couponCode.isNotEmpty;

    final dateValue = (summary.orderDate ?? '').trim();
    final shownDate = dateValue.isEmpty ? l10n.commonDash : dateValue;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderDetailsTitle(summary.orderId))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.orderDetailsDateLine(shownDate)),
          const SizedBox(height: 12),

          Text(
            l10n.orderDetailsItemsTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),

          ...summary.lines.map((l) {
            final unit = _effectiveUnit(l);

            final name = ((l.itemName ?? '').trim().isEmpty)
                ? l10n.orderDetailsItemFallback(l.itemId)
                : l.itemName!.trim();

            return Container(
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
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.orderDetailsQtyUnitLine(
                            l.quantity,
                            // ✅ Explore-style currency
                            money(context, unit),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    // ✅ Explore-style currency
                    money(context, l.lineSubtotal),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 24),

          _row(
            context,
            l10n.orderDetailsSubtotal,
            money(context, summary.itemsSubtotal),
          ),
          _row(
            context,
            l10n.orderDetailsShipping,
            money(context, summary.shippingTotal),
          ),
          _row(context, l10n.orderDetailsTax, money(context, totalTax)),

          if (showCoupon)
            _row(
              context,
              l10n.orderDetailsCouponLine(couponCode),
              "-${money(context, discount)}",
            ),

          const SizedBox(height: 6),
          _row(
            context,
            l10n.orderDetailsGrandTotal,
            money(context, summary.grandTotal),
            bold: true,
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () async {
              final bytes = await InvoicePdf.build(summary);
              await Printing.sharePdf(
                bytes: bytes,
                filename: "invoice-${summary.orderId}.pdf",
              );
            },
            child: Text(l10n.orderDetailsDownloadInvoice),
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String left,
    String right, {
    bool bold = false,
  }) {
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
