part of 'item_details_bloc.dart';

class ItemDetailsState extends Equatable {
  final bool isLoading;
  final ItemDetails? details;
  final String? error;

  const ItemDetailsState({this.isLoading = false, this.details, this.error});

  ItemDetailsState copyWith({
    bool? isLoading,
    ItemDetails? details,
    String? error,
  }) {
    return ItemDetailsState(
      isLoading: isLoading ?? this.isLoading,
      details: details ?? this.details,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, details, error];
}
