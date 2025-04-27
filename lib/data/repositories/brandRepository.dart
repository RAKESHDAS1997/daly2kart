import 'package:eshop_pro/data/models/brand.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/labelKeys.dart';

class BrandRepository {
  Future<({List<Brand> brands, int total})> getBrands(
      {required int storeId, int? offset, String? brandIds}) async {
    try {
      final result = await Api.get(
          url: Api.getBrands,
          useAuthToken: false,
          queryParameters: {
            Api.storeIdApiKey: storeId,
            Api.offsetApiKey: offset ?? 0,
            Api.limitApiKey: limit * 2,
            if (brandIds != null) Api.idsApiKey: brandIds
          });

      return (
        brands: (((result['data'] ?? [])) as List)
            .map((e) => Brand.fromJson(e))
            .toList(),
        total: int.parse((result['total'] ?? 0).toString())
      );
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }
}
