import 'dart:io';

import 'package:eshop_pro/data/repositories/authRepository.dart';
import 'package:eshop_pro/utils/labelKeys.dart';

const String baseUrl = "https://eshop-pro.eshopweb.store";
const String databaseUrl = "$baseUrl/api/";

const bool isDemoApp = true;

const String googleLoginType = 'google';
const String appleLoginType = 'apple';
const String phoneLoginType = 'phone';

const double appContentHorizontalPadding = 15.0;
const double appContentVerticalSpace = 16.0;
const double horizontalCompetitionListHeight = 70.0;
const double bottomsheetBorderRadius = 16.0;
const Duration bottomToastDisplayDuration = Duration(milliseconds: 3000);
const Duration tabBarAnimationDuration = Duration(milliseconds: 350);
const Duration snackBarDuration = Duration(seconds: 3);

// default value for country code in phone number field in signup screen
const String initialCountryCode = "+91";

const double borderRadius = 4.0;
const double bottomBarHeight = 80.0;
const int otpTimeOutSeconds = 60;

const int maxLimitOfWidgetsInHome = 10;
const int maxLimitOfBestSellersInHome = 5;

const int cachedMaxWidthAndHeight = 400;

const String defaultLanguageCode = 'en';

/// [Api limits constants]

const int limit = 15;

const appName = 'eShop Pro';
//Your package name
const String androidPackageName = 'daily2kart';
const String iosPackageName = 'com.wrteam.eshop.pro';
//Playstore link of your application
const String androidLink =
    'https://play.google.com/store/apps/details?id=$androidPackageName';

//Appstore link of your application
const String iosLink = 'https://testflight.apple.com/join/ZqKwNk27';

final storeUrl = Platform.isAndroid ? androidLink : iosLink;

const awaitingStatusType = 'awaiting';
const receivedStatusType = 'received';
const processedStatusType = 'processed';
const shippedStatusType = 'shipped';
const deliveredStatusType = 'delivered';
const cancelledStatusType = 'cancelled';
const returnedStatusType = 'returned';
const returnRequestPendingStatusType = 'return_request_pending';
const returnRequestApprovedStatusType = 'return_request_approved';
const returnRequestDeclineStatusType = 'return_request_decline';

String variableLevelStockMgmtType = 'variable_level';
String addStockUpdateType = 'add';
String subtractStockUpdateType = 'subtract';
String simpleOrderType = 'simple';
String digitalOrderType = 'digital';
String comboOrderType = "combo_order";
String imageMediaType = 'image';
String videoMediaType = 'video';

const String defaultTransactionType = 'transaction';
String walletTransactionType = 'wallet';
String creditType = 'credit';
String debitType = 'debit';
String successTxnStatus = 'Transaction successful';
String failureTxnStatus = 'Transaction failed';
String pendingTxnStatus = 'Transaction pending';
String cancelledTxnStatus = 'Transaction cancelled';
String succeededStatus = 'succeeded';
String pendingStatus = 'pending';
String capturedStatus = 'captured';

Map<String, String> orderStatusTypes = {
  awaitingStatusType: awaitingStatusType,
  receivedStatusType: receivedKey,
  processedStatusType: processedKey,
  shippedStatusType: onTheWayKey,
  deliveredStatusType: deliveredKey,
  cancelledStatusType: cancelledKey,
  returnedStatusType: returnedKey
};

const descendingOrder = 'desc';
const ascendingOrder = 'asc';
const int maxSearchHistory = 5;

const String selfHostedType = 'self_hosted';
const String youtubeVideoType = 'youtube';

const String keyNotifications = "notificationsKey";
const String pusherAppKey = '4b0e747a4edbac9e4e17';
const String pusherCluster = 'ap2';
String pusherChannelName = 'ezeemart.${AuthRepository.getUserDetails().id}';
