import 'dart:convert';
import 'dart:io';

import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/user_details_cubit.dart';
import 'package:eshop_pro/data/models/paymentMethod.dart';
import 'package:eshop_pro/utils/Stripe_Service.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../utils/api.dart';
import '../../utils/constants.dart';
import '../models/transaction.dart';

class TransactionRepository {
  final paystackPlugin = PaystackPlugin();
  Future<({List<Transaction> transactions, int total, double balance})>
      getTransactions({
    required int userId,
    int? offset,
    String? transactionType,
    String? type,
  }) async {
    String url = Api.getTransactions;
    try {
      Map<String, dynamic> queryParameters = {
        Api.userIdApiKey: userId,
        Api.limitApiKey: limit,
        Api.transactionTypeApiKey: transactionType ?? defaultTransactionType,
        Api.typeApiKey: type,
        Api.offsetApiKey: offset ?? 0,
      };
      if (transactionType == walletTransactionType && type == debitType) {
        url = Api.getWithdrawalRequest;
      }
      if (transactionType == defaultTransactionType) {
        queryParameters.remove(Api.typeApiKey);
      }
      final result = await Api.get(
          url: url, useAuthToken: true, queryParameters: queryParameters);

      return (
        transactions: transactionType == walletTransactionType &&
                type == debitType
            ? ((result['data'] ?? []) as List)
                .map((transaction) =>
                    Transaction.fromWithdrawJson(Map.from(transaction ?? {})))
                .toList()
            : ((result['data'] ?? []) as List)
                .map((transaction) =>
                    Transaction.fromJson(Map.from(transaction ?? {})))
                .toList(),
        total: int.parse((result['total'] ?? 0).toString()),
        balance: double.parse((result['balance'] ?? 0).toString()),
      );
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  createRazorpayOrder({required String orderID, required double amount}) async {
    try {
      final result = await Api.post(body: {
        Api.orderIdApiKey: orderID,
        Api.amountApiKey: amount,
      }, url: Api.razorpayCreateOrder, useAuthToken: true);

      return result;
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<({Transaction transaction, String message})> sendWithdrawalRequest(
      {required Map<String, dynamic> params}) async {
    try {
      final result = await Api.post(
          body: params, url: Api.sendWithdrawalRequest, useAuthToken: true);

      return (
        transaction: Transaction.fromWithdrawJson(result['data'] ?? {}),
        message: result['message'].toString()
      );
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<bool> addTransaction({
    required Map<String, dynamic> params,
  }) async {
    try {
      final result = await Api.post(
          body: params, url: Api.addTransaction, useAuthToken: true);

      return result['error'] == false;
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<PaymentMethod> fetchPaymentMethods() async {
    try {
      final result = await Api.get(
          url: Api.getSettings,
          queryParameters: {Api.typeApiKey: 'payment_method'},
          useAuthToken: false);
      return PaymentMethod.fromJson(
          Map.from(result['data']['payment_method'] ?? {}));
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  doPaymentWithRazorpay(
      {required BuildContext context,
      required String orderID,
      required Razorpay razorpay,
      required String razorpayId,
      required double price}) async {
    try {
      String userContactNumber =
          context.read<UserDetailsCubit>().getUserMobile();
      String userEmail = context.read<UserDetailsCubit>().getUserEmail();

      var response = await TransactionRepository()
          .createRazorpayOrder(orderID: orderID, amount: price);
      if (response['error'] == false) {
        var razorpayOptions = {
          'key': razorpayId,
          'amount': price.toString(),
          'name': context.read<UserDetailsCubit>().getUserName(),
          'order_id': response['data']['id'],
          'notes': {'order_id': orderID},
          'prefill': {
            'contact': userContactNumber,
            'email': userEmail,
          },
        };

        razorpay.open(razorpayOptions);
      } else {
        return {
          'error': true,
          'message': '',
          'status': false,
        };
      }
    } catch (e) {
      Utils.showSnackBar(message: e.toString(), context: context);
    }
  }

  Future<Map<String, dynamic>> doPaymentWithStripe({
    required double price,
    required String currencyCode,
    required String paymentFor,
    required BuildContext context,
    String? orderId,
  }) async {
    try {
      StripeTransactionResponse stripeResponse = await payWithStripe(
          currencyCode: currencyCode,
          stripeTransactionAmount: price,
          paymentFor: paymentFor,
          orderId: orderId,
          context: context);
      Map<String, dynamic> response = {
        'error': true,
        'status': false,
        'message': defaultErrorMessageKey
      };

      if (stripeResponse.status == 'succeeded') {
        response['error'] = false;
        response['status'] = true;
        response['message'] = transactionSuccessfulKey;
      } else {
        response['error'] = true;
        response['status'] = false;
        response['message'] = stripeResponse.message;
      }

      return response;
    } catch (e) {
      return {
        'error': true,
        'message': e.toString(),
        'status': false,
      };
    }
  }

  //This method is used to pay with stripe
  static Future<StripeTransactionResponse> payWithStripe({
    required String currencyCode,
    required double stripeTransactionAmount,
    required String paymentFor,
    required BuildContext context,
    String? orderId,
  }) async {
    try {
      var response = await StripeService.payWithPaymentSheet(
          amount: (stripeTransactionAmount.round() * 100).toString(),
          currency: currencyCode,
          from: paymentFor,
          awaitedOrderId: orderId,
          context: context);

      return response;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> doPaymentWithPayStack(
      {required double price,
      required String paystackId,
      required String orderID,
      required BuildContext context}) async {
    try {
      String userEmail = context.read<UserDetailsCubit>().getUserEmail();

      await paystackPlugin.initialize(publicKey: paystackId);

      Charge charge = Charge()
        ..amount = (price * 100).toInt()
        ..email = userEmail
        ..putMetaData('order_id', orderID)
        ..reference = _getReference();

      CheckoutResponse response = await paystackPlugin.checkout(
        context,
        method: CheckoutMethod.card,
        charge: charge,
      );
     
      if (response.status) {
        return {
          'error': false,
          'message': transactionSuccessfulKey,
          'status': true,
          'transactionId': response.reference
        };
      } else {
        return {
          'error': true,
          'message': response.message,
          'status': true,
        };
      }
    } catch (e) {
      return {
        'error': true,
        'message': e.toString(),
        'status': false,
      };
    }
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<Map<String, dynamic>> doPaymentWithPaypal(
      {required double price,
      required String orderID,
      required String type,
      required BuildContext context}) async {
    try {
      var paypalLink = await getPaypalPaymentGatewayLink(params: {
        Api.amountApiKey: price,
        Api.userIdApiKey: context.read<UserDetailsCubit>().getUserId(),
        Api.orderIdApiKey: orderID
      });

      if (paypalLink != '') {
        var response = await Utils.navigateToScreen(
            context, Routes.paypalWebviewScreen,
            arguments: {
              'url': paypalLink,
              'from': type,
              'orderId': orderID,
              'price': price,
            });
        if (response == true) {
          return {
            'error': true,
            'message': transactionFailedKey,
            'status': false,
          };
        }
      }
      return {
        'error': false,
        'message': transactionSuccessfulKey,
        'status': true
      };
    } catch (e) {
      Utils.showSnackBar(message: e.toString(), context: context);
      return {
        'error': true,
        'message': e.toString(),
        'status': false,
      };
    }
  }

  //This method is used to get paypal payment gateway link
  static Future<String> getPaypalPaymentGatewayLink({
    required Map<String, dynamic> params,
  }) async {
    try {
      final result = await Api.getHtmlContent(
          url: Api.getPaypalLink, queryParameters: params, useAuthToken: true);
      return result;
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<Map<String, dynamic>> doPaymentWithPhonePe({
    required double price,
    required String environment,
    required String? appId,
    required String merchantId,
    String? orderID,
    required BuildContext context,
    String transactionType = defaultTransactionType,
    required String type,
  }) async {
    try {
      bool isPhonePeInitilized = await PhonePePaymentSdk.init(
          environment.toUpperCase(), appId ?? '', merchantId, true);

  
      Map<String, dynamic> params = {
        Api.userIdApiKey: context.read<UserDetailsCubit>().getUserId(),
        Api.amountApiKey: price.toString(),
        Api.statusApiKey: awaitingStatusType,
        Api.messageApiKey: 'waiting for payment',
        Api.paymentMethodApiKey: phonepeKey,
        Api.transactionTypeApiKey: transactionType,
        Api.typeApiKey:
            transactionType == defaultTransactionType ? phonepeKey : creditType
      };
      if (orderID != null) {
        params.addAll({Api.txnIdApiKey: orderID});
        params.addAll({Api.orderIdApiKey: orderID});
      }
      final bool transactionAdded = await addTransaction(params: params);

      //first create transaction with awaiting state, then do payment
      if (!transactionAdded || !isPhonePeInitilized) {
        return {
          'error': true,
          'message': phonePePaymentFailedKey,
          'status': false,
        };
      }

      final phonePeDetails = await getPhonePeDetails(
        type: type,
        mobile: context.read<UserDetailsCubit>().getUserMobile().trim().isEmpty
            ? context.read<UserDetailsCubit>().getUserId().toString()
            : context.read<UserDetailsCubit>().getUserMobile(),
        userId: context.read<UserDetailsCubit>().getUserId().toString(),
        amount: price.toString(),
        orderId: orderID,
        transationId: orderID ?? '',
      );

      final response = await PhonePePaymentSdk.startTransaction(
          jsonEncode(phonePeDetails['data']['payload'] ?? {}).toBase64,
          phonePeDetails['data']['payload']['redirectUrl'] ?? '',
          phonePeDetails['data']['checksum'] ?? '',
          Platform.isAndroid ? androidPackageName : iosPackageName);
      if (response != null) {
        String status = response['status'].toString();

        if (status == 'SUCCESS') {
          return {
            'error': false,
            'message': phonePePaymentSuccessKey,
            'status': true,
          };
        }
      }

      return {
        'error': true,
        'message': phonePePaymentFailedKey,
        'status': false,
      };
    } catch (e) {
      return {
        'error': true,
        'message': e.toString(),
        'status': false,
      };
    }
  }

  static Future<Map> getPhonePeDetails({
    required String userId,
    required String type,
    required String mobile,
    String? amount,
    String? orderId,
    required String transationId,
  }) async {
    try {
      var responseData = await Api.post(
        url: Api.phonepeApp,
        body: {
          Api.typeApiKey: type,
          Api.mobileApiKey: mobile,
          if (amount != null) Api.amountApiKey: amount,
          Api.orderIdApiKey: orderId ?? '',
          Api.transactionIdApiKey: transationId,
          Api.userIdApiKey: userId
        },
        useAuthToken: true,
      );
      return responseData;
    } on Exception catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }
}
