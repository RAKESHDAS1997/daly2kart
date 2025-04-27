import 'dart:async';

import 'package:eshop_pro/data/models/filterAttribute.dart';
import 'package:eshop_pro/data/models/product.dart';
import 'package:eshop_pro/data/models/productRating.dart';
import 'package:eshop_pro/data/models/searchedProduct.dart';
import 'package:eshop_pro/data/repositories/authRepository.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/hiveBoxKeys.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:hive/hive.dart';

class ProductRepository {
  final List<Product> _products = [];

  final _productStreamController = StreamController<List<Product>>.broadcast();

  Stream<List<Product>> get productStream => _productStreamController.stream;
  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      _productStreamController.add(_products);
    }
  }

  void toggleFavoriteStatus(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product.copyWith(isFavorite: product.isFavorite);
      _productStreamController.add(_products);
    }
  }

  void setProducts(List<Product> products) {
    _products.clear();
    _products.addAll(products);
    _productStreamController.add(_products);
  }

  List<Product> getUpdatedProducts() => _products;
  Future<
          ({
            List<Product> products,
            int total,
            List<FilterAttribute> filterAttributes,
            double minPrice,
            double maxPrice,
            String? categoryIds,
            String? brandIds
          })>
      getProducts(
          {required int storeId,
          String? apiUrl,
          int? productId,
          int? offset,
          String? sortBy,
          String? orderBy,
          int? topRatedProduct,
          int? sellerId,
          String? categoryIds,
          String? brandIds,
          List<int>? attributeValueIds,
          String? discount,
          String? rating,
          double? minPrice,
          double? maxPrice,
          List<int>? productIds,
          bool isComboProduct = false,
          String? zipcode,
          String? searchText}) async {
    try {
      Map<String, dynamic> queryParameters = {
        Api.userIdApiKey: AuthRepository.getUserDetails().id,
        Api.storeIdApiKey: storeId,
        Api.productIdApiKey: productId,
        Api.offsetApiKey: offset ?? 0,
        Api.limitApiKey: limit,
        Api.sortByApiKey: sortBy,
        Api.orderByApiKey: orderBy,
        Api.sellerIdApiKey: sellerId,
        Api.categoryIdApiKey: categoryIds,
        Api.brandIdApiKey: brandIds,
        Api.attributeValuesIdsApiKey: attributeValueIds,
        Api.discountApiKey: discount,
        Api.ratingApiKey: rating,
        Api.minPriceApiKey: minPrice,
        Api.maxPriceApiKey: maxPrice,
      };
      if (isComboProduct &&
          queryParameters.containsKey(Api.sortByApiKey) &&
          queryParameters[Api.sortByApiKey] == "pv.price") {
        queryParameters.addAll({Api.sortByApiKey: "p.price"});
      }
      if (searchText != null) {
        queryParameters.addAll({Api.searchApiKey: searchText});
      }
      if (productIds != null && productIds.isNotEmpty) {
        queryParameters.addAll({Api.productIdsApiKey: productIds.join(',')});
      }
      if (sortBy == null) {
        queryParameters.remove(Api.sortByApiKey);
      }
      if (orderBy == null) {
        queryParameters.remove(Api.orderByApiKey);
      }
      if (topRatedProduct != null) {
        queryParameters.addAll({Api.productTypeApiKey: 'top_rated_products'});
      }
      if (sellerId == null) {
        queryParameters.remove(Api.sellerIdApiKey);
      }

      if (categoryIds == null) {
        queryParameters.remove(Api.categoryIdApiKey);
      }

      if (brandIds == null) {
        queryParameters.remove(Api.brandIdApiKey);
      }

      if (attributeValueIds == null) {
        queryParameters.remove(Api.attributeValuesIdsApiKey);
      }

      if (discount == null) {
        queryParameters.remove(Api.discountApiKey);
      }
      if (rating == null) {
        queryParameters.remove(Api.ratingApiKey);
      }

      if (minPrice == null) {
        queryParameters.remove(Api.minPriceApiKey);
      }
      if (maxPrice == null) {
        queryParameters.remove(Api.maxPriceApiKey);
      }
      if (zipcode != null) {
        queryParameters.addAll({Api.zipCodeApiKey: zipcode});
      }
     

      final result = await Api.get(
          url:
              isComboProduct ? Api.getComboProducts : apiUrl ?? Api.getProducts,
          useAuthToken: false,
          queryParameters: queryParameters);

      return (
        products: ((result['data'] ?? []) as List)
            .map((product) => Product.fromJson(Map.from(product ?? {})))
            .where((product) =>
                product.type == comboProductType ||
                (product.type != comboProductType &&
                    product.variants != null &&
                    product.variants!
                        .isNotEmpty)) // Filter products with non-empty variants
            .toList(),
        total: int.parse((result['total'] ?? 0).toString()),
        filterAttributes: (result['filters'] as List?)
                ?.map((filterAttributes) =>
                    FilterAttribute.fromJson(Map.from(filterAttributes ?? {})))
                .toList() ??
            List<FilterAttribute>.from([]),
        minPrice: double.parse(result['min_price']?.toString() ?? '0'),
        maxPrice: double.parse(result['max_price']?.toString() ?? '0'),
        categoryIds: result['category_ids']?.toString(),
        brandIds: result['brand_ids']?.toString(),
      );
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<List<Product>> getMostSellingProducts(
      {required int storeId, required int userId, String? zipcode}) async {
    try {
      Map<String, dynamic>? params = {
        Api.storeIdApiKey: storeId,
        Api.userIdApiKey: userId,
      };
      if (zipcode != null && zipcode.isNotEmpty) {
        params[Api.zipCodeApiKey] = zipcode;
      }
      final result = await Api.get(
          url: Api.getMostSellingProducts,
          useAuthToken: true,
          queryParameters: params);
      return ((result['data'] ?? []) as List).map((model) {
        return Product.fromMostSellingProductJson(model);
      }).where((product) {
        if (zipcode != null) {
          if (product.isDeliverable == true)
            return true;
          else
            return false;
        } else {
          return true;
        }
      }).toList();
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<({ProductRating productRating, int total})> getProductRatings({
    required Map<String, dynamic> params,
    required String apiUrl,
  }) async {
    try {
      if (!params.containsKey(Api.limitApiKey)) {
        params.addAll({Api.limitApiKey: limit});
      }
      final result = await Api.get(
          url: apiUrl, useAuthToken: true, queryParameters: params);

      return (
        productRating: ProductRating.fromJson(Map.from(result)),
        total: int.parse((result['total'] ?? 0).toString()),
      );
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<List<SearchedProduct>> getSearchProducts(
      {required int storeId, required String query}) async {
    try {
      final result =
          await Api.post(url: Api.searchProducts, useAuthToken: false, body: {
        Api.storeIdApiKey: storeId,
        Api.searchApiKey: query,
      });

      return ((result['data'] ?? []) as List)
          .map((product) => SearchedProduct.fromJson(Map.from(product ?? {})))
          .toList();
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<List<String>> getMostSearchedProducts({required int storeId}) async {
    try {
      final result = await Api.post(
          url: Api.getMostSearchedHistory,
          useAuthToken: false,
          body: {
            Api.storeIdApiKey: storeId,
          });

      return ((result['data'] ?? []) as List)
          .map((text) => text['search_term'].toString())
          .toList();
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<String> checkProductDeliverability(
      {required Map<String, dynamic> params}) async {
    try {
      final result = await Api.post(
          url: Api.isProductDelivarable, useAuthToken: true, body: params);

      return result['message'];
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<({RatingData productRating, String successMessage})> setProductReview(
      {required Map<String, dynamic> params, required String apiUrl}) async {
    try {
      final result =
          await Api.post(url: apiUrl, useAuthToken: true, body: params);
      var filteredRatings = (result['data']['product_rating'] ?? [])
          .where((rating) =>
              rating['user_id'] == AuthRepository.getUserDetails().id)
          .toList();
      return (
        productRating: RatingData.fromJson(
            Map.from(filteredRatings.isNotEmpty ? filteredRatings.first : {})),
        successMessage: result['message'].toString(),
      );
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  addSearchInLocalHistory(String query) {
    final searchBox = Hive.box(searchBoxKey);
    List<String> currentHistory = searchBox.values.toList().cast<String>();

// Check if the search query is already in the history
    if (!currentHistory.contains(query)) {
      // If the history has reached the maximum limit, remove the oldest entry
      if (currentHistory.length >= maxSearchHistory) {
        searchBox.deleteAt(0);
      }

      // Add the new query to the beginning of the box
      searchBox.add(query);
    }
  }

  getSearchHistory() {
    return Hive.box(searchBoxKey).values.toList().reversed.toList();
  }

  clearSearchHistory() {
    Hive.box(searchBoxKey).clear();
  }
}
