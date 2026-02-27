class PaymentSummary {
  final double orderTotal;
  final double paidAmount;
  final double remainingAmount;
  final bool fullyPaid;
  final String paymentState; // UNPAID / PARTIAL / PAID ...

  const PaymentSummary({
    required this.orderTotal,
    required this.paidAmount,
    required this.remainingAmount,
    required this.fullyPaid,
    required this.paymentState,
  });
}

class OrderCard {
  final int orderId;
  final DateTime? orderDate;

  final String orderStatus; // raw: PENDING
  final String? orderStatusUi; // pretty: Pending

  final int itemsCount; // total qty
  final int linesCount; // number of lines

  final double totalPrice;

  final String? previewItemName;
  final String? previewImageUrl;

  final bool fullyPaid;
  final PaymentSummary? payment;

  const OrderCard({
    required this.orderId,
    required this.orderStatus,
    required this.totalPrice,
    required this.itemsCount,
    required this.linesCount,
    required this.fullyPaid,
    this.payment,
    this.orderDate,
    this.orderStatusUi,
    this.previewItemName,
    this.previewImageUrl,
  });
}