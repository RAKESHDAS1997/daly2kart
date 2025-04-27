import 'package:eshop_pro/data/models/language.dart';
import 'package:eshop_pro/data/models/settings.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:eshop_pro/utils/hiveBoxKeys.dart';
import 'package:eshop_pro/utils/labelKeys.dart';

import 'package:hive_flutter/hive_flutter.dart';

class SettingsRepository {
  Future<void> setCurrentAppLanguage(Language value) async {
    try {
      await Hive.box(settingsBoxKey).put(currentAppLanguageKey, value.toJson());
    } catch (e) {
    
    }
  }


  Language getCurrentAppLanguage() {
    try {
      final languageValue = Hive.box(settingsBoxKey).get(currentAppLanguageKey);
     

      return Language.fromJson(Map.from(languageValue ?? {}));
    } catch (e) {
    
      return Language.fromJson({});
    }
  }

  Future<void> setOnBoardingScreen(bool value) async {
    Hive.box(authBoxKey).put(showOnBoardingScreenKey, value);
  }

  bool getOnBoardingScreen() {
    return Hive.box(authBoxKey).get(showOnBoardingScreenKey) ?? true;
  }

  Future<void> setFirstTimeUser(bool value) async {
    Hive.box(authBoxKey).put(isFirstTimeUserKey, value);
  }

  bool getFirstTimeUser() {
    return Hive.box(authBoxKey).get(isFirstTimeUserKey) ?? true;
  }

  Future<Settings> getSettings() async {
    try {
      final result = await Api.get(url: Api.getSettings, useAuthToken: false);

      return Settings.fromJson(Map.from(result['data'] ?? {}));
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<List<Language>> getLanguages() async {
    try {
      final result = await Api.get(url: Api.getLanguages, useAuthToken: false);

      return ((result['data'] ?? []) as List)
          .map((language) => Language.fromJson(Map.from(language ?? {})))
          .toList();
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<Map<String, String>> getLanguageLables(String languageCode) async {
    try {
      final result = await Api.get(
          url: Api.getLanguageLabels,
          queryParameters: {Api.languageCodeApiKey: languageCode},
          useAuthToken: false);

      return Map.from(result['data'] ?? {});
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }
}
