import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/entities/invoice_data.dart';

class InvoicePdf {
  static Future<Uint8List> build(InvoiceData s, {String? title}) async {
    pw.ThemeData? theme;
    try {
      final base = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf'),
      );
      final bold = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoNaskhArabic-Bold.ttf'),
      );
      theme = pw.ThemeData.withFont(base: base, bold: bold);
    } catch (_) {
      theme = null;
    }

    final doc = pw.Document(theme: theme);

    final sym = _pickSymbol(s.currencySymbol);
    String money(num v) => _formatMoney(v, sym);

    final totalTax = s.itemTaxTotal + s.shippingTaxTotal;
    final showCoupon = s.couponCode.trim().isNotEmpty;

    final shownOrderCode = s.orderCode.trim().isNotEmpty
        ? s.orderCode.trim()
        : (s.providerReference.trim().isNotEmpty ? s.providerReference.trim() : '—');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (ctx) {
          final w = ctx.page.pageFormat.availableWidth;
          final leftW = w * 0.62;
          final rightW = w - leftW;

          pw.Widget kvLine(String k, String v, {bool bold = false}) {
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Table(
                columnWidths: const {
                  0: pw.FixedColumnWidth(95),
                  1: pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text(
                        k,
                        style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        v,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          pw.Widget totalsRow(String l, String r, {bool bold = false}) {
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    l,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                    ),
                  ),
                  pw.Text(
                    r,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Table(
                columnWidths: {
                  0: pw.FixedColumnWidth(leftW),
                  1: pw.FixedColumnWidth(rightW),
                },
                children: [
                  pw.TableRow(
                    verticalAlignment: pw.TableCellVerticalAlignment.top,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.only(right: 12),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              (title ?? 'INVOICE').toUpperCase(),
                              style: pw.TextStyle(
                                fontSize: 22,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            kvLine('Order', shownOrderCode, bold: true),
                            kvLine('Date', s.orderDateText.isEmpty ? '—' : s.orderDateText),
                            if (s.customerName.trim().isNotEmpty)
                              kvLine('Customer', s.customerName.trim()),
                            if (s.customerPhone.trim().isNotEmpty)
                              kvLine('Phone', s.customerPhone.trim()),
                            if (s.addressLine.trim().isNotEmpty)
                              kvLine('Address', s.addressLine.trim()),
                            if (s.city.trim().isNotEmpty)
                              kvLine('City', s.city.trim()),
                            if (s.postalCode.trim().isNotEmpty)
                              kvLine('Postal', s.postalCode.trim()),
                            if (s.shippingMethodName.trim().isNotEmpty)
                              kvLine('Shipping', s.shippingMethodName.trim()),
                          ],
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: pw.BorderRadius.circular(10),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            kvLine('Provider', s.paymentProvider.trim().isEmpty ? '—' : s.paymentProvider.trim()),
                            kvLine('Status', s.paymentStatus.trim().isEmpty ? '—' : s.paymentStatus.trim()),
                            kvLine('Method', s.paymentMethod.trim().isEmpty ? '—' : s.paymentMethod.trim()),
                            kvLine('Ref', s.providerReference.trim().isEmpty ? '—' : s.providerReference.trim()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 14),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),

              pw.Text(
                'Items',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),

              pw.Table.fromTextArray(
                headers: const ['Item', 'Qty', 'Unit', 'Total'],
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                cellStyle: const pw.TextStyle(fontSize: 10),
                columnWidths: const {
                  0: pw.FlexColumnWidth(3.2),
                  1: pw.FlexColumnWidth(0.8),
                  2: pw.FlexColumnWidth(1.2),
                  3: pw.FlexColumnWidth(1.2),
                },
                data: s.lines.map((l) {
                  return [
                    l.itemName.trim().isEmpty ? 'Item' : l.itemName.trim(),
                    l.quantity.toString(),
                    money(l.unitPrice),
                    money(l.lineSubtotal),
                  ];
                }).toList(),
              ),

              pw.SizedBox(height: 16),

              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  children: [
                    totalsRow('Subtotal', money(s.itemsSubtotal)),
                    totalsRow('Shipping', money(s.shippingTotal)),
                    totalsRow('Tax', money(totalTax)),
                    if (showCoupon)
                      totalsRow('Coupon (${s.couponCode.trim()})', '-${money(s.couponDiscount)}'),
                    pw.Divider(color: PdfColors.grey300),
                    totalsRow('Grand Total', money(s.grandTotal), bold: true),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static Future<void> share(InvoiceData data, {String? title}) async {
    final bytes = await build(data, title: title);
    final code = data.orderCode.trim();
    final fileName = code.isNotEmpty
        ? 'invoice-$code.pdf'
        : 'invoice-${data.orderId}.pdf';

    await Printing.sharePdf(
      bytes: bytes,
      filename: fileName,
    );
  }

  static String _pickSymbol(String? fromOrder) {
    final a = (fromOrder ?? '').trim();
    if (a.isNotEmpty) return a;
    return '\$';
  }

  static String _formatMoney(num v, String symbol) {
    final val = v.toDouble();
    final sign = val < 0 ? '-' : '';
    final abs = val.abs().toStringAsFixed(2);
    return '$sign$symbol$abs';
  }
}