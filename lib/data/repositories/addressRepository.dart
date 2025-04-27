import 'package:eshop_pro/data/models/address.dart';
import 'package:eshop_pro/data/models/city.dart';
import 'package:eshop_pro/data/models/zipcode.dart';
import 'package:eshop_pro/utils/labelKeys.dart';

import '../../utils/api.dart';
import '../../utils/constants.dart';

class AddressRepository {
  Future<List<Address>> getAddress() async {
    try {
      final result = await Api.get(
          url: Api.getAddress, useAuthToken: true, queryParameters: {});

      return ((result['data'] ?? []) as List)
          .map((address) => Address.fromJson(Map.from(address ?? {})))
          .toList();
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<({Address address, String successMessage})> addAddress(
      {required Map<String, dynamic> params}) async {
    try {
      Map<String, dynamic> result;
      if (params.containsKey(Api.idApiKey)) {
        result = await Api.put(
            queryParameters: params,
            url: Api.updateAddress,
            useAuthToken: true);
      } else {
        result = await Api.post(
            body: params, url: Api.addAddress, useAuthToken: true);
      }

      return (
        successMessage: result['message'].toString(),
        address: Address.fromJson(Map.from(result['data'][0] ?? {}))
      );
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<
      ({
        List<City> citylist,
        int total,
      })> getCities({int? offset, String? search}) async {
    try {
      final result = await Api.get(
          url: Api.getCities,
          useAuthToken: true,
          queryParameters: {
            Api.limitApiKey: limit,
            Api.offsetApiKey: offset ?? 0,
            Api.searchApiKey: search ?? '',
          });

      return (
        citylist: ((result['data'] ?? []) as List)
            .map((city) => City.fromJson(Map.from(city ?? {})))
            .toList(),
        total: int.parse((result['total'] ?? 0).toString()),
      );
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<
      ({
        List<Zipcode> zipcodes,
        int total,
      })> getZipcodes({int? cityId, int? offset, String? search}) async {
    try {
      Map<String, dynamic>? queryParameters = {
        Api.limitApiKey: limit,
        Api.offsetApiKey: offset ?? 0,
        Api.searchApiKey: search ?? '',
      };
      if (cityId != null) {
        queryParameters[Api.cityIdApiKey] = cityId;
      }
      final result = await Api.get(
          url: cityId == null ? Api.getZipcodes : Api.getZipcodeByCityId,
          useAuthToken: true,
          queryParameters: queryParameters);

      return (
        zipcodes: ((result['data'] ?? []) as List)
            .map((zipcode) => Zipcode.fromJson(Map.from(zipcode ?? {})))
            .toList(),
        total: int.parse((result['total'] ?? 0).toString()),
      );
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }


  Future<String> deleteAddress({
    required int addressId,
  }) async {
    try {
      final result = await Api.post(
        body: {Api.idApiKey: addressId},
        url: Api.deleteAddress,
        useAuthToken: true,
      );
      return result['message'].toString();
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }
}
