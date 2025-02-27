import 'dart:convert';
import 'package:eshop_pro/data/models/notification.dart';
import 'package:eshop_pro/data/repositories/authRepository.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRepository {
  Future<
      ({
        List<Notifications> notifications,
        int total,
      })> getNotifications({
    int? offset,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {
        Api.offsetApiKey: offset ?? 0,
        Api.limitApiKey: limit,
        Api.userIdApiKey: AuthRepository.getUserDetails().id,
      };

      final result = await Api.get(
          url: Api.getNotifications,
          useAuthToken: true,
          queryParameters: queryParameters);
      return (
  
        notifications: ((result['data'] ?? []) as List)
            .map((notification) =>
                Notifications.fromJson(Map.from(notification ?? {})))
            .toList(),
        total: int.parse((result['total'] ?? 0).toString()),
      );
    } catch (e) {
      // If an error occurs, check if it's an ApiException or a different type of error
      if (e is ApiException) {
        throw ApiException(e
            .toString()); // Re-throw the API exception with the backend message
      } else {
        // Handle any other exceptions
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  void addNotification(Map<String, dynamic> data) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.reload();
    List<String> notifications =
        sharedPreferences.getStringList(keyNotifications) ??
            List<String>.from([]);

    notifications.add(jsonEncode(data));

    await sharedPreferences.setStringList(keyNotifications, notifications);
  }

  Future<List<Map<String, dynamic>>> getBGNotifications() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.reload();
    List<String> notifications =
        sharedPreferences.getStringList(keyNotifications) ??
            List<String>.from([]);

    return notifications
        .map((notificationData) =>
            Map<String, dynamic>.from(jsonDecode(notificationData) ?? {}))
        .toList();
  }

  Future<void> clearNotification() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setStringList(keyNotifications, []);
  }
}
