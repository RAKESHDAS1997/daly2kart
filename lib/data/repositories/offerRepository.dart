import 'package:eshop_pro/data/models/offerSlider.dart';
import 'package:eshop_pro/data/models/slider.dart';
import 'package:eshop_pro/utils/labelKeys.dart';

import '../../utils/api.dart';

class OfferRepository {
  Future<List<OfferSlider>> getOfferSliders({required int storeId}) async {
    try {
      final result = await Api.get(
          url: Api.getOfferSliders,
          useAuthToken: false,
          queryParameters: {Api.storeIdApiKey: storeId});

      return ((result['slider_images'] ?? []) as List)
          .map((offer) => OfferSlider.fromJson(Map.from(offer ?? {})))
          .toList();
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<List<Sliders>> getSliders({required int storeId}) async {
    try {
      final result = await Api.get(
          url: Api.getSliderImages,
          useAuthToken: true,
          queryParameters: {Api.storeIdApiKey: storeId});

      return ((result['data'] ?? []) as List)
          .map((slider) => Sliders.fromJson(Map.from(slider ?? {})))
          .toList();
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }
}
