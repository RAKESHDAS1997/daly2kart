import 'package:eshop_pro/data/models/seller.dart';
import 'package:eshop_pro/data/repositories/authRepository.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/labelKeys.dart';

class SellerRepository {
  Future<({List<Seller> sellers, int total})> getSellers(
      {required int storeId, int? offset, List<int>? sellerIds}) async {
    try {
      final result = await Api.get(
          url: Api.getSellers,
          useAuthToken: false,
          queryParameters: {
            Api.userIdApiKey: AuthRepository.getUserDetails().id,
            Api.storeIdApiKey: storeId,
            Api.offsetApiKey: offset ?? 0,
            Api.limitApiKey: limit,
            if (sellerIds != []) Api.sellerIdsApiKey: sellerIds?.join(','),
          });

      return (
        sellers: ((result['data'] ?? []) as List)
            .map((product) => Seller.fromJson(Map.from(product ?? {})))
            .toList(),
        total: int.parse((result['total'] ?? 0).toString())
      );
    } catch (e, _) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<List<Seller>> getBestSellers(
      {required int storeId, int? offset}) async {
    try {
      final result = await Api.get(
          url: Api.bestSellers,
          useAuthToken: false,
          queryParameters: {
            Api.userIdApiKey: AuthRepository.getUserDetails().id,
            Api.storeIdApiKey: storeId,
            Api.offsetApiKey: offset ?? 0,
            Api.limitApiKey: limit,
          });

      return (((result['data'] ?? []) as List)
          .map((product) => Seller.fromJson(Map.from(product ?? {})))
          .toList());
    } catch (e, _) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<List<Seller>> getFeaturedSellers({required int storeId}) async {
    try {
      final result = await Api.get(
          url: Api.topSellers,
          useAuthToken: true,
          queryParameters: {
            Api.userIdApiKey: AuthRepository.getUserDetails().id,
            Api.storeIdApiKey: storeId
          });

      return ((result['data'] ?? []) as List)
          .map((seller) => Seller.fromJson(Map.from(seller ?? {})))
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
