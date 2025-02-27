import 'package:eshop_pro/data/repositories/sellerRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/seller.dart';

abstract class FeaturedSellerState {}

class FeaturedSellerInitial extends FeaturedSellerState {}

class FeaturedSellerFetchInProgress extends FeaturedSellerState {}

class FeaturedSellerFetchSuccess extends FeaturedSellerState {
  final List<Seller> topSellers;

  FeaturedSellerFetchSuccess(this.topSellers);
}

class FeaturedSellerFetchFailure extends FeaturedSellerState {
  final String errorMessage;

  FeaturedSellerFetchFailure(this.errorMessage);
}

class FeaturedSellerCubit extends Cubit<FeaturedSellerState> {
  final SellerRepository _sellerRepository = SellerRepository();

  FeaturedSellerCubit() : super(FeaturedSellerInitial());

  void fetchFeaturedSellers({required int storeId}) {
    emit(FeaturedSellerFetchInProgress());

    _sellerRepository
        .getFeaturedSellers(storeId: storeId)
        .then((value) => emit(FeaturedSellerFetchSuccess(value)))
        .catchError((e) {
      emit(FeaturedSellerFetchFailure(e.toString()));
    });
  }
}
