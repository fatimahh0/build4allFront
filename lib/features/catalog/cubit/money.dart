import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:build4front/features/catalog/cubit/currency_cubit.dart';

String money(
  BuildContext context,
  num value, {
  String? symbolFromApi,
  int decimals = 2,
}) {
  final apiSym = (symbolFromApi ?? '').trim();
  final amount = value.toDouble().toStringAsFixed(decimals);

  // ✅ If admin/user passed symbol from API/cache → use it immediately
  if (apiSym.isNotEmpty) return '$apiSym$amount';

  // ✅ Safe: CurrencyCubit might not exist in this widget tree (admin screens)
  try {
    final sym = context.select((CurrencyCubit c) => c.symbol).trim();
    if (sym.isNotEmpty) return '$sym$amount';
  } catch (_) {
    // CurrencyCubit not provided above this context -> ignore
  }

  // last resort fallback
  return '\$$amount';
}
