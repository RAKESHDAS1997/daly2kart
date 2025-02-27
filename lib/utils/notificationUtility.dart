import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eshop_pro/app/app.dart';
import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/category/category_cubit.dart';
import 'package:eshop_pro/cubits/order/orderCubit.dart';
import 'package:eshop_pro/cubits/storesCubit.dart';
import 'package:eshop_pro/cubits/transaction/transactionCubit.dart';
import 'package:eshop_pro/cubits/user_details_cubit.dart';
import 'package:eshop_pro/data/models/order.dart';
import 'package:eshop_pro/data/models/product.dart';
import 'package:eshop_pro/data/repositories/notificationRepository.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/productDetailsScreen.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../data/repositories/authRepository.dart';

class NotificationUtility {
  static void initFirebaseState(BuildContext context) async {
    if (!context.read<UserDetailsCubit>().isGuestUser()) {
      String fcmToken = await AuthRepository.getFcmToken();
      
      if (context.read<UserDetailsCubit>().getuserDetails().fcmId != null &&
          context.read<UserDetailsCubit>().getuserDetails().fcmId!.isNotEmpty &&
          !context
              .read<UserDetailsCubit>()
              .getuserDetails()
              .fcmId!
              .contains(fcmToken) &&
          fcmToken.isNotEmpty) {
        AuthRepository().updateFcmId({
          Api.userIdApiKey: AuthRepository.getUserDetails().id,
          Api.fcmIdApiKey: fcmToken
        });
      }
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onBackgroundMessage(RemoteMessage message) async {
    if (message.data.isNotEmpty) {
  
      NotificationRepository().addNotification(message.data);
    }
  }

  static void _onTapNotificationScreenNavigateCallback(
      {required Map<String, dynamic>? notificationData,
      required BuildContext context}) {
    if (notificationData == null) {
      return;
    }
    Map<String, dynamic> data = notificationData;
    String? type = data['type'];
    if (type != null) {
      if (type == 'message' &&
          chatController.showNotification(data['user_id'])) {
        currentChatUserId = data['user_id'];

        Utils.navigateToScreen(
          context,
          Routes.chatScreen,
          replacePrevious: Get.currentRoute == Routes.chatScreen ? true : false,
          arguments: int.parse(data['user_id']),
        );
      }
      if (type == 'wallet') {
        Utils.navigateToScreen(context, Routes.walletScreen);
      }
      if (type == 'order') {
        if (Get.currentRoute != Routes.myOrderScreen &&
            Get.currentRoute != Routes.orderDetailsScreen) {
          Utils.navigateToScreen(context, Routes.orderDetailsScreen,
              arguments: {
                'storeId': int.tryParse(data['store_id']),
                'order': Order(id: int.parse(data['order_id'])),
                'orderId': int.parse(data['order_id']),
              },
              replacePrevious: true);
        }
      }
      if (type == 'default') {}
      if (type == 'notification_url' && data['link'].isNotEmpty) {
        Utils.launchURL(data['link'].toString());
      }
      if (type == 'products') {
        Utils.navigateToScreen(
          context,
          Routes.productDetailsScreen,
          arguments: ProductDetailsScreen.buildArguments(
              storeId: int.tryParse(data['store_id']),
              product: Product(id: int.parse(data['type_id'])),
              productIds: [int.parse(data['type_id'])]),
        );
      }

      if (type == 'categories') {
        if (data['type_id'] != null) {
          Utils.navigateToScreen(context, Routes.categoryScreen,
                  replacePrevious:
                      Get.currentRoute == Routes.categoryScreen ? true : false,
                  arguments: {
                'storeId': int.tryParse(data['store_id']),
                'categoryId': int.parse(data['type_id']),
                'shouldPop': true
              })!
              .then((value) => context.read<CategoryCubit>().fetchCategories(
                  storeId: context.read<StoresCubit>().getDefaultStore().id!,
                  search: ''));
       
        }
      }
    }
  }

  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  

  //Ask notification permission here
  static Future<NotificationSettings> _getNotificationPermission() async {
    return await FirebaseMessaging.instance.requestPermission(
      alert: false,
      announcement: false,
      badge: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
  }

  static Future<void> setUpNotificationService(BuildContext context) async {
    NotificationSettings notificationSettings =
        await FirebaseMessaging.instance.getNotificationSettings();

    //ask for permission
    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      notificationSettings = await _getNotificationPermission();

      //if permission is provisionnal or authorised
      if (notificationSettings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          notificationSettings.authorizationStatus ==
              AuthorizationStatus.provisional) {
        _initNotificationListener(context);
      }

      //if permission denied
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.denied) {
      //If user denied then ask again
      notificationSettings = await _getNotificationPermission();
      if (notificationSettings.authorizationStatus ==
          AuthorizationStatus.denied) {
        return;
      }
    }
    _initNotificationListener(context);
  }

  static void _initNotificationListener(BuildContext context) {
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen((remoteMessage) {
      foregroundMessageListener(remoteMessage, context);
    });
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((remoteMessage) {
      onMessageOpenedAppListener(remoteMessage, context);
    });

    FirebaseMessaging.instance.getInitialMessage().then((value) {
      _onTapNotificationScreenNavigateCallback(
          notificationData: value?.data ?? {}, context: context);
    });

    if (!kIsWeb) {
      _initLocalNotification(context);
    }
  }

  static displayNotification(
      String title, String body, String image, Map additionalData) async {
    createLocalNotification(
        dismissable: true,
        imageUrl: image,
        title: title,
        body: body,
        payload: jsonEncode(additionalData));
  }

  static onReceiveNotification(
      Map<String, dynamic> data, BuildContext context) {
    var type = data['type'];
    if (type != null) {
      if (type == 'wallet' && Get.currentRoute == Routes.walletScreen) {
        context.read<TransactionCubit>().getTransaction(
            userId: context.read<UserDetailsCubit>().getUserId(),
            transactionType: walletTransactionType,
            type: creditType);
      }
    }
    if (type == 'order' &&
        (Get.currentRoute == Routes.myOrderScreen ||
            Get.currentRoute == Routes.orderDetailsScreen)) {
  

      context
          .read<OrdersCubit>()
          .addOrder(int.parse(data['order_id']), context);
    }
  }

  static void foregroundMessageListener(
      RemoteMessage message, BuildContext context) async {
    final additionalData = message.data;
    RemoteNotification notification = message.notification!;
    var title = notification.title ?? '';
    var body = notification.body ?? '';
    var image = message.data['image'] ?? '';
    if (message.data['type'] == 'message') {
      if (chatController.showNotification(message.data['user_id'])) {
        displayNotification(title, body, image, additionalData);
      }
    } else {
      displayNotification(title, body, image, additionalData);
      onReceiveNotification(message.data, context);
    }
  }

  static void onMessageOpenedAppListener(
      RemoteMessage remoteMessage, BuildContext context) {
    _onTapNotificationScreenNavigateCallback(
        notificationData: remoteMessage.data, context: context);
  }

  static void _initLocalNotification(BuildContext context) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    InitializationSettings initializationSettings =
        const InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    _requestPermissionsForIos();
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        _onTapNotificationScreenNavigateCallback(
            notificationData:
                Map<String, dynamic>.from(jsonDecode(details.payload ?? "")),
            context: context);
      },
    );
  }

  static Future<void> _requestPermissionsForIos() async {
    if (Platform.isIOS) {
      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions();
    }
  }

  static Future<void> createLocalNotification(
      {required String title,
      required bool dismissable, //User can clear it
      required String body,
      required String imageUrl,
      required String payload}) async {
    late AndroidNotificationDetails androidPlatformChannelSpecifics;
    if (imageUrl.isNotEmpty) {
      final downloadedImagePath = await _downloadAndSaveFile(imageUrl);
      if (downloadedImagePath.isEmpty) {
        //If somwhow failed to download image
        androidPlatformChannelSpecifics = AndroidNotificationDetails(
            androidPackageName, //channel id
            'Local notification', //channel name
            importance: Importance.max,
            priority: Priority.high,
            ongoing: !dismissable,
            ticker: 'ticker');
      } else {
        var bigPictureStyleInformation = BigPictureStyleInformation(
            FilePathAndroidBitmap(downloadedImagePath),
            hideExpandedLargeIcon: false,
            contentTitle: title,
            htmlFormatContentTitle: true,
            summaryText: title,
            htmlFormatSummaryText: true);

        androidPlatformChannelSpecifics = AndroidNotificationDetails(
            androidPackageName, //channel id
            'Local notification', //channel name
            importance: Importance.max,
            priority: Priority.high,
            largeIcon: FilePathAndroidBitmap(downloadedImagePath),
            styleInformation: bigPictureStyleInformation,
            ongoing: !dismissable,
            ticker: 'ticker');
      }
    } else {
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
          androidPackageName, //channel id
          'Local notification', //channel name
          importance: Importance.max,
          priority: Priority.high,
          ongoing: !dismissable,
          ticker: 'ticker');
    }
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iosNotificationDetails);
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: payload);
  }

  static Future<String> _downloadAndSaveFile(String url) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/temp.jpg';

    try {
      await Api.download(
          url: url,
          cancelToken: CancelToken(),
          savePath: filePath,
          updateDownloadedPercentage: (value) {});

      return filePath;
    } catch (e) {
      return "";
    }
  }
}
