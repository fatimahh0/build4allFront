class SaleUtils {
  static DateTime? parseDt(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse('$v');
  }

  static num? parseNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse('$v');
  }

  static int? parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v');
  }

  /// Sale is ACTIVE only if now is inside [saleStart, saleEnd]
  /// - if both null => NOT active (safer)
  /// - if only start => active if now >= start
  /// - if only end => active if now <= end
  static bool isSaleActiveNow(DateTime? saleStart, DateTime? saleEnd) {
    final now = DateTime.now();
    if (saleStart == null && saleEnd == null) return false;

    if (saleStart != null && saleEnd == null) return !now.isBefore(saleStart);
    if (saleStart == null && saleEnd != null) return !now.isAfter(saleEnd);

    return !now.isBefore(saleStart!) && !now.isAfter(saleEnd!);
  }

  /// Compute a clean "onSale" that respects the date window AND requires salePrice.
  /// If backend sends onSale, we still enforce date window.
  static bool computeOnSale({
    required num? salePrice,
    required DateTime? saleStart,
    required DateTime? saleEnd,
    bool? backendOnSale,
  }) {
    if (salePrice == null) return false;
    final activeByDate = isSaleActiveNow(saleStart, saleEnd);
    if (!activeByDate) return false;

    // If backend provided onSale, respect it too (but date is enforced above)
    if (backendOnSale != null && backendOnSale == false) return false;

    return true;
  }

  static num? computeEffectivePrice({
    required bool onSale,
    required num? backendEffectivePrice,
    required num? salePrice,
  }) {
    if (!onSale) return null;
    return backendEffectivePrice ?? salePrice;
  }

  static int? percentOff(num? original, num? effective) {
    if (original == null || effective == null) return null;
    if (original <= 0) return null;
    final p = ((1 - (effective / original)) * 100).round();
    if (p <= 0) return null;
    return p;
  }
}
