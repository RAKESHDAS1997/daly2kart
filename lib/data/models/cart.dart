import 'package:eshop_pro/data/models/address.dart';
import 'package:eshop_pro/data/models/paymentMethod.dart';
import 'package:eshop_pro/data/models/product.dart';
import 'package:eshop_pro/data/models/productVariant.dart';
import 'package:eshop_pro/data/models/promoCode.dart';
import 'package:get/get.dart';

class Cart {
  String? totalQuantity;
  double? subTotal;
  double? itemTotal;
  double? discount;

  double? deliveryCharge;
  double? taxPercentage;
  double? taxAmount;
  double? overallAmount;
  double? originalOverallAmount;
  double? totalArr;
  List<int>? variantId;
  List<CartProduct>? cartProducts;
  List<CartProduct>? saveForLaterProducts;
  List<PromoCode>? promoCodes;
  double? couponDiscount;
  PromoCode? promoCode;
  String? deliveryInstruction;
  String? emailAddress;
  PaymentModel? selectedPaymentMethod;
  Address? selectedAddress;
  bool? useWalletBalance = false;
  double? walletAmount;
  String? stripePayId;
  Cart(
      {this.totalQuantity,
      this.subTotal,
      this.itemTotal,
      this.discount,
      this.couponDiscount,
      this.promoCode,
      this.deliveryCharge,
      this.taxPercentage,
      this.taxAmount,
      this.overallAmount,
      this.originalOverallAmount,
      this.totalArr,
      this.variantId,
      this.promoCodes,
      this.cartProducts,
      this.saveForLaterProducts,
      this.deliveryInstruction,
      this.selectedPaymentMethod,
      this.emailAddress,
      this.selectedAddress,
      this.useWalletBalance,
      this.walletAmount,
      this.stripePayId});

  Cart.fromJson(Map<String, dynamic> json) {
    totalQuantity = json['total_quantity'];
    subTotal = double.tryParse((json['sub_total'] ?? 0).toString().isEmpty
        ? "0"
        : (json['sub_total'] ?? 0).toString());
    itemTotal = double.tryParse((json['item_total'] ?? 0).toString().isEmpty
        ? "0"
        : (json['item_total'] ?? 0).toString());
    discount = double.tryParse((json['discount'] ?? 0).toString().isEmpty
        ? "0"
        : (json['discount'] ?? 0).toString());
    couponDiscount = double.tryParse(
        (json['coupon_discount'] ?? 0).toString().isEmpty
            ? "0"
            : (json['coupon_discount'] ?? 0).toString());
    deliveryCharge = double.tryParse(
        (json['delivery_charge'] ?? 0).toString().isEmpty
            ? "0"
            : (json['delivery_charge'] ?? 0).toString());

    taxPercentage = double.tryParse(
        (json['tax_percentage'] ?? 0).toString().isEmpty
            ? "0"
            : (json['tax_percentage'] ?? 0).toString());
    taxAmount = double.tryParse((json['tax_amount'] ?? 0).toString().isEmpty
        ? "0"
        : (json['tax_amount'] ?? 0).toString());

    overallAmount = double.tryParse(
            (json['overall_amount'] ?? 0).toString().isEmpty
                ? "0"
                : (json['overall_amount'] ?? 0).toString()) ??
        0;
    originalOverallAmount =
        overallAmount; // we will use this param to restore the original overall amount when remove promo code
    useWalletBalance = false;
    totalArr = double.tryParse((json['total_arr'] ?? 0).toString().isEmpty
        ? "0"
        : (json['total_arr'] ?? 0).toString());

    variantId =
        json['variant_id'] != null ? json['variant_id'].cast<int>() : [];
    cartProducts = <CartProduct>[];
    saveForLaterProducts = <CartProduct>[];
    if (json['cart'] != null) {
      json['cart'].forEach((v) {
        cartProducts!.add(CartProduct.fromJson(v));
      });
    }
    if (json['promo_codes'] != null) {
      promoCodes = <PromoCode>[];
      json['promo_codes'].forEach((v) {
        promoCodes!.add(PromoCode.fromJson(v));
      });
    }
  }
  Cart copyWith({
    String? totalQuantity,
    double? subTotal,
    double? deliveryCharge,
    double? taxPercentage,
    double? taxAmount,
    double? overallAmount,
    double? totalArr,
    List<int>? variantId,
    List<CartProduct>? cartProducts,
    List<CartProduct>? saveForLaterProducts,
    List<PromoCode>? promoCodes,
  }) {
    return Cart(
      totalQuantity: totalQuantity ?? this.totalQuantity,
      subTotal: subTotal ?? this.subTotal,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      taxAmount: taxAmount ?? this.taxAmount,
      overallAmount: overallAmount ?? this.overallAmount,
      totalArr: totalArr ?? this.totalArr,
      variantId: variantId ?? this.variantId,
      cartProducts: cartProducts ?? this.cartProducts,
      saveForLaterProducts: saveForLaterProducts ?? this.saveForLaterProducts,
      promoCodes: promoCodes ?? this.promoCodes,
    );
  }

  updateProductDetails(int cartProductId, Product product) {
    if (cartProducts != null) {
      CartProduct? cartProduct = cartProducts!.firstWhereOrNull(
        (product) => product.id == cartProductId,
      );
      if (cartProduct != null) {
        cartProduct.productDetails![0] = product;
      }
    }
  }
}

class CartProduct {
  int? id;
  int? userId;
  int? storeId;
  int? productVariantId;
  String? productIds;
  int? qty;
  int? isSavedForLater;
  String? productType;
  String? createdAt;
  String? updatedAt;
  int? cartId;
  String? cartProductType;
  int? isPricesInclusiveTax;
  String? name;
  String? type;
  String? productSlug;
  String? image;
  String? shortDescription;
  int? sellerId;
  int? minimumOrderQuantity;
  int? quantityStepSize;
  String? pickupLocation;
  String? weight;
  int? totalAllowedQuantity;
  double? price;
  double? specialPrice;
  String? taxPercentage;
  int? minimumFreeDeliveryOrderQty;
  String? productDeliveryCharge;
  bool? removeProductInProgress;

  String? netAmount;
  String? taxAmount;
  double? subTotal;
  List<ProductVariant>? productVariants;
  List<Product>? productDetails;
  String? errorMessage;
  CartProduct(
      {this.id,
      this.userId,
      this.storeId,
      this.productVariantId,
      this.productIds,
      this.qty,
      this.isSavedForLater,
      this.productType,
      this.createdAt,
      this.updatedAt,
      this.cartId,
      this.cartProductType,
      this.isPricesInclusiveTax,
      this.name,
      this.type,
      this.productSlug,
      this.image,
      this.shortDescription,
      this.sellerId,
      this.minimumOrderQuantity,
      this.quantityStepSize,
      this.pickupLocation,
      this.weight,
      this.totalAllowedQuantity,
      this.price,
      this.specialPrice,
      this.taxPercentage,
      this.minimumFreeDeliveryOrderQty,
      this.productDeliveryCharge,
      this.netAmount,
      this.taxAmount,
      this.subTotal,
      this.productVariants,
      this.productDetails,
      this.removeProductInProgress,
      this.errorMessage});

  CartProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    storeId = json['store_id'];
    productVariantId = json['product_variant_id'];
    productIds = json['product_ids'];
    qty = json['qty'];
    isSavedForLater = json['is_saved_for_later'];
    productType = json['product_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    cartId = json['cart_id'];
    cartProductType = json['cart_product_type'];
    isPricesInclusiveTax = json['is_prices_inclusive_tax'];
    name = json['name'];
    type = json['type'];
    productSlug = json['product_slug'];
    image = json['image'];
    shortDescription = json['short_description'];
    sellerId = json['seller_id'];
    minimumOrderQuantity = json['minimum_order_quantity'];
    quantityStepSize = json['quantity_step_size'];
    pickupLocation = json['pickup_location'];
    weight = json['weight'].toString();
    totalAllowedQuantity = json['total_allowed_quantity'];
    price = double.parse((json['price'] ?? 0.0).toString());
    specialPrice = double.parse((json['special_price'] ?? 0.0).toString());
    taxPercentage = json['tax_percentage'];
    minimumFreeDeliveryOrderQty = json['minimum_free_delivery_order_qty'];
    productDeliveryCharge = json['product_delivery_charge'].toString();

    netAmount = json['net_amount'];

    taxAmount = json['tax_amount'];

    subTotal = double.parse((json['sub_total'] ?? 0.0).toString());

    if (json['product_variants'] != null && json['product_variants'] != '') {
      productVariants = <ProductVariant>[];
      json['product_variants'].forEach((v) {
        productVariants!.add(ProductVariant.fromJson(v));
      });
    }
    if (json['product_details'] != null) {
      productDetails = <Product>[];
      json['product_details'].forEach((v) {
        Product product = Product.fromJson(v);
        if (product.type == comboProductType ||
            (product.type != comboProductType &&
                product.variants != null &&
                product.variants!.isNotEmpty)) {
          productDetails!.add(product);
        }
      });
    }
    removeProductInProgress = false;
  }
  double getDiscoutPercentage() {
    if (specialPrice != 0.0) {
      return ((price! - specialPrice!) * 100) / price!;
    }
    return 0.0;
  }
}
