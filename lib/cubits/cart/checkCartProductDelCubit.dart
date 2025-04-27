import 'package:eshop_pro/data/repositories/cartRepository.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CheckCartProductDeliverabilityState {}

class CheckCartProductDeliverabilityInitial
    extends CheckCartProductDeliverabilityState {}

class CheckCartProductDeliverabilityInProgress
    extends CheckCartProductDeliverabilityState {}

class CheckCartProductDeliverabilitySuccess
    extends CheckCartProductDeliverabilityState {
  final String successMessage;
  CheckCartProductDeliverabilitySuccess({required this.successMessage});
}

class CheckCartProductDeliverabilityFailure
    extends CheckCartProductDeliverabilityState {
  final String errorMessage;
  final List<Map<String, dynamic>>? errorData;
  CheckCartProductDeliverabilityFailure(this.errorMessage, this.errorData);
}

class CheckCartProductDeliverabilityCubit
    extends Cubit<CheckCartProductDeliverabilityState> {
  final CartRepository _cartRepository = CartRepository();

  CheckCartProductDeliverabilityCubit()
      : super(CheckCartProductDeliverabilityInitial());

  void checkDeliverability({required int storeId, required int addressId}) {
    emit(CheckCartProductDeliverabilityInProgress());

    _cartRepository
        .checkDeliverability(storeId: storeId, addressId: addressId)
        .then((value) =>
            emit(CheckCartProductDeliverabilitySuccess(successMessage: value)))
        .catchError((e) {
      emit(CheckCartProductDeliverabilityFailure(e.toString(), e.errorData));
    });
  }
}
