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

  /// ✅ Fix:
  /// - Allows clearing createdProduct intentionally
  /// - Allows clearing error intentionally
  /// - Preserves previous error if not provided
  ProductFormState copyWith({
    bool? isSubmitting,
    Product? createdProduct,
    bool clearCreatedProduct = false,
    String? error,
    bool clearError = false,
  }) {
    return ProductFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      createdProduct: clearCreatedProduct
          ? null
          : (createdProduct ?? this.createdProduct),
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get success => createdProduct != null && error == null;

  @override
  List<Object?> get props => [isSubmitting, createdProduct, error];
}
