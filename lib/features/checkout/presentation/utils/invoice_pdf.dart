import 'dart:typed_data';
import 'package:build4front/features/checkout/data/models/checkout_summary_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class InvoicePdf {
  static Future<Uint8List> build(CheckoutSummaryModel s) async {
    final doc = pw.Document();

    String money(double v) => "${s.currencySymbol}${v.toStringAsFixed(2)}";
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
              pw.Text("Date: ${s.orderDate ?? '-'}"),
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
                      : l.itemName!;
                  return [
                    name,
                    l.quantity.toString(),
                    money(l.unitPrice),
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
}
