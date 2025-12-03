import 'package:equatable/equatable.dart';
import 'package:build4front/features/admin/product/domain/entities/product.dart';

class ProductListState extends Equatable {
  final bool isLoading;
  final List<Product> products;
  final String? error;

  const ProductListState({
    required this.isLoading,
    required this.products,
    this.error,
  });

  factory ProductListState.initial() =>
      const ProductListState(isLoading: false, products: []);

  ProductListState copyWith({
    bool? isLoading,
    List<Product>? products,
    String? error,
  }) {
    return ProductListState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, products, error];
}
