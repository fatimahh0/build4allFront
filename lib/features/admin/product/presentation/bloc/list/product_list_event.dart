import 'package:equatable/equatable.dart';

abstract class ProductListEvent extends Equatable {
  const ProductListEvent();
  @override
  List<Object?> get props => [];
}

class LoadProductsForOwner extends ProductListEvent {
  final int ownerProjectId;
  final int? itemTypeId;
  final int? categoryId;

  const LoadProductsForOwner(
    this.ownerProjectId, {
    this.itemTypeId,
    this.categoryId,
  });

  @override
  List<Object?> get props => [ownerProjectId, itemTypeId, categoryId];
}
