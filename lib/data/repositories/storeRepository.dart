import 'package:eshop_pro/data/models/store.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:eshop_pro/utils/hiveBoxKeys.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:hive/hive.dart';

class StoreRepository {
  Future<List<Store>> getStores() async {
    try {
      final result = await Api.get(url: Api.getStores, useAuthToken: false);

      return ((result['data'] ?? []) as List)
          .map((store) => Store.fromJson(Map.from(store ?? {})))
          .toList();
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  int getDefaultStoreId() {
    return Hive.box(settingsBoxKey).get(defaultStoreIdKey) ?? 0;
  }

  Future<void> setDefaultStoreId({required int storeId}) async {
   
    Hive.box(settingsBoxKey).put(defaultStoreIdKey, storeId);
  }
}
