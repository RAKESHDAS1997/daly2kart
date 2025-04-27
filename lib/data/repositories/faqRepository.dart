import 'package:eshop_pro/utils/labelKeys.dart';

import '../../utils/api.dart';
import '../../utils/constants.dart';
import '../models/faq.dart';

class FaqRepository {
  Future<({List<FAQ> faqs, int total})> getFaqs({
    required Map<String, dynamic> params,
    required String api,
  }) async {
    try {
      if (!params.containsKey(Api.limitApiKey)) {
        params.addAll({Api.limitApiKey: limit});
      }
      final result =
          await Api.get(url: api, useAuthToken: true, queryParameters: params);

      return (
        faqs: ((result['data'] ?? []) as List)
            .map((faq) => FAQ.fromJson(Map.from(faq ?? {})))
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

  Future<({FAQ faq, String successMessage})> addProductFaq(
      {required Map<String, dynamic> params}) async {
    try {
      final result = await Api.post(
          url: Api.addProductFfaqs, body: params, useAuthToken: true);

      return (
        faq: FAQ.fromJson(Map.from(result['data'] ?? {})),
        successMessage: result['message'].toString()
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
