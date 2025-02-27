import 'package:eshop_pro/data/models/categorySlider.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/labelKeys.dart';

import '../../utils/api.dart';
import '../models/category.dart';

class CategoryRepository {
  Future<({List<Category> categories, int total})> getCategories(
      {required int storeId,
      int? offset,
      String? search,
      int? categoryId,
      String? categoryIds}) async {
    try {
      final result = await Api.get(
          url: Api.getCategories,
          useAuthToken: true,
          queryParameters: {
            Api.storeIdApiKey: storeId,
            Api.limitApiKey: limit,
            Api.offsetApiKey: offset ?? 0,
            if (categoryId != null) Api.idApiKey: categoryId,
            if (search != null) Api.searchApiKey: search,
            if (categoryIds != null) Api.idsApiKey: categoryIds
          });
      List<Category> categories = ((result['data'] ?? []) as List)
          .map((category) => Category.fromJson(Map.from(category ?? {})))
          .toList();
      List<Category> uniqueCategories =
          categories.toSet().toList().fold<List<Category>>([], (list, current) {
        if (!list.any((item) => item.id == current.id)) {
          list.add(current);
        }
        return list;
      });
      int difference = categories.length - uniqueCategories.length;
      return (
        categories: uniqueCategories,
        total: int.parse((result['total'] ?? 0).toString()) - difference,
      );
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString(),
            errorCode: e
                .errorCode); // Re-throw the API exception with the backend message
      } else {
        // Handle any other exceptions
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<List<CategorySlider>> getCategoriesSliders(
      {required int storeId}) async {
    try {
      final result = await Api.get(
          url: Api.getCategoriesSliders,
          useAuthToken: true,
          queryParameters: {Api.storeIdApiKey: storeId});

      return ((result['slider_images'] ?? []) as List)
          .where((slider) => slider != null && slider['status'] == 1)
          .map((slider) =>
              CategorySlider.fromJson(Map<String, dynamic>.from(slider)))
          .toList();
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString(),
            errorCode: e
                .errorCode); // Re-throw the API exception with the backend message
      } else {
        // Handle any other exceptions
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }
}
