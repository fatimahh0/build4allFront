// lib/features/admin/product/presentation/screens/admin_products_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';
import 'package:build4front/features/auth/data/services/admin_token_store.dart';

import '../../data/repositories/product_repository_impl.dart';
import '../../data/services/product_api_service.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/entities/product.dart';

import '../bloc/list/product_list_bloc.dart';
import '../bloc/list/product_list_event.dart';
import '../bloc/list/product_list_state.dart';

import '../widgets/admin_product_card.dart';
import 'admin_create_product_screen.dart';

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

class _AdminProductsListView extends StatefulWidget {
  final int ownerProjectId;
  const _AdminProductsListView({required this.ownerProjectId});

  @override
  State<_AdminProductsListView> createState() => _AdminProductsListViewState();
}

class _AdminProductsListViewState extends State<_AdminProductsListView> {
  String _searchQuery = '';
  String _typeFilter = 'ALL';

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

      if (context.mounted) {
        Navigator.of(context).pop(); // close loader
        context.read<ProductListBloc>().add(
          LoadProductsForOwner(widget.ownerProjectId),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete product: $e')));
      }
    }
  }

  List<Product> _applyFilters(ProductListState state) {
    var list = state.products;

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((p) {
        final name = p.name.toLowerCase();
        final sku = (p.sku ?? '').toLowerCase();
        return name.contains(q) || sku.contains(q);
      }).toList();
    }

    if (_typeFilter != 'ALL') {
      list = list
          .where((p) => (p.productType).toUpperCase() == _typeFilter)
          .toList();
    }

    return list;
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
              builder: (_) => AdminCreateProductScreen(
                ownerProjectId: widget.ownerProjectId,
              ),
            ),
          );

          if (changed == true && context.mounted) {
            context.read<ProductListBloc>().add(
              LoadProductsForOwner(widget.ownerProjectId),
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

            final filtered = _applyFilters(state);
            final width = MediaQuery.of(context).size.width;
            final crossAxisCount = width >= 1100
                ? 5
                : width >= 900
                ? 4
                : width >= 600
                ? 3
                : 2;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Header row: search + filter + count ----
                _AdminProductsHeaderBar(
                  tokens: tokens,
                  l10n: l10n,
                  totalCount: state.products.length,
                  filteredCount: filtered.length,
                  searchQuery: _searchQuery,
                  onSearchChanged: (val) {
                    setState(() => _searchQuery = val);
                  },
                  typeFilter: _typeFilter,
                  onTypeFilterChanged: (val) {
                    setState(() => _typeFilter = val);
                  },
                ),
                SizedBox(height: spacing.md),

                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.70,
                      crossAxisSpacing: spacing.md,
                      mainAxisSpacing: spacing.md,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      return AdminProductCard(
                        product: product,
                        onEdit: () async {
                          final changed = await Navigator.of(context)
                              .push<bool>(
                                MaterialPageRoute(
                                  builder: (_) => AdminCreateProductScreen(
                                    ownerProjectId: widget.ownerProjectId,
                                    categoryId: product.categoryId,
                                    itemTypeId: product.itemTypeId,
                                    currencyId: product.currencyId,
                                    initialProduct: product,
                                  ),
                                ),
                              );

                          if (changed == true && context.mounted) {
                            context.read<ProductListBloc>().add(
                              LoadProductsForOwner(widget.ownerProjectId),
                            );
                          }
                        },
                        onDelete: () => _confirmDelete(context, product),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AdminProductsHeaderBar extends StatelessWidget {
  final dynamic tokens;
  final AppLocalizations l10n;
  final int totalCount;
  final int filteredCount;

  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  /// 'ALL', 'SIMPLE', 'VARIABLE', 'GROUPED', 'EXTERNAL'
  final String typeFilter;
  final ValueChanged<String> onTypeFilterChanged;

  const _AdminProductsHeaderBar({
    required this.tokens,
    required this.l10n,
    required this.totalCount,
    required this.filteredCount,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.typeFilter,
    required this.onTypeFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = tokens.colors;
    final spacing = tokens.spacing;
    final text = tokens.typography;

    return Container(
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(tokens.card.radius),
        border: Border.all(color: c.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: c.label.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: title + count
          Row(
            children: [
              Icon(Icons.inventory_2_outlined, color: c.primary),
              SizedBox(width: spacing.sm),
              Text(
                l10n.adminProductsTitle,
                style: text.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: c.label,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: c.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '$filteredCount / $totalCount',
                  style: text.bodySmall.copyWith(color: c.primary),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),

          // Second row: search + type filter
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: l10n.adminProductsSearchHint,
                  ),
                  onChanged: onSearchChanged,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: c.background,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: c.border.withOpacity(0.4)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: typeFilter,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          value: 'ALL',
                          child: Text(l10n.adminProductsFilterAll),
                        ),
                        DropdownMenuItem(
                          value: 'SIMPLE',
                          child: Text(l10n.adminProductTypeSimple),
                        ),
                        DropdownMenuItem(
                          value: 'VARIABLE',
                          child: Text(l10n.adminProductTypeVariable),
                        ),
                        DropdownMenuItem(
                          value: 'GROUPED',
                          child: Text(l10n.adminProductTypeGrouped),
                        ),
                        DropdownMenuItem(
                          value: 'EXTERNAL',
                          child: Text(l10n.adminProductTypeExternal),
                        ),
                      ],
                      onChanged: (val) {
                        if (val == null) return;
                        onTypeFilterChanged(val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
