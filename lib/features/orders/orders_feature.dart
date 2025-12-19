import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/config/app_config.dart';

import 'domain/repositories/orders_repository.dart';
import 'domain/usecases/get_my_orders.dart';
import 'presentation/bloc/orders_bloc.dart';
import 'presentation/screens/my_orders_screen.dart';

class OrdersFeature extends StatelessWidget {
  final AppConfig appConfig;
  const OrdersFeature({super.key, required this.appConfig});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<OrdersRepository>();

    return BlocProvider(
      create: (_) => OrdersBloc(getMyOrders: GetMyOrders(repo)),
      child: const MyOrdersScreen(),
    );
  }
}
