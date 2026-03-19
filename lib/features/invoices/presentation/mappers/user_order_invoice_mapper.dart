import '../../domain/entities/invoice_data.dart';

class UserOrderInvoiceMapper {
  static InvoiceData fromRaw({
    required Map<String, dynamic> order,
    required List<Map<String, dynamic>> items,
  }) {
    double toDouble(dynamic v, {double fallback = 0}) {
      if (v == null) return fallback;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.trim()) ?? fallback;
      return fallback;
    }

    int toInt(dynamic v, {int fallback = 0}) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v.trim()) ?? fallback;
      return fallback;
    }

    String s(dynamic v) => (v ?? '').toString().trim();

    final payment = (order['payment'] is Map)
        ? (order['payment'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    String resolveCustomerName() {
      final shippingName = s(order['shippingFullName']);
      if (shippingName.isNotEmpty) return shippingName;

      final customerName = s(order['customerName']);
      if (customerName.isNotEmpty) return customerName;

      final username = s(order['customerUsername']);
      if (username.isNotEmpty) return username;

      for (final row in items) {
        final user = (row['user'] is Map)
            ? (row['user'] as Map).cast<String, dynamic>()
            : <String, dynamic>{};

        final first = s(user['firstName']);
        final last = s(user['lastName']);
        final uname = s(user['username']);

        final full = '$first $last'.trim();
        if (full.isNotEmpty) return full;
        if (uname.isNotEmpty) return uname;
      }

      return '';
    }

    String resolveCustomerPhone() {
      final shippingPhone = s(order['shippingPhone']);
      if (shippingPhone.isNotEmpty) return shippingPhone;

      final customerPhone = s(order['customerPhone']);
      if (customerPhone.isNotEmpty) return customerPhone;

      for (final row in items) {
        final user = (row['user'] is Map)
            ? (row['user'] as Map).cast<String, dynamic>()
            : <String, dynamic>{};

        final p = s(user['phoneNumber']);
        if (p.isNotEmpty) return p;
      }

      return '';
    }

    String resolveCustomerEmail() {
      final customerEmail = s(order['customerEmail']);
      if (customerEmail.isNotEmpty) return customerEmail;

      for (final row in items) {
        final user = (row['user'] is Map)
            ? (row['user'] as Map).cast<String, dynamic>()
            : <String, dynamic>{};

        final email = s(user['email']);
        if (email.isNotEmpty) return email;
      }

      return '';
    }

    final lines = items.map((row) {
      final item = (row['item'] is Map)
          ? (row['item'] as Map).cast<String, dynamic>()
          : <String, dynamic>{};

      final qty = toInt(row['quantity']);
      final unit = toDouble(
        row['unitPrice'],
        fallback: toDouble(row['price']),
      );
      final lineTotal = toDouble(
        row['lineTotal'],
        fallback: unit * qty,
      );

      return InvoiceLineData(
        itemName: s(item['itemName']).isNotEmpty ? s(item['itemName']) : 'Item',
        quantity: qty,
        unitPrice: unit,
        lineSubtotal: lineTotal,
      );
    }).toList();

    final computedItemsSubtotal = lines.fold<double>(
      0,
      (sum, e) => sum + e.lineSubtotal,
    );

    final itemsSubtotal = toDouble(
      order['itemsSubtotal'],
      fallback: computedItemsSubtotal,
    );

    final shippingTotal = toDouble(order['shippingTotal']);
    final itemTaxTotal = toDouble(order['itemTaxTotal']);
    final shippingTaxTotal = toDouble(order['shippingTaxTotal']);
    final couponDiscount = toDouble(order['couponDiscount']);

    final grandTotal = toDouble(
      order['grandTotal'],
      fallback: toDouble(
        order['totalPrice'],
        fallback: itemsSubtotal +
            shippingTotal +
            itemTaxTotal +
            shippingTaxTotal -
            couponDiscount,
      ),
    );

    return InvoiceData(
      orderId: toInt(
        order['id'],
        fallback: toInt(order['orderId']),
      ),
      orderCode: s(order['orderCode']),
      orderDateText: s(order['orderDate']),
      currencySymbol: s(order['currencySymbol']),
      paymentProvider: s(order['paymentProviderCode']).isNotEmpty
          ? s(order['paymentProviderCode'])
          : s(order['paymentMethod']),
      paymentStatus: s(order['paymentStatus']).isNotEmpty
          ? s(order['paymentStatus'])
          : s(payment['paymentState']),
      providerReference: s(order['providerPaymentId']),
      paymentMethod: s(order['paymentMethod']),
      customerName: resolveCustomerName(),
      customerPhone: resolveCustomerPhone(),
      customerEmail: resolveCustomerEmail(),
      addressLine: s(order['shippingAddress']),
      city: s(order['shippingCity']),
      postalCode: s(order['shippingPostalCode']),
      shippingMethodName: s(order['shippingMethodName']),
      itemsSubtotal: itemsSubtotal,
      shippingTotal: shippingTotal,
      itemTaxTotal: itemTaxTotal,
      shippingTaxTotal: shippingTaxTotal,
      couponCode: s(order['couponCode']),
      couponDiscount: couponDiscount,
      grandTotal: grandTotal,
      lines: lines,
    );
  }
}