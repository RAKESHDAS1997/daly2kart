import 'dart:async';
import 'dart:math';
import 'package:eshop_pro/data/models/userDetails.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/hiveBoxKeys.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthRepository {
  int count = 1;
  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _firebaseAuth = FirebaseAuth.instance;
  Future<void> signOutUser(BuildContext context, String userType) async {
    String fcm = await AuthRepository.getFcmToken();
    try {
      await updateFcmId({Api.fcmIdApiKey: fcm, 'is_delete': 1});
      await FirebaseAuth.instance.signOut();
      if (userType == googleLoginType) {
        await _googleSignIn.signOut();
      }

      await removeSessionData();
    } catch (e) {
      Utils.showSnackBar(message: e.toString(), context: context);
    }
  }

  removeSessionData() async {
    await Hive.box(authBoxKey).delete(isLogInKey);
    await Hive.box(authBoxKey).delete(userDetailsKey);
    await Hive.box(authBoxKey).delete(tokenKey);
    await Hive.box(authBoxKey).delete(defaultStoreIdKey);
    await Hive.box(settingsBoxKey).clear();
    await Hive.box(productsBoxKey).clear();
  }

  static bool getIsLogIn() {
    return Hive.box(authBoxKey).get(isLogInKey) ?? false;
  }

  Future<void> setIsLogIn(bool value) async {
    return Hive.box(authBoxKey).put(isLogInKey, value);
  }

  static UserDetails getUserDetails() {
    return UserDetails.fromJson(
        Map.from(Hive.box(authBoxKey).get(userDetailsKey) ?? {}));
  }

  Future<void> setUserDetails(UserDetails value) async {
    return Hive.box(authBoxKey).put(userDetailsKey, value.toJson());
  }

  Future<void> setToken(String value) async {
    return Hive.box(authBoxKey).put(tokenKey, value);
  }

  static String getToken() {
    return Hive.box(authBoxKey).get(tokenKey) ?? '';
  }

  static Future<String> getFcmToken() async {
    try {
      return (await FirebaseMessaging.instance.getToken()) ?? "";
    } catch (e) {
      return "";
    }
  }

  Future<String> registerUser({required Map<String, dynamic> params}) async {
    try {
      final result = await Api.post(
          body: params, url: Api.registerUser, useAuthToken: false);

      return result['message'];
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<({String token, UserDetails userDetails})> signUp(
      String loginType) async {
    try {
      String fcm = await AuthRepository.getFcmToken();
      User? user;
      if (loginType == googleLoginType) {
        user = await signInWithGoogle();
      } else {
        user = await signInWithApple();
      }
      if (user != null) {
        final result = await Api.post(
          url: Api.signUp,
          useAuthToken: false,
          body: {
            Api.nameApiKey: user.displayName ?? '',
            Api.emailApiKey: user.email ?? user.providerData.first.email ?? '',
            Api.imageApiKey: user.photoURL ?? '',
            Api.mobileApiKey: user.phoneNumber ?? '',
            Api.fcmIdApiKey: fcm,
            Api.typeApiKey: loginType
          },
        );
        return (
          token: result['token'].toString(),
          userDetails: UserDetails.fromJson(Map.from(result['data'] ?? {}))
        );
      }
      throw ApiException(defaultErrorMessageKey);
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<Map<String, dynamic>> loginUser(
      {required Map<String, dynamic> params}) async {
    try {
      final result =
          await Api.post(body: params, url: Api.login, useAuthToken: false);

      return {
        'token': result['token'],
        'userDetails': UserDetails.fromJson(Map.from(result['user'] ?? {}))
      };
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<({String token, UserDetails userDetails})> verifyUser(
      {required Map<String, dynamic> params}) async {
    try {
      print('call verify user');

      final result = await Api.post(
          body: params, url: Api.verifyUser, useAuthToken: false);

      return (
        token: result['token'].toString(),
        userDetails: UserDetails.fromJson(Map.from(result['user'] ?? {}))
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

  Future<({String successMessage, UserDetails userDetails})> updateUser(
      {required Map<String, dynamic> params}) async {
    try {
      final result =
          await Api.post(body: params, url: Api.updateUser, useAuthToken: true);

      return (
        successMessage: result['message'].toString(),
        userDetails: UserDetails.fromJson(Map.from(result['data'][0] ?? {}))
      );
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<String> verifyOtp({required Map<String, dynamic> params}) async {
    try {
      final result =
          await Api.post(body: params, url: Api.verifyOtp, useAuthToken: false);

      return result['message'];
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<String> resendOtp({required Map<String, dynamic> params}) async {
    try {
      final result =
          await Api.post(body: params, url: Api.resendOtp, useAuthToken: false);

      return result['message'];
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<String> setNewPassword({required Map<String, dynamic> params}) async {
    try {
      final result = await Api.post(
          body: params, url: Api.resetPassword, useAuthToken: false);

      return result['message'];
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<User?> signInWithGoogle() async {
    UserCredential? userCredential;
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        userCredential = await _firebaseAuth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw ApiException(accountExistGoogleErrorMessageKey);
      } else if (e.code == 'invalid-credential') {
        throw ApiException(errorInCredentialsErrorMessageKey);
      }
    } catch (e) {
      throw ApiException(errorInSiginnGoogleErrorMessageKey);
    }
    if (userCredential != null) {
      return userCredential.user;
    }
    return null;
  }

  Future<User?> signInWithApple() async {
    UserCredential? userCredential;
    User? updatedUser;
    final authProvider = OAuthProvider('apple.com');
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = authProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);
      if (userCredential.additionalUserInfo!.isNewUser) {
        final user = userCredential.user!;

        final String givenName = credential.givenName ?? "";

        final String familyName = credential.familyName ?? "";
        await user.updateDisplayName("$givenName $familyName");

        await user.reload();
      }
      updatedUser = _firebaseAuth.currentUser;
    } on SignInWithAppleCredentialsException catch (e) {
      throw ApiException(e.message);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw ApiException(appleLoginCancelledErrorMsg);
      } else if (e.code == AuthorizationErrorCode.failed) {
        throw ApiException(defaultErrorMessageKey);
      }
    }
    return updatedUser;
  }

  Future<void> updateFcmId(Map<String, dynamic> params) async {
    try {
      await Api.put(
          url: Api.updateFcm, queryParameters: params, useAuthToken: true);
    } catch (e) {
      if (e is ApiException) {
        // throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<String> deleteAccount({required Map<String, dynamic> params}) async {
    try {
      final result = await Api.post(
          url: Api.deleteUserAccount, useAuthToken: true, body: params);

      return result['message'];
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<String> deleteSocialAccount() async {
    String message = '';
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        await FirebaseAuth.instance.currentUser!.delete();
        final result = await Api.delete(
          url: Api.deleteSocialAccount,
          useAuthToken: true,
        );

        return result['message'];
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          throw ApiException(requireRecentLoginErrorMessageKey);
        }
      }
      return message;
    }
    throw ApiException(requireRecentLoginErrorMessageKey);
  }

  Future<String> generateReferralCode() async {
    String referCode = getRandomString(8);

    try {
      bool error = await validateReferal(referCode: referCode);

      if (!error) {
        return referCode;
      } else {
        if (count < 5) {
          generateReferralCode();
        }
        count++;
      }
    } on TimeoutException catch (_) {
      throw ApiException(defaultErrorMessageKey);
    }
    throw ApiException(defaultErrorMessageKey);
  }

  String getRandomString(int length) => String.fromCharCodes(
        Iterable.generate(
          length,
          (_) => _chars.codeUnitAt(
            _rnd.nextInt(
              _chars.length,
            ),
          ),
        ),
      );
  //validate referl code
  static Future<bool> validateReferal({
    required String referCode,
  }) async {
    final result =
        await Api.post(url: Api.validateReferCode, useAuthToken: true, body: {
      Api.referralCodeApiKey: referCode,
    });
    return result['error'];
  }
}
