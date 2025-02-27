import 'dart:convert';

import 'package:eshop_pro/app/app.dart';
import 'package:eshop_pro/cubits/chat/getMessageCubit.dart';
import 'package:eshop_pro/cubits/settingsAndLanguagesCubit.dart';
import 'package:eshop_pro/data/models/chatMessage.dart';
import 'package:eshop_pro/data/repositories/authRepository.dart';
import 'package:eshop_pro/ui/screens/profile/customerSupport/chatScreen.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherService {
  final PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  late String socketId;
  PusherChannel? channel;

  Future<void> initPusher(
      BuildContext context, GetMessageCubit getMessageCubit) async {
    try {
      await pusher.init(
        apiKey: context.read<SettingsAndLanguagesCubit>().getPusherAppKey(),
        cluster: context.read<SettingsAndLanguagesCubit>().getPusherCluster(),
        onConnectionStateChange: (currentState, previousState) async {
          if (currentState == 'CONNECTED') {
            // Once connected, retrieve the socketId
            socketId = await pusher.getSocketId();
          }
        },
        onError: (message, code, exception) {
       
        },
        onSubscriptionSucceeded: (channelName, data) {
        
        },
        onEvent: (event) {
        
          if (event.eventName == 'messaging' &&
              jsonDecode(event.data)['from_id'].toString() ==
                  currentChatUserId.toString()) {
            getMessageCubit.emitSuccessState(
                ChatMessage.fromJson(jsonDecode(event.data)['message']));
          }
        },
      );
      // Connect to Pusher
      await pusher.connect();
      pusherChannel = await pusher.subscribe(
          channelName:
              context.read<SettingsAndLanguagesCubit>().getPusherChannerName());
    } catch (e) {
     
    }
  }

  disconnectPusher(String channelName) {
    pusher.unsubscribe(channelName: channelName);
    pusher.disconnect();
  }

  Future<void> sendMessage(String message) async {
    await Api.post(
        url: Api.chatifySendMessageApi,
        body: {
          "from_id": AuthRepository.getUserDetails().id,
          "id": 1,
          "type": "user",
          "message": message
        },
        useAuthToken: true);
  }
}
