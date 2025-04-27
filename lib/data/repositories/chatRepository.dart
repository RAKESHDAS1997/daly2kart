import 'package:eshop_pro/data/models/chatMessage.dart';
import 'package:eshop_pro/data/models/userDetails.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/labelKeys.dart';

class ChatRepository {
  Future<({List<ChatMessage> messages, int total})> getMessages({
    required Map<String, dynamic> params,
  }) async {
    try {
      params.addAll({Api.limitApiKey: limit});

      final result = await Api.post(
          url: Api.chatifyFetchMessagesApi, useAuthToken: true, body: params);
      if (result['total'] == 0) {
        throw ApiException(dataNotAvailableKey);
      }
      return (
        messages: ((result['messages'] ?? []) as List)
            .map((msg) => ChatMessage.fromJson(Map.from(msg ?? {})))
            .toList(),
        total: int.parse((result['total'] ?? 0).toString()),
      );
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString(),
            errorCode: e
                .errorCode); // Re-throw the API exception with the backend message
      } else {
        // Handle any other exceptions
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<List<UserDetails>> getContacts({String? search}) async {
    try {
      String url = search != null && search.isNotEmpty
          ? Api.chatifySearchApi
          : Api.chatifyGetContactsApi;
      final result = await Api.get(
          url: url, useAuthToken: true, queryParameters: {'input': search});

      return url == Api.chatifyGetContactsApi
          ? ((result['contacts'] ?? []) as List)
              .map((user) => UserDetails.fromJson(Map.from(user ?? {})))
              .toList()
          : ((result['records'] ?? []) as List)
              .map((user) => UserDetails.fromJson(Map.from(user ?? {})))
              .toList();
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString(),
            errorCode: e
                .errorCode); // Re-throw the API exception with the backend message
      } else {
        // Handle any other exceptions
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<ChatMessage> sendMessage({
    required Map<String, dynamic> params,
  }) async {
    try {
      final result = await Api.post(
          url: Api.chatifySendMessageApi, useAuthToken: true, body: params);
      if (result['error']['status'] == 1) {
        throw ApiException(result['error']['message']);
      }
      return ChatMessage.fromJson(Map.from(result['message'] ?? {}));
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString(),
            errorCode: e
                .errorCode); // Re-throw the API exception with the backend message
      } else {
        // Handle any other exceptions
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<void> makeSeenMessage({
    required Map<String, dynamic> params,
  }) async {
    try {
      await Api.post(
          url: Api.chatifyMakeSeenApi, useAuthToken: true, body: params);
  
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString(),
            errorCode: e
                .errorCode); // Re-throw the API exception with the backend message
      } else {
        // Handle any other exceptions
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }
}
