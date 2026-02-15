class CheckoutBlockedFailure implements Exception {
  final String message;
  final List<String> blockingErrors;
  final List<Map<String, dynamic>> lineErrors;

  CheckoutBlockedFailure({
    required this.message,
    required this.blockingErrors,
    required this.lineErrors,
  });

  @override
  String toString() => message;
}
