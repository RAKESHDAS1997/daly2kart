import 'package:eshop_pro/data/repositories/productRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CheckProductDeliverabilityState {}

class CheckProductDeliverabilityInitial
    extends CheckProductDeliverabilityState {}

class CheckProductDeliverabilityFetchInProgress
    extends CheckProductDeliverabilityState {}

class CheckProductDeliverabilityFetchSuccess
    extends CheckProductDeliverabilityState {
  final String successMessage;
  CheckProductDeliverabilityFetchSuccess({required this.successMessage});
}

class CheckProductDeliverabilityFetchFailure
    extends CheckProductDeliverabilityState {
  final String errorMessage;

  CheckProductDeliverabilityFetchFailure(this.errorMessage);
}

class CheckProductDeliverabilityCubit
    extends Cubit<CheckProductDeliverabilityState> {
  final ProductRepository _productRepository = ProductRepository();

  CheckProductDeliverabilityCubit()
      : super(CheckProductDeliverabilityInitial());

  void checkProductDeliverability({required Map<String, dynamic> params}) {
    emit(CheckProductDeliverabilityFetchInProgress());
    _productRepository
        .checkProductDeliverability(params: params)
        .then((value) =>
            emit(CheckProductDeliverabilityFetchSuccess(successMessage: value)))
        .catchError((e) {
      emit(CheckProductDeliverabilityFetchFailure(e.toString()));
    });
  }
}
