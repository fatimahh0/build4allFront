import 'package:build4front/features/catalog/cubit/currency_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


String money(BuildContext context, double value, {String? symbolFromApi}) {
  final apiSym = (symbolFromApi ?? '').trim();
  if (apiSym.isNotEmpty) {
    return '$apiSym${value.toStringAsFixed(2)}';
  }

  final globalSym = context.read<CurrencyCubit>().symbol;
  if (globalSym.isNotEmpty) {
    return '$globalSym${value.toStringAsFixed(2)}';
  }

  return '\$${value.toStringAsFixed(2)}'; // last-resort fallback only
}
