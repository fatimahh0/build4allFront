import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/list_shipping_methods.dart';
import '../../domain/usecases/create_shipping_method.dart';
import '../../domain/usecases/update_shipping_method.dart';
import '../../domain/usecases/delete_shipping_method.dart';
import 'shipping_methods_event.dart';
import 'shipping_methods_state.dart';

class ShippingMethodsBloc
    extends Bloc<ShippingMethodsEvent, ShippingMethodsState> {
  final ListShippingMethods listMethods;
  final CreateShippingMethod createMethod;
  final UpdateShippingMethod updateMethod;
  final DeleteShippingMethod deleteMethod;

  ShippingMethodsBloc({
    required this.listMethods,
    required this.createMethod,
    required this.updateMethod,
    required this.deleteMethod,
  }) : super(const ShippingMethodsState()) {
    on<LoadShippingMethods>(_onLoad);
    on<CreateShippingMethodEvent>(_onCreate);
    on<UpdateShippingMethodEvent>(_onUpdate);
    on<DeleteShippingMethodEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadShippingMethods e,
    Emitter<ShippingMethodsState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final methods = await listMethods(
        ownerProjectId: e.ownerProjectId,
        authToken: e.token,
      );
      emit(state.copyWith(loading: false, methods: methods));
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }

  Future<void> _onCreate(
    CreateShippingMethodEvent e,
    Emitter<ShippingMethodsState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await createMethod(body: e.body, authToken: e.token);
      final methods = await listMethods(
        ownerProjectId: e.ownerProjectId,
        authToken: e.token,
      );
      emit(state.copyWith(loading: false, methods: methods));
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }

  Future<void> _onUpdate(
    UpdateShippingMethodEvent e,
    Emitter<ShippingMethodsState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await updateMethod(id: e.id, body: e.body, authToken: e.token);
      final methods = await listMethods(
        ownerProjectId: e.ownerProjectId,
        authToken: e.token,
      );
      emit(state.copyWith(loading: false, methods: methods));
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteShippingMethodEvent e,
    Emitter<ShippingMethodsState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await deleteMethod(id: e.id, authToken: e.token);
      final methods = await listMethods(
        ownerProjectId: e.ownerProjectId,
        authToken: e.token,
      );
      emit(state.copyWith(loading: false, methods: methods));
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }
}
