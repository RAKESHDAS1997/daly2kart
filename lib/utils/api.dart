import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eshop_pro/app/app.dart';
import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/data/repositories/settingsRepository.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';

import '../data/repositories/authRepository.dart';
import '../ui/widgets/check_interconnectiviy.dart';

class ApiException implements Exception {
  String errorMessage;
  final List<Map<String, dynamic>>? errorData;
  final int? errorCode;

  ApiException(this.errorMessage, {this.errorData, this.errorCode});

  @override
  String toString() {
    return errorMessage;
  }
}

class Api {

  static String getStores = "${databaseUrl}get_stores";
  static String getSettings = "${databaseUrl}get_settings";
  static String getLanguages = "${databaseUrl}get_languages";
  static String getLanguageLabels = "${databaseUrl}get_language_labels";
  static String registerUser = "${databaseUrl}register_user";
  static String login = "${databaseUrl}login";
  static String verifyUser = "${databaseUrl}verify_user";
  static String signUp = "${databaseUrl}sign_up";
  static String resetPassword = "${databaseUrl}reset_password";
  static String getCategories = "${databaseUrl}get_categories";
  static String getCategoriesSliders = "${databaseUrl}get_categories_sliders";
  static String getOfferImages = "${databaseUrl}get_offer_images";
  static String getSliderImages = "${databaseUrl}get_slider_images";
  static String getOfferSliders = "${databaseUrl}get_offers_sliders";
  static String updateFcm = "${databaseUrl}update_fcm";
  static String topSellers =
      "${databaseUrl}top_sellers"; 
  static String getProducts = "${databaseUrl}get_products";
  static String getComboProducts = "${databaseUrl}get_combo_products";
  static String getComboProductRating =
      "${databaseUrl}get_combo_product_rating";
  static String getOrders = "${databaseUrl}get_orders";
  static String getMostSellingProducts = "${databaseUrl}most_selling_products";
  static String getSections = "${databaseUrl}get_sections";
  static String getSellers = "${databaseUrl}get_sellers";
  static String bestSellers = "${databaseUrl}best_sellers";
  static String getBrands = "${databaseUrl}get_brands";
  static String updateUser = "${databaseUrl}update_user";
  static String getFaqs = "${databaseUrl}get_faqs";
  static String getProductFaqs = "${databaseUrl}get_product_faqs";
  static String addProductFfaqs = "${databaseUrl}add_product_faqs";
  static String getTransactions = "${databaseUrl}transactions";
  static String getWithdrawalRequest = "${databaseUrl}get_withdrawal_request";
  static String getAddress = "${databaseUrl}get_address";
  static String addAddress = "${databaseUrl}add_address";
  static String updateAddress = "${databaseUrl}update_address";
  static String getCities = "${databaseUrl}get_cities";
  static String getZipcodeByCityId = "${databaseUrl}get_zipcode_by_city_id";
  static String getZipcodes = "${databaseUrl}get_zipcodes";
  static String deleteAddress = "${databaseUrl}delete_address";
  static String getPromoCodes = "${databaseUrl}get_promo_codes";
  static String deleteUserAccount = "${databaseUrl}delete_user";
  static String deleteSocialAccount = "${databaseUrl}delete_social_account";
  static String getFavorites = "${databaseUrl}get_favorites";
  static String addFavoriteProduct = "${databaseUrl}add_to_favorites";
  static String removeFavoriteProduct = "${databaseUrl}remove_from_favorites";
  static String downloadOrderInvoice = "${databaseUrl}download_order_invoice";
  static String downloadLinkHash = "${databaseUrl}download_link_hash";
  static String sendWithdrawalRequest = "${databaseUrl}send_withdrawal_request";
  static String getNotifications = "${databaseUrl}get_notifications";
  static String getTickets = "${databaseUrl}get_tickets";
  static String addTicket = "${databaseUrl}add_ticket";
  static String editTicket = "${databaseUrl}edit_ticket";
  static String getTicketTypes = "${databaseUrl}get_ticket_types";
  static String validatePromoCode = "${databaseUrl}validate_promo_code";
  static String validateReferCode = "${databaseUrl}validate_refer_code";
  static String verifyOtp = "${databaseUrl}verify_otp";
  static String resendOtp = "${databaseUrl}resend_otp";
  static String getUserCart = "${databaseUrl}get_user_cart";
  static String clearCart = "${databaseUrl}clear_cart";
  static String removeFromCart = "${databaseUrl}remove_from_cart";
  static String manageCart = "${databaseUrl}manage_cart";
  static String placeOrder = "${databaseUrl}place_order";
  static String updateOrderItemStatus =
      "${databaseUrl}update_order_item_status";
  static String updateOrderStatus = "${databaseUrl}update_order_status";
  static String getProductRating = "${databaseUrl}get_product_rating";
  static String setProductRating = "${databaseUrl}set_product_rating";
  static String setComboProductRating =
      "${databaseUrl}set_combo_product_rating";
  static String searchProducts = "${databaseUrl}search_products";
  static String checkCartProductsDelivarable =
      "${databaseUrl}check_cart_products_delivarable";
  static String getMostSearchedHistory =
      "${databaseUrl}get_most_searched_history";
  static String getSimilarProducts = "${databaseUrl}get_similar_products";
  static String getSimilarComboProducts =
      "${databaseUrl}get_combo_similar_products";
  static String isProductDelivarable = "${databaseUrl}is_product_delivarable";
  static String getPaypalLink = "${databaseUrl}get_paypal_link";
  static String deleteOrder = "${databaseUrl}delete_order";
  static String addTransaction = "${databaseUrl}add_transaction";
  static String phonepeApp = "${databaseUrl}phonepe_app";
  static String razorpayCreateOrder = "${databaseUrl}razorpay_create_order";
  static String paypalResponseUrl = '$databaseUrl' 'app_payment_status';
  static String chatifyAuthAPI = '$baseUrl/chatify/api/chat/auth';
  static String chatifySendMessageApi = '$baseUrl/chatify/api/sendMessage';
  static String chatifyFetchMessagesApi = '$baseUrl/chatify/api/fetchMessages';
  static String chatifySearchApi = '$baseUrl/chatify/api/search';
  static String chatifyGetContactsApi = '$baseUrl/chatify/api/getContacts';
  static String chatifyMakeSeenApi = '$baseUrl/chatify/api/makeSeen';

  ///=====*** form keys=====
  static String idApiKey = 'id';
  static String idsApiKey = 'ids';
  static String nameApiKey = 'name';
  static String emailApiKey = 'email';
  static String passwordApiKey = 'password';
  static String mobileApiKey = 'mobile';
  static String mobileNoApiKey = 'mobile_no';
  static String countryCodeApiKey = 'country_code';
  static String otpApiKey = 'otp';
  static String fcmIdApiKey = 'fcm_id';
  static String userIdApiKey = 'user_id';
  static String referralCodeApiKey = 'referral_code';
  static String friendsCodeApiKey = 'friends_code';
  static String newApiKey = 'new';
  static String oldApiKey = 'old';
  static String typeApiKey = 'type';
  static String storeIdApiKey = 'store_id';
  static String zipCodeApiKey = 'zipcode';
  static String latitudeApiKey = 'latitude';
  static String longitudeApiKey = 'longitude';
  static String languageCodeApiKey = 'language_code';
  static String activeApiKey = 'active';
  static String imageApiKey = 'image';
  static String firebaseIdApiKey = 'firebase_id';
  static String productIdApiKey = 'product_id';
  static String sellerIdApiKey = 'seller_id';
  static String offsetApiKey = 'offset';
  static String limitApiKey = 'limit';
  static String sortByApiKey = 'sort';
  static String orderByApiKey = 'order';
  static String topRatedProductApiKey = 'top_rated_product';
  static String discountApiKey = 'discount';
  static String usernameApiKey = 'username';
  static String transactionTypeApiKey = 'transaction_type';
  static String stateApiKey = 'state';
  static String addressApiKey = 'address';
  static String cityApiKey = 'city';
  static String cityNameApiKey = 'city_name';
  static String areaNameApiKey = 'area_name';
  static String pincodeApiKey = 'pincode';
  static String pincodeNameApiKey = 'pincode_name';
  static String isDefaultAddressApiKey = 'is_default';
  static String searchApiKey = 'search';
  static String cityIdApiKey = 'city_id';
  static String activeStatusApiKey = 'active_status';
  static String ratingApiKey = 'rating';
  static String minPriceApiKey = 'minimum_price';
  static String maxPriceApiKey = 'maximum_price';
  static String categoryIdApiKey = 'category_id';
  static String brandIdApiKey = 'brand_id';
  static String attributeValuesIdsApiKey = 'attribute_values_ids';
  static String productTypeApiKey = 'product_type';
  static String startDateApiKey = 'start_date';
  static String endDateApiKey = 'end_date';
  static String orderIdApiKey = 'order_id';
  static String orderItemIdApiKey = 'order_item_id';
  static String ticketTypeIdApiKey = 'ticket_type_id';
  static String subjectApiKey = 'subject';
  static String descriptionApiKey = 'description';
  static String ticketIdApiKey = 'ticket_id';
  static String statusApiKey = 'status';
  static String amountApiKey = 'amount';
  static String paymentAddressApiKey = 'payment_address';
  static String finalTotalApiKey = 'final_total';
  static String promoCodeApiKey = 'promo_code';
  static String promoCodeIdApiKey = 'promo_code_id';
  static String productVariantIdApiKey = 'product_variant_id';
  static String addressIdApiKey = 'address_id';
  static String onlyDeliveryChargeApiKey = 'only_delivery_charge';
  static String isSavedForLaterApiKey = 'is_saved_for_later';
  static String qtyApiKey = 'qty';
  static String txnIdApiKey = 'txn_id';
  static String paymentMethodApiKey = 'payment_method';
  static String messageApiKey = 'message';
  static String transactionIdApiKey = 'transaction_id';
  static String productIdsApiKey = 'product_ids';
  static String sellerIdsApiKey = 'seller_ids';
  static String isSellerApiKey = 'is_seller';
  static String questionApiKey = 'question';
  static String hasImagesApiKey = 'has_images';
  static String productLimitApiKey = 'product_limit';
  static String productOffsetApiKey = 'product_offset';
  static String sellerLimitApiKey = 'seller_limit';
  static String sellerOffsetApiKey = 'seller_offset';
  static String deliveryChargeApiKey = 'delivery_charge';
  static String isWalletUsedApiKey = 'is_wallet_used';
  static String walletBalanceUsedApiKey = 'wallet_balance_used';
  static String orderNoteApiKey = 'order_note';
  static String orderPaymentCurrencyCodeApiKey = 'order_payment_currency_code';
  static String fromIdApiKey = 'from_id';
  static String toIdApiKey = 'to_id';
  static String fileApiKey = 'file';
  static String commentApiKey = 'comment';
  static String titleApiKey = 'title';
  static String reviewImageApiKey = 'review_image';
  static String isNotificationOnApiKey = 'is_notification_on';

  ///end form keys====discount

  static Map<String, dynamic> headers() {
    String token = AuthRepository
        .getToken(); 
    
    if (token.isEmpty) {
      return {};
    }

    return {
      "Authorization": "Bearer $token",
  
    };
  }

  static callOnUnauthorized(
    String url, {
    String? message,
  }) {
    if ([
      Api.verifyUser,

      Api.registerUser,
      Api.updateFcm,
      Api.updateUser
    ].contains(url)) {
      Utils.showSnackBar(
          message: 'Unauthenticated. Please login again.',
          context: navigatorKey.currentContext!);
      Utils.navigateToScreen(navigatorKey.currentContext!, Routes.loginScreen,
          replaceAll: true);
    }
  }

  static Future<Map<String, dynamic>> post({
    required Map<String, dynamic> body,
    required String url,
    required bool useAuthToken,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      if (await InternetConnectivity.isUserOffline()) {
        throw ApiException(noInternetKey);
      }
      final Dio dio = Dio();
      final FormData formData =
          FormData.fromMap(body, ListFormat.multiCompatible);

      final response = await dio.post(url,
          data: formData,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
          options: useAuthToken ? Options(headers: headers()) : null);
    
      if ([
        Api.checkCartProductsDelivarable,
        Api.validatePromoCode,
        Api.chatifyFetchMessagesApi,
        Api.chatifySendMessageApi,
        Api.chatifyMakeSeenApi
      ].contains(url)) {
        return Map.from(response.data);
      }
      if (url == Api.chatifyAuthAPI) {
        return jsonDecode(response.data);
      }
      if (response.data['error']) {
        
        if (response.data['code'] == 401) {
          callOnUnauthorized(url);
        }
        throw ApiException(
          SettingsRepository().getCurrentAppLanguage().code != null &&
                  SettingsRepository().getCurrentAppLanguage().code != 'en'
              ? response.data['language_message_key']
              : response.data['message'].toString(),
          errorCode: response.data['code'],
        );
      }
      if (SettingsRepository().getCurrentAppLanguage().code != null &&
          SettingsRepository().getCurrentAppLanguage().code != 'en') {
        response.data['message'] = response.data['language_message_key'];
      }
      return Map.from(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        // The request was made and the server responded with a status code
        if (e.response!.statusCode == 500) {
          // Handle the 500 error
          throw ApiException(internalServerErrorMessageKey);
        }
        if (e.response!.statusCode == 401) {
          // Handle the 401 error
          callOnUnauthorized(url, message: e.response!.data['message']);
        }
      } else {
        // Something happened in setting up the request or an error occurred before the response
        throw ApiException(e.error is SocketException
            ? noInternetKey
            : e.response?.data['message']);
      }
      json.encode(e.response?.data);
      
      throw ApiException(e.error is SocketException
          ? noInternetKey
          : e.response?.data['message']);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage, errorCode: e.errorCode);
    } catch (e) {
      throw ApiException(defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> get({
    required String url,
    required bool useAuthToken,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      if (await InternetConnectivity.isUserOffline()) {
        throw ApiException(noInternetKey);
      }
  
      final Dio dio = Dio();
      final response = await dio.get(url,
          queryParameters: queryParameters,
          options: useAuthToken ? Options(headers: headers()) : null);
    
      if ([
        Api.getUserCart,
        Api.getProductRating,
        Api.chatifySearchApi,
        Api.chatifySearchApi,
        Api.chatifyGetContactsApi
      ].contains(url)) {
        return Map.from(response.data);
      }
      if (response.data['error']) {
        if (response.data['code'] == 401) {
          callOnUnauthorized(
            url,
          );
        }
        throw ApiException(
          SettingsRepository().getCurrentAppLanguage().code != null &&
                  SettingsRepository().getCurrentAppLanguage().code != 'en'
              ? response.data['language_message_key']
              : response.data['message'].toString(),
          errorCode: response.data['code'],
        );
      }
      if (SettingsRepository().getCurrentAppLanguage().code != null &&
          SettingsRepository().getCurrentAppLanguage().code != 'en') {
        response.data['message'] = response.data['language_message_key'];
      }
      return Map.from(response.data);
    } on DioException catch (e) {
      
      if (e.response != null) {
        // The request was made and the server responded with a status code
        if (e.response!.statusCode == 500) {
          // Handle the 500 error
          throw ApiException(internalServerErrorMessageKey);
        }
        if (e.response!.statusCode == 401) {
          // Handle the 401 error
          callOnUnauthorized(url, message: e.response!.data['message']);
        }
      }
      throw ApiException(
          e.error is SocketException ? noInternetKey : defaultErrorMessageKey);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage, errorCode: e.errorCode);
    } catch (e) {
   
      throw ApiException(defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> put({
    Map<String, dynamic>? body,
    required String url,
    required bool useAuthToken,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      if (await InternetConnectivity.isUserOffline()) {
        throw const SocketException(noInternetKey);
      }
      final Dio dio = Dio();
      final FormData formData =
          FormData.fromMap(body ?? {}, ListFormat.multiCompatible);
 
      final response = await dio.put(url,
          data: formData,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
          options: useAuthToken ? Options(headers: headers()) : null);
    
      if (response.data['error']) {
        if (response.data['code'] == 401) {
          callOnUnauthorized(url);
        }
        throw ApiException(
            SettingsRepository().getCurrentAppLanguage().code != null &&
                    SettingsRepository().getCurrentAppLanguage().code != 'en'
                ? response.data['language_message_key']
                : response.data['message'].toString());
      }
      if (SettingsRepository().getCurrentAppLanguage().code != null &&
          SettingsRepository().getCurrentAppLanguage().code != 'en') {
        response.data['message'] = response.data['language_message_key'];
      }
      return Map.from(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        // The request was made and the server responded with a status code
        if (e.response!.statusCode == 500) {
          // Handle the 500 error
          throw ApiException(internalServerErrorMessageKey);
        }
        if (e.response!.statusCode == 401) {
          // Handle the 401 error
          callOnUnauthorized(url, message: e.response!.data['message']);
        }
      }
    
      throw ApiException(e.error is SocketException
          ? noInternetKey
          : e.response?.data['message']);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage, errorCode: e.errorCode);
    } catch (e) {
      throw ApiException(defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> delete({
    required String url,
    required bool useAuthToken,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      if (await InternetConnectivity.isUserOffline()) {
        throw ApiException(noInternetKey);
      }
      final Dio dio = Dio();

      final response = await dio.delete(url,
          queryParameters: queryParameters,
          options: useAuthToken ? Options(headers: headers()) : null);
    
      if (response.data['error']) {
        if (response.data['code'] == 401) {
          callOnUnauthorized(url);
        }
        throw ApiException(
            SettingsRepository().getCurrentAppLanguage().code != null &&
                    SettingsRepository().getCurrentAppLanguage().code != 'en'
                ? response.data['language_message_key']
                : response.data['message'].toString());
      }
      if (SettingsRepository().getCurrentAppLanguage().code != null &&
          SettingsRepository().getCurrentAppLanguage().code != 'en') {
        response.data['message'] = response.data['language_message_key'];
      }
      return Map.from(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        // The request was made and the server responded with a status code
        if (e.response!.statusCode == 500) {
          // Handle the 500 error
          throw ApiException(internalServerErrorMessageKey);
        }
        if (e.response!.statusCode == 401) {
          // Handle the 401 error
          callOnUnauthorized(url, message: e.response!.data['message']);
        }
      }
     
      throw ApiException(e.error is SocketException
          ? noInternetKey
          : e.response?.data['message']);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage, errorCode: e.errorCode);
    } catch (e) {
      throw ApiException(defaultErrorMessageKey);
    }
  }

  static Future<void> download(
      {required String url,
      required CancelToken cancelToken,
      required String savePath,
      required Function updateDownloadedPercentage}) async {
    try {
      if (await InternetConnectivity.isUserOffline()) {
        throw const SocketException(noInternetKey);
      }
      final Dio dio = Dio();
      await dio.download(url, savePath, cancelToken: cancelToken,
          onReceiveProgress: ((count, total) {
        updateDownloadedPercentage((count / total) * 100);
      }));
    } on DioException catch (e) {
      if (e.response != null) {
        // The request was made and the server responded with a status code
        if (e.response!.statusCode == 500) {
          // Handle the 500 error
          throw ApiException(internalServerErrorMessageKey);
        }
        if (e.response!.statusCode == 401) {
          // Handle the 401 error
          callOnUnauthorized(url, message: e.response!.data['message']);
        }
      }
    
      throw ApiException(e.error is SocketException
          ? noInternetKey
          : e.response?.data['message']);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage, errorCode: e.errorCode);
    } catch (e) {
      throw ApiException(defaultErrorMessageKey);
    }
  }

  static Future<String> getHtmlContent({
    required String url,
    required bool useAuthToken,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      if (await InternetConnectivity.isUserOffline()) {
        throw ApiException(noInternetKey);
      }
   
      final Dio dio = Dio();
      final response = await dio.get(url,
          queryParameters: queryParameters,
          options: useAuthToken ? Options(headers: headers()) : null);
      
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // The request was made and the server responded with a status code
        if (e.response!.statusCode == 500) {
          // Handle the 500 error
          throw ApiException(internalServerErrorMessageKey);
        }
      }
    
      throw ApiException(e.error is SocketException
          ? noInternetKey
          : e.response?.data['message']);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
     
      throw ApiException(defaultErrorMessageKey);
    }
  }
}
