import 'package:dio/dio.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:eshop_pro/utils/labelKeys.dart';

import '../../utils/constants.dart';
import '../models/order.dart';

class OrderRepository {
  Future<
      ({
        List<Order> orders,
        int total,
      })> getOrders({
    required int storeId,
    int? id,
    int? productId,
    int? offset,
    String? status,
    String? startDate,
    String? endDate,
    String? search,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {
        Api.storeIdApiKey: storeId,
        Api.offsetApiKey: offset ?? 0,
        Api.limitApiKey: limit,
        if (search != '' && search != null) Api.searchApiKey: search,
      };
      if (id != null) {
        queryParameters.addAll({Api.idApiKey: id});
      }
      if (status != allKey && status != null) {
        queryParameters.addAll({Api.activeStatusApiKey: status});
      }

      if (startDate != null) {
        queryParameters.addAll({Api.startDateApiKey: startDate});
      }
      if (endDate != null) {
        queryParameters.addAll({Api.endDateApiKey: endDate});
      }

      final result = await Api.get(
          url: Api.getOrders,
          useAuthToken: true,
          queryParameters: queryParameters);
      return (
        orders: ((result['data'] ?? []) as List)
            .map((order) => Order.fromJson(Map.from(order ?? {})))
            .toList(),
        total: int.parse((result['total'] ?? 0).toString()),
      );
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

  Future<String> deleteOrder({required String orderId}) async {
    try {
      final result = await Api.delete(
          url: Api.deleteOrder,
          useAuthToken: true,
          queryParameters: {Api.orderIdApiKey: orderId});
      return result['message'];
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<String> getOrderInvoice({required int orderId}) async {
    try {
      final result = await Api.get(
          url: Api.downloadOrderInvoice,
          useAuthToken: true,
          queryParameters: {Api.orderIdApiKey: orderId});

      return result['invoice_url'];
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<({Order order, String successMessage})> updateOrderItemStatus(
      {required Map<String, dynamic> params}) async {
    try {
      final result = await Api.post(
          body: params, url: Api.updateOrderItemStatus, useAuthToken: true);

      return (
        successMessage: result['message'].toString(),
        order: Order.fromJson(Map.from(result['data'][0] ?? {}))
      );
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<String> updateOrderStatus(
      {required Map<String, dynamic> params}) async {
    try {
      final result = await Api.put(
          queryParameters: params,
          url: Api.updateOrderStatus,
          useAuthToken: true);

      return result['message'].toString();
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<String> getFileDownloadLink({required int orderItemId}) async {
    try {
      final result = await Api.post(
          url: Api.downloadLinkHash,
          useAuthToken: true,
          body: {Api.orderItemIdApiKey: orderItemId});

      return result['data'];
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<void> downloadFile(
      {required String url,
      required String savePath,
      required CancelToken cancelToken,
      required Function updateDownloadedPercentage}) async {
    try {
      await Api.download(
          cancelToken: cancelToken,
          url: url,
          savePath: savePath,
          updateDownloadedPercentage: updateDownloadedPercentage);
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }
}
