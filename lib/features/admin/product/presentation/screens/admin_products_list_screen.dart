import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';

// Domain + data
import 'package:build4front/features/admin/product/domain/usecases/get_products.dart';
import 'package:build4front/features/admin/product/data/repositories/product_repository_impl.dart';
import 'package:build4front/features/admin/product/data/services/product_api_service.dart';
import 'package:build4front/features/admin/product/domain/entities/product.dart';

// Admin token (for auth)
import 'package:build4front/features/auth/data/services/admin_token_store.dart';

// UI
import 'package:build4front/features/admin/product/presentation/widgets/admin_product_card.dart';
import 'package:build4front/features/admin/product/presentation/screens/admin_create_product_screen.dart';

// Bloc
import 'package:build4front/features/admin/product/presentation/bloc/list/product_list_bloc.dart';
import 'package:build4front/features/admin/product/presentation/bloc/list/product_list_event.dart';
import 'package:build4front/features/admin/product/presentation/bloc/list/product_list_state.dart';

class AdminProductsListScreen extends StatelessWidget {
  final int ownerProjectId;

  const AdminProductsListScreen({super.key, required this.ownerProjectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductListBloc>(
      create: (_) => ProductListBloc(
        getProducts: GetProducts(
          ProductRepositoryImpl(
            api: ProductApiService(),
            getToken: AdminTokenStore().getToken,
          ),
        ),
      )..add(LoadProductsForOwner(ownerProjectId)),
      child: _AdminProductsListView(ownerProjectId: ownerProjectId),
    );
  }
}

class _AdminProductsListView extends StatelessWidget {
  final int ownerProjectId;

  const _AdminProductsListView({required this.ownerProjectId});

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final tokens = context.read<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final text = tokens.typography;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete product'),
        content: Text(
          'Are you sure you want to delete "${product.name}"?',
          style: text.bodyMedium.copyWith(color: colors.label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete', style: TextStyle(color: colors.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Progress dialog while deleting
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final token = await AdminTokenStore().getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Missing admin token – please log in again.');
      }

      final api = ProductApiService();
      await api.delete(id: product.id, authToken: token);

      // Close progress dialog
      Navigator.of(context).pop();

      if (context.mounted) {
        // Reload list
        context.read<ProductListBloc>().add(
          LoadProductsForOwner(ownerProjectId),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // close progress

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete product: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final text = tokens.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Text(
          l10n.adminProductsTitle,
          style: text.titleMedium.copyWith(
            color: colors.label,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final changed = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) =>
                  AdminCreateProductScreen(ownerProjectId: ownerProjectId),
            ),
          );

          if (changed == true && context.mounted) {
            context.read<ProductListBloc>().add(
              LoadProductsForOwner(ownerProjectId),
            );
          }
        },
        backgroundColor: colors.primary,
        child: Icon(Icons.add, color: colors.onPrimary),
      ),
      body: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: BlocBuilder<ProductListBloc, ProductListState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(
                child: Text(
                  state.error!,
                  style: text.bodyMedium.copyWith(color: colors.danger),
                ),
              );
            }

            if (state.products.isEmpty) {
              return Center(
                child: Text(
                  l10n.adminProductsEmpty,
                  style: text.bodyMedium.copyWith(color: colors.body),
                ),
              );
            }

            final width = MediaQuery.of(context).size.width;
            final crossAxisCount = width >= 900
                ? 4
                : width >= 600
                ? 3
                : 2;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.70,
                crossAxisSpacing: spacing.md,
                mainAxisSpacing: spacing.md,
              ),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                return AdminProductCard(
                  product: product,
                  onEdit: () async {
                    final changed = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => AdminCreateProductScreen(
                          ownerProjectId: ownerProjectId,
                          categoryId: product.categoryId,
                          itemTypeId: product.itemTypeId,
                          currencyId: null, // use Env or AUP config
                          initialProduct: product,
                        ),
                      ),
                    );

                    if (changed == true && context.mounted) {
                      context.read<ProductListBloc>().add(
                        LoadProductsForOwner(ownerProjectId),
                      );
                    }
                  },
                  onDelete: () => _confirmDelete(context, product),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
