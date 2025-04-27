import 'package:eshop_pro/data/models/offerSlider.dart';
import 'package:eshop_pro/data/repositories/offerRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


abstract class OfferState {}

class OfferInitial extends OfferState {}

class OfferFetchInProgress extends OfferState {}

class OfferFetchSuccess extends OfferState {
  final List<OfferSlider> sliders;

  OfferFetchSuccess(this.sliders);
}

class OfferFetchFailure extends OfferState {
  final String errorMessage;

  OfferFetchFailure(this.errorMessage);
}

class OfferCubit extends Cubit<OfferState> {
  final OfferRepository _offerRepository = OfferRepository();

  OfferCubit() : super(OfferInitial());

  void getOfferSliders({required int storeId}) {
    emit(OfferFetchInProgress());

    _offerRepository
        .getOfferSliders(storeId: storeId)
        .then((value) => emit(OfferFetchSuccess(value)))
        .catchError((e) {
      emit(OfferFetchFailure(e.toString()));
    });
  }
}
