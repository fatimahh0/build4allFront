part of 'item_details_bloc.dart';

abstract class ItemDetailsEvent extends Equatable {
  const ItemDetailsEvent();
  @override
  List<Object?> get props => [];
}

class ItemDetailsStarted extends ItemDetailsEvent {
  final int itemId;
  final String? token;
  const ItemDetailsStarted(this.itemId, {this.token});

  @override
  List<Object?> get props => [itemId, token];
}
