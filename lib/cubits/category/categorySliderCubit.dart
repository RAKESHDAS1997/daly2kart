import 'package:eshop_pro/data/models/categorySlider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/categoryRepository.dart';

abstract class CategorySliderState {}

class CategorySliderInitial extends CategorySliderState {}

class CategorySliderFetchInProgress extends CategorySliderState {}

class CategorySliderFetchSuccess extends CategorySliderState {
  final List<CategorySlider> categorySlider;

  CategorySliderFetchSuccess(this.categorySlider);
}

class CategorySliderFetchFailure extends CategorySliderState {
  final String errorMessage;

  CategorySliderFetchFailure(this.errorMessage);
}

class CategorySliderCubit extends Cubit<CategorySliderState> {
  final CategoryRepository categoryRepository = CategoryRepository();
  CategorySliderCubit() : super(CategorySliderInitial());

  void getCategoriesSliders({required int storeId}) {
    emit(CategorySliderFetchInProgress());

    categoryRepository
        .getCategoriesSliders(storeId: storeId)
        .then((value) => emit(CategorySliderFetchSuccess(value)))
        .catchError((e) {
      emit(CategorySliderFetchFailure(e.toString()));
    });
  }
}
