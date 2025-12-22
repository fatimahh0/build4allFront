import 'package:build4front/features/admin/orders_admin/data/repository/admin_orders_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'data/services/admin_orders_api_service.dart';
import 'domain/repositories/admin_orders_repository.dart';
import 'presentation/bloc/admin_orders_bloc.dart';
import 'presentation/bloc/admin_orders_event.dart';
import 'presentation/screens/admin_orders_screen.dart';

class OrdersAdminFeature extends StatelessWidget {
  final Future<String?> Function() getToken;

  const OrdersAdminFeature({super.key, required this.getToken});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AdminOrdersRepository>(
      create: (_) => AdminOrdersRepositoryImpl(
        api: AdminOrdersApiService(getToken: getToken),
      ),
      child: BlocProvider(
        create: (ctx) =>
            AdminOrdersBloc(repo: ctx.read<AdminOrdersRepository>())
              ..add(const AdminOrdersStarted()),
        child: const AdminOrdersScreen(),
      ),
    );
  }
}
