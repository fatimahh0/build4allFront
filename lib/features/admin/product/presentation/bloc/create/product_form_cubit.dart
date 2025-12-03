import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/features/admin/product/domain/entities/product.dart';
import 'package:build4front/features/admin/product/domain/usecases/create_product.dart';
import 'product_form_state.dart';

class ProductFormCubit extends Cubit<ProductFormState> {
  final CreateProduct createProduct;

  ProductFormCubit({required this.createProduct})
    : super(ProductFormState.initial());

  Future<void> submit({
    required int ownerProjectId,
    required int itemTypeId,
    required int? currencyId,
    required String name,
    String? description,
    required double price,
    int? stock,
    String? status,
    String? imageUrl,
    String? sku,
  }) async {
    emit(state.copyWith(isSubmitting: true, error: null));

    try {
      final Product p = await createProduct(
        ownerProjectId: ownerProjectId,
        itemTypeId: itemTypeId,
        currencyId: currencyId,
        name: name,
        description: description,
        price: price,
        stock: stock,
        status: status,
        imageUrl: imageUrl,
        sku: sku,
      );

      emit(state.copyWith(isSubmitting: false, createdProduct: p, error: null));
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          createdProduct: null,
          error: e.toString(),
        ),
      );
    }
  }
}
