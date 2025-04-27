import 'package:eshop_pro/data/models/product.dart';
import 'package:eshop_pro/data/repositories/productRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MostSellingProductsState {}

class MostSellingProductsInitial extends MostSellingProductsState {}

class MostSellingProductsFetchInProgress extends MostSellingProductsState {}

class MostSellingProductsFetchSuccess extends MostSellingProductsState {
  final List<Product> products;

  MostSellingProductsFetchSuccess({
    required this.products,
  });
}

class MostSellingProductsFetchFailure extends MostSellingProductsState {
  final String errorMessage;

  MostSellingProductsFetchFailure(this.errorMessage);
}

class MostSellingProductsCubit extends Cubit<MostSellingProductsState> {
  final ProductRepository productRepository;

  MostSellingProductsCubit(this.productRepository)
      : super(MostSellingProductsInitial()) {
    productRepository.productStream.listen((products) {
      // Update the state when products change
      emit(MostSellingProductsFetchSuccess(products: products));
    });
  }

  void getMostSellingProducts(
      {required int storeId, required int userId, String? zipcode}) async {
    emit(MostSellingProductsFetchInProgress());
    try {
      final result = await productRepository.getMostSellingProducts(
          storeId: storeId, userId: userId, zipcode: zipcode);
      emit(MostSellingProductsFetchSuccess(products: result));
    } catch (e) {
      emit(MostSellingProductsFetchFailure(e.toString()));
    }
  }
}
