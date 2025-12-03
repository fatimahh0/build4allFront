import 'package:equatable/equatable.dart';

abstract class ProductListEvent extends Equatable {
  const ProductListEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductsForOwner extends ProductListEvent {
  final int ownerProjectId;

  const LoadProductsForOwner(this.ownerProjectId);

  @override
  List<Object?> get props => [ownerProjectId];
}
