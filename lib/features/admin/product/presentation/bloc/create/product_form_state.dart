import 'package:equatable/equatable.dart';
import 'package:build4front/features/admin/product/domain/entities/product.dart';

class ProductFormState extends Equatable {
  final bool isSubmitting;
  final Product? createdProduct;
  final String? error;

  const ProductFormState({
    required this.isSubmitting,
    this.createdProduct,
    this.error,
  });

  factory ProductFormState.initial() {
    return const ProductFormState(
      isSubmitting: false,
      createdProduct: null,
      error: null,
    );
  }

  ProductFormState copyWith({
    bool? isSubmitting,
    Product? createdProduct,
    String? error,
  }) {
    return ProductFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      createdProduct: createdProduct ?? this.createdProduct,
      error: error,
    );
  }

  bool get success => createdProduct != null && error == null;

  @override
  List<Object?> get props => [isSubmitting, createdProduct, error];
}
