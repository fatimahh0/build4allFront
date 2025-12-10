import '../../domain/entities/shipping_method.dart';

class ShippingMethodsState {
  final bool loading;
  final String? error;
  final List<ShippingMethod> methods;

  const ShippingMethodsState({
    this.loading = false,
    this.error,
    this.methods = const [],
  });

  ShippingMethodsState copyWith({
    bool? loading,
    String? error,
    List<ShippingMethod>? methods,
  }) {
    return ShippingMethodsState(
      loading: loading ?? this.loading,
      error: error,
      methods: methods ?? this.methods,
    );
  }
}
