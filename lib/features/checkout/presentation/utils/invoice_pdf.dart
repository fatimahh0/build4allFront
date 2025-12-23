import 'dart:typed_data';
import 'package:build4front/features/checkout/data/models/checkout_summary_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class InvoicePdf {
  static Future<Uint8List> build(
    CheckoutSummaryModel s, {
    // ✅ optional fallback (if currencySymbol is empty/null)
    String? fallbackSymbol,
  }) async {
    final doc = pw.Document();

    final sym = _pickSymbol(s.currencySymbol, fallbackSymbol);

    String money(num v) => _formatMoney(v, sym);

    final totalTax = s.itemTaxTotal + s.shippingTaxTotal;

    final couponCode = (s.couponCode ?? '').trim();
    final discount = s.couponDiscount ?? 0.0;
    final showCoupon = couponCode.isNotEmpty; // ✅ show even if 0

    pw.Widget row(String l, String r, {bool bold = false}) {
      final style = pw.TextStyle(
        fontSize: 12,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      );
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(l, style: style),
          pw.Text(r, style: style),
        ],
      );
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (_) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "INVOICE",
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text("Order: #${s.orderId}"),
              pw.Text(
                "Date: ${((s.orderDate ?? '').trim().isEmpty) ? '-' : s.orderDate}",
              ),
              pw.SizedBox(height: 18),

              pw.Text(
                "Items",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),

              pw.Table.fromTextArray(
                headers: const ["Item", "Qty", "Unit", "Total"],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellStyle: const pw.TextStyle(fontSize: 11),
                data: s.lines.map((l) {
                  final name = ((l.itemName ?? '').trim().isEmpty)
                      ? 'Item #${l.itemId}'
                      : l.itemName!.trim();

                  // ✅ if your API unitPrice is original price but lineSubtotal is sale,
                  // you can compute effective unit like the UI:
                  final effectiveUnit = (l.quantity <= 0)
                      ? l.unitPrice
                      : (l.lineSubtotal / l.quantity);

                  return [
                    name,
                    l.quantity.toString(),
                    money(effectiveUnit),
                    money(l.lineSubtotal),
                  ];
                }).toList(),
              ),

              pw.SizedBox(height: 18),

              row("Subtotal", money(s.itemsSubtotal)),
              row("Shipping", money(s.shippingTotal)),
              row("Tax", money(totalTax)),
              if (showCoupon)
                row("Coupon ($couponCode)", "-${money(discount)}"),

              pw.Divider(),
              row("Grand Total", money(s.grandTotal), bold: true),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static String _pickSymbol(String? fromOrder, String? fallback) {
    final a = (fromOrder ?? '').trim();
    if (a.isNotEmpty) return a;

    final b = (fallback ?? '').trim();
    if (b.isNotEmpty) return b;

    return '\$';
  }

  static String _formatMoney(num v, String symbol) {
    // Keep it simple and consistent: "LBP 12,000.00" style not needed unless you want separators.
    // If you want thousands separators later, we can add intl formatting.
    final value = v.toDouble().toStringAsFixed(2);
    return '$symbol$value';
  }
}
