abstract class ShippingMethodsEvent {}

class LoadShippingMethods extends ShippingMethodsEvent {
  final String token;
  LoadShippingMethods({required this.token});
}

class CreateShippingMethodEvent extends ShippingMethodsEvent {
  final Map<String, dynamic> body;
  final String token;

  CreateShippingMethodEvent({
    required this.body,
    required this.token,
  });
}

class UpdateShippingMethodEvent extends ShippingMethodsEvent {
  final int id;
  final Map<String, dynamic> body;
  final String token;

  UpdateShippingMethodEvent({
    required this.id,
    required this.body,
    required this.token,
  });
}

class DeleteShippingMethodEvent extends ShippingMethodsEvent {
  final int id;
  final String token;

  DeleteShippingMethodEvent({
    required this.id,
    required this.token,
  });
}
