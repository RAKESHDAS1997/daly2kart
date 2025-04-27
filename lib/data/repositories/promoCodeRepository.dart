import 'package:eshop_pro/data/models/promoCode.dart';
import 'package:eshop_pro/utils/labelKeys.dart';

import '../../utils/api.dart';

class PromoCodeRepository {
  Future<List<PromoCode>> getPromoCodes({required int storeId}) async {
    try {
      final result = await Api.get(
          url: Api.getPromoCodes,
          useAuthToken: true,
          queryParameters: {Api.storeIdApiKey: storeId});

      return ((result['data'] ?? []) as List)
          .map((code) => PromoCode.fromJson(Map.from(code ?? {})))
          .toList();
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e
            .toString()); // Re-throw the API exception with the backend message
      } else {
        // Handle any other exceptions
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<PromoCode> validatePromoCode(
      {required Map<String, dynamic> params}) async {
    try {
      final result = await Api.post(
          body: params, url: Api.validatePromoCode, useAuthToken: true);
      if (!result['error']) {
        return PromoCode.fromJson(Map.from(result['data'][0] ?? {}));
      }
      throw ApiException(result['message'], errorData: [result['data']]);
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString(),
            errorData: e
                .errorData); // Re-throw the API exception with the backend message
      } else {
        // Handle any other exceptions
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }
}
