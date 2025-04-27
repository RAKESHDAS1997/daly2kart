import 'package:eshop_pro/data/models/fesaturedSection.dart';

import 'package:eshop_pro/data/repositories/authRepository.dart';
import 'package:eshop_pro/utils/labelKeys.dart';

import '../../utils/api.dart';

class SectionRepository {
  Future<List<FeaturedSection>> getSections(
      {required int storeId, String? zipcode}) async {
    try {
      Map<String, dynamic>? params = {
        Api.storeIdApiKey: storeId,
        Api.userIdApiKey: AuthRepository.getUserDetails().id,
      };
      if (zipcode != null && zipcode.isNotEmpty) {
        params[Api.zipCodeApiKey] = zipcode;
      }
      final result = await Api.get(
          url: Api.getSections, useAuthToken: true, queryParameters: params);

      return ((result['data'] ?? []) as List)
          .map((section) => FeaturedSection.fromJson(
              Map.from(section ?? {}), zipcode != null ? true : false))
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
