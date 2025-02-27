import 'package:eshop_pro/data/models/seller.dart';
import 'package:eshop_pro/data/repositories/sellerRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BestSellersState {}

class BestSellersInitial extends BestSellersState {}

class BestSellersFetchInProgress extends BestSellersState {}

class BestSellersFetchSuccess extends BestSellersState {
  final List<Seller> sellers;

  BestSellersFetchSuccess({
    required this.sellers,
  });
}

class BestSellersFetchFailure extends BestSellersState {
  final String errorMessage;

  BestSellersFetchFailure(this.errorMessage);
}

class BestSellersCubit extends Cubit<BestSellersState> {
  final SellerRepository _sellerRepository = SellerRepository();

  BestSellersCubit() : super(BestSellersInitial());

  void getBestSellers({required int storeId}) async {
    emit(BestSellersFetchInProgress());
    try {
      List<Seller> sellers =
          await _sellerRepository.getBestSellers(storeId: storeId);

      emit(BestSellersFetchSuccess(sellers: sellers));
    } catch (e) {
      emit(BestSellersFetchFailure(e.toString()));
    }
  }
}
