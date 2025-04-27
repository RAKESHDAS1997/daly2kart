import 'package:eshop_pro/utils/constants.dart';

class SystemSettings {
  final String? appName;
  final String? supportNumber;
  final String? supportEmail;
  final String? logo;
  final String? favicon;
  final List<String>? onBoardingImage;
  final List<String>? onBoardingVideo;
  final String? storageType;
  final String? onBoardingMediaType;
  final String? currentVersionOfAndroidApp;
  final String? currentVersionOfIosApp;
  final int? orderDeliveryOtpSystem;
  final String? systemTimezone;
  final String? minimumCartAmount;
  final String? maximumItemAllowedInCart;
  final String? lowStockLimit;
  final String? maxDaysToReturnItem;
  final String? deliveryBoyBonus;
  final int? enableCartButtonOnProductListView;
  final int? versionSystemStatus;
  final int? expandProductImage;
  final String? taxName;
  final String? taxNumber;
  final int? google;
  final int? facebook;
  final int? apple;
  final int? referAndEarnStatus;
  final String? minimumReferAndEarnAmount;
  final String? minimumReferAndEarnBonus;
  final String? referAndEarnMethod;
  final String? maxReferAndEarnAmount;
  final String? numberOfTimesBonusGivenToCustomer;
  final int? walletBalanceStatus;
  final String? walletBalanceAmount;
  final String? authenticationMethod;

  final String? supportedLocals;
  final String? storeCurrency;
  final String? decimalPoint;
  final int? singleSellerOrderSystem;
  final int? customerAppMaintenanceStatus;
  final int? sellerAppMaintenanceStatus;
  final int? deliveryBoyAppMaintenanceStatus;
  final String? messageForCustomerApp;
  final String? messageForSellerApp;
  final String? messageForDeliveryBoyApp;
  final int? navbarFixed;
  final int? themeMode;
  final CurrencySetting? currencySetting;

  SystemSettings({
    this.appName,
    this.supportNumber,
    this.supportEmail,
    this.logo,
    this.favicon,
    this.onBoardingImage,
    this.onBoardingVideo,
    this.storageType,
    this.onBoardingMediaType,
    this.currentVersionOfAndroidApp,
    this.currentVersionOfIosApp,
    this.orderDeliveryOtpSystem,
    this.systemTimezone,
    this.minimumCartAmount,
    this.maximumItemAllowedInCart,
    this.lowStockLimit,
    this.maxDaysToReturnItem,
    this.deliveryBoyBonus,
    this.enableCartButtonOnProductListView,
    this.versionSystemStatus,
    this.expandProductImage,
    this.taxName,
    this.taxNumber,
    this.google,
    this.facebook,
    this.apple,
    this.referAndEarnStatus,
    this.minimumReferAndEarnAmount,
    this.minimumReferAndEarnBonus,
    this.referAndEarnMethod,
    this.maxReferAndEarnAmount,
    this.numberOfTimesBonusGivenToCustomer,
    this.walletBalanceStatus,
    this.walletBalanceAmount,
    this.authenticationMethod,
    this.supportedLocals,
    this.storeCurrency,
    this.decimalPoint,
    this.singleSellerOrderSystem,
    this.customerAppMaintenanceStatus,
    this.sellerAppMaintenanceStatus,
    this.deliveryBoyAppMaintenanceStatus,
    this.messageForCustomerApp,
    this.messageForSellerApp,
    this.messageForDeliveryBoyApp,
    this.navbarFixed,
    this.themeMode,
    this.currencySetting,
  });

  SystemSettings copyWith({
    String? appName,
    String? supportNumber,
    String? supportEmail,
    String? logo,
    String? favicon,
    List<String>? onBoardingImage,
    List<String>? onBoardingVideo,
    String? storageType,
    String? onBoardingMediaType,
    String? currentVersionOfAndroidApp,
    String? currentVersionOfIosApp,
    int? orderDeliveryOtpSystem,
    String? systemTimezone,
    String? minimumCartAmount,
    String? maximumItemAllowedInCart,
    String? lowStockLimit,
    String? maxDaysToReturnItem,
    String? deliveryBoyBonus,
    int? enableCartButtonOnProductListView,
    int? versionSystemStatus,
    int? expandProductImage,
    String? taxName,
    String? taxNumber,
    int? google,
    int? facebook,
    int? apple,
    int? referAndEarnStatus,
    String? minimumReferAndEarnAmount,
    String? minimumReferAndEarnBonus,
    String? referAndEarnMethod,
    String? maxReferAndEarnAmount,
    String? numberOfTimesBonusGivenToCustomer,
    int? walletBalanceStatus,
    String? walletBalanceAmount,
    String? authenticationMethod,
    String? supportedLocals,
    String? storeCurrency,
    String? decimalPoint,
    int? singleSellerOrderSystem,
    int? customerAppMaintenanceStatus,
    int? sellerAppMaintenanceStatus,
    int? deliveryBoyAppMaintenanceStatus,
    String? messageForCustomerApp,
    String? messageForSellerApp,
    String? messageForDeliveryBoyApp,
    int? navbarFixed,
    int? themeMode,
    CurrencySetting? currencySetting,
  }) {
    return SystemSettings(
      appName: appName ?? this.appName,
      supportNumber: supportNumber ?? this.supportNumber,
      supportEmail: supportEmail ?? this.supportEmail,
      logo: logo ?? this.logo,
      favicon: favicon ?? this.favicon,
      onBoardingImage: onBoardingImage ?? this.onBoardingImage,
      onBoardingVideo: onBoardingVideo ?? this.onBoardingVideo,
      storageType: storageType ?? this.storageType,
      onBoardingMediaType: onBoardingMediaType ?? this.onBoardingMediaType,
      currentVersionOfAndroidApp:
          currentVersionOfAndroidApp ?? this.currentVersionOfAndroidApp,
      currentVersionOfIosApp:
          currentVersionOfIosApp ?? this.currentVersionOfIosApp,
      orderDeliveryOtpSystem:
          orderDeliveryOtpSystem ?? this.orderDeliveryOtpSystem,
      systemTimezone: systemTimezone ?? this.systemTimezone,
      minimumCartAmount: minimumCartAmount ?? this.minimumCartAmount,
      maximumItemAllowedInCart:
          maximumItemAllowedInCart ?? this.maximumItemAllowedInCart,
      lowStockLimit: lowStockLimit ?? this.lowStockLimit,
      maxDaysToReturnItem: maxDaysToReturnItem ?? this.maxDaysToReturnItem,
      deliveryBoyBonus: deliveryBoyBonus ?? this.deliveryBoyBonus,
      enableCartButtonOnProductListView: enableCartButtonOnProductListView ??
          this.enableCartButtonOnProductListView,
      versionSystemStatus: versionSystemStatus ?? this.versionSystemStatus,
      expandProductImage: expandProductImage ?? this.expandProductImage,
      taxName: taxName ?? this.taxName,
      taxNumber: taxNumber ?? this.taxNumber,
      google: google ?? this.google,
      facebook: facebook ?? this.facebook,
      apple: apple ?? this.apple,
      referAndEarnStatus: referAndEarnStatus ?? this.referAndEarnStatus,
      minimumReferAndEarnAmount:
          minimumReferAndEarnAmount ?? this.minimumReferAndEarnAmount,
      minimumReferAndEarnBonus:
          minimumReferAndEarnBonus ?? this.minimumReferAndEarnBonus,
      referAndEarnMethod: referAndEarnMethod ?? this.referAndEarnMethod,
      maxReferAndEarnAmount:
          maxReferAndEarnAmount ?? this.maxReferAndEarnAmount,
      numberOfTimesBonusGivenToCustomer: numberOfTimesBonusGivenToCustomer ??
          this.numberOfTimesBonusGivenToCustomer,
      walletBalanceStatus: walletBalanceStatus ?? this.walletBalanceStatus,
      walletBalanceAmount: walletBalanceAmount ?? this.walletBalanceAmount,
      authenticationMethod: authenticationMethod ?? this.authenticationMethod,
      supportedLocals: supportedLocals ?? this.supportedLocals,
      storeCurrency: storeCurrency ?? this.storeCurrency,
      decimalPoint: decimalPoint ?? this.decimalPoint,
      singleSellerOrderSystem:
          singleSellerOrderSystem ?? this.singleSellerOrderSystem,
      customerAppMaintenanceStatus:
          customerAppMaintenanceStatus ?? this.customerAppMaintenanceStatus,
      sellerAppMaintenanceStatus:
          sellerAppMaintenanceStatus ?? this.sellerAppMaintenanceStatus,
      deliveryBoyAppMaintenanceStatus: deliveryBoyAppMaintenanceStatus ??
          this.deliveryBoyAppMaintenanceStatus,
      messageForCustomerApp:
          messageForCustomerApp ?? this.messageForCustomerApp,
      messageForSellerApp: messageForSellerApp ?? this.messageForSellerApp,
      messageForDeliveryBoyApp:
          messageForDeliveryBoyApp ?? this.messageForDeliveryBoyApp,
      navbarFixed: navbarFixed ?? this.navbarFixed,
      themeMode: themeMode ?? this.themeMode,
      currencySetting: currencySetting ?? this.currencySetting,
    );
  }

  SystemSettings.fromJson(Map<String, dynamic> json)
      : appName = json['app_name'] as String?,
        supportNumber = json['support_number'] as String?,
        supportEmail = json['support_email'] as String?,
        logo = json['logo'] as String?,
        favicon = json['favicon'] as String?,
        onBoardingImage = json['on_boarding_image'] == ''
            ? []
            : (json['on_boarding_image'] as List?)
                ?.map((dynamic e) => e as String)
                .toList(),
        onBoardingVideo = json['on_boarding_video'] == ''
            ? []
            : (json['on_boarding_video'] as List?)
                ?.map((dynamic e) => e as String)
                .toList(),
        storageType = json['storage_type'] as String?,
        onBoardingMediaType = json['on_boarding_media_type'] as String?,
        currentVersionOfAndroidApp =
            json['current_version_of_android_app'] as String?,
        currentVersionOfIosApp = json['current_version_of_ios_app'] as String?,
        orderDeliveryOtpSystem = json['order_delivery_otp_system'] as int?,
        systemTimezone = json['system_timezone'] as String?,
        minimumCartAmount = json['minimum_cart_amount'] as String?,
        maximumItemAllowedInCart =
            json['maximum_item_allowed_in_cart'] as String?,
        lowStockLimit = json['low_stock_limit'] as String?,
        maxDaysToReturnItem = (json['max_days_to_return_item'] ?? 1).toString(),
        deliveryBoyBonus = json['delivery_boy_bonus'] as String?,
        enableCartButtonOnProductListView =
            json['enable_cart_button_on_product_list_view'] as int?,
        versionSystemStatus = json['version_system_status'] as int?,
        expandProductImage = json['expand_product_image'] as int?,
        taxName = json['tax_name'] as String?,
        taxNumber = json['tax_number'] as String?,
        google = json['google'] as int?,
        facebook = json['facebook'] as int?,
        apple = json['apple'] as int?,
        referAndEarnStatus = json['refer_and_earn_status'] as int?,
        minimumReferAndEarnAmount =
            json['minimum_refer_and_earn_amount'] as String?,
        minimumReferAndEarnBonus =
            json['minimum_refer_and_earn_bonus'] as String?,
        referAndEarnMethod = json['refer_and_earn_method'] as String?,
        maxReferAndEarnAmount = json['max_refer_and_earn_amount'] as String?,
        numberOfTimesBonusGivenToCustomer =
            json['number_of_times_bonus_given_to_customer'] as String?,
        walletBalanceStatus = json['wallet_balance_status'] as int?,
        walletBalanceAmount = json['wallet_balance_amount'] as String?,
        authenticationMethod = json['authentication_method'] as String?,
        supportedLocals = json['supported_locals'] as String?,
        storeCurrency = json['store_currency'] as String?,
        decimalPoint = json['decimal_point'] as String?,
        singleSellerOrderSystem = json['single_seller_order_system'] as int?,
        customerAppMaintenanceStatus =
            json['customer_app_maintenance_status'] ?? 0,
        sellerAppMaintenanceStatus = json['seller_app_maintenance_status'] ?? 0,
        deliveryBoyAppMaintenanceStatus =
            json['delivery_boy_app_maintenance_status'] ?? 0,
        messageForCustomerApp = json['message_for_customer_app'] as String?,
        messageForSellerApp = json['message_for_seller_app'] as String?,
        messageForDeliveryBoyApp =
            json['message_for_delivery_boy_app'] as String?,
        navbarFixed = json['navbar_fixed'] as int?,
        themeMode = json['theme_mode'] as int?,
        currencySetting =
            (json['currency_setting'] as Map<String, dynamic>?) != null
                ? CurrencySetting.fromJson(
                    json['currency_setting'] as Map<String, dynamic>)
                : null;

  Map<String, dynamic> toJson() => {
        'app_name': appName,
        'support_number': supportNumber,
        'support_email': supportEmail,
        'logo': logo,
        'favicon': favicon,
        'on_boarding_image': onBoardingImage,
        'on_boarding_video': onBoardingVideo,
        'storage_type': storageType,
        'on_boarding_media_type': onBoardingMediaType,
        'current_version_of_android_app': currentVersionOfAndroidApp,
        'current_version_of_ios_app': currentVersionOfIosApp,
        'order_delivery_otp_system': orderDeliveryOtpSystem,
        'system_timezone': systemTimezone,
        'minimum_cart_amount': minimumCartAmount,
        'maximum_item_allowed_in_cart': maximumItemAllowedInCart,
        'low_stock_limit': lowStockLimit,
        'max_days_to_return_item': maxDaysToReturnItem,
        'delivery_boy_bonus': deliveryBoyBonus,
        'enable_cart_button_on_product_list_view':
            enableCartButtonOnProductListView,
        'version_system_status': versionSystemStatus,
        'expand_product_image': expandProductImage,
        'tax_name': taxName,
        'tax_number': taxNumber,
        'google': google,
        'facebook': facebook,
        'apple': apple,
        'refer_and_earn_status': referAndEarnStatus,
        'minimum_refer_and_earn_amount': minimumReferAndEarnAmount,
        'minimum_refer_and_earn_bonus': minimumReferAndEarnBonus,
        'refer_and_earn_method': referAndEarnMethod,
        'max_refer_and_earn_amount': maxReferAndEarnAmount,
        'number_of_times_bonus_given_to_customer':
            numberOfTimesBonusGivenToCustomer,
        'wallet_balance_status': walletBalanceStatus,
        'wallet_balance_amount': walletBalanceAmount,
        'authentication_method': authenticationMethod,
        'supported_locals': supportedLocals,
        'store_currency': storeCurrency,
        'decimal_point': decimalPoint,
        'single_seller_order_system': singleSellerOrderSystem,
        'customer_app_maintenance_status': customerAppMaintenanceStatus,
        'seller_app_maintenance_status': sellerAppMaintenanceStatus,
        'delivery_boy_app_maintenance_status': deliveryBoyAppMaintenanceStatus,
        'message_for_customer_app': messageForCustomerApp,
        'message_for_seller_app': messageForSellerApp,
        'message_for_delivery_boy_app': messageForDeliveryBoyApp,
        'navbar_fixed': navbarFixed,
        'theme_mode': themeMode,
        'currency_setting': currencySetting?.toJson()
      };

  bool showVideosInOnBoardingScreen() {
    return onBoardingMediaType == videoMediaType;
  }

  bool showImagesInOnBoardingScreen() {
    return onBoardingMediaType == imageMediaType;
  }
}

class CurrencySetting {
  final int? id;
  final String? name;
  final String? code;
  final String? symbol;
  final String? exchangeRate;
  final int? isDefault;
  final int? status;
  final String? createdAt;
  final String? updatedAt;

  CurrencySetting({
    this.id,
    this.name,
    this.code,
    this.symbol,
    this.exchangeRate,
    this.isDefault,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  CurrencySetting copyWith({
    int? id,
    String? name,
    String? code,
    String? symbol,
    String? exchangeRate,
    int? isDefault,
    int? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return CurrencySetting(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      symbol: symbol ?? this.symbol,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      isDefault: isDefault ?? this.isDefault,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  CurrencySetting.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        name = json['name'] as String?,
        code = json['code'] as String?,
        symbol = json['symbol'] as String?,
        exchangeRate = json['exchange_rate'] as String?,
        isDefault = json['is_default'] as int?,
        status = json['status'] as int?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'symbol': symbol,
        'exchange_rate': exchangeRate,
        'is_default': isDefault,
        'status': status,
        'created_at': createdAt,
        'updated_at': updatedAt
      };
}
