import 'package:eshop_pro/app/app.dart';
import 'package:eshop_pro/app/routes.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  bool showNotification(String senderId) {
  
    if (currentChatUserId == senderId &&
        Get.currentRoute == Routes.chatScreen) {
      // Chat screen for this user is open, don't show notification
      return false;
    }
    return true;
  }
}
