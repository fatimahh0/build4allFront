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
  if (apiSym.isNotEmpty) {
    return '$apiSym${value.toDouble().toStringAsFixed(decimals)}';
  }

  //  select() makes UI rebuild when currency changes
  final sym = context.select((CurrencyCubit c) => c.symbol).trim();

  final amount = value.toDouble().toStringAsFixed(decimals);
  if (sym.isNotEmpty) return '$sym$amount';

  // last resort fallback
  return '\$$amount';
}
