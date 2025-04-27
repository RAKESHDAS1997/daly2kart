import 'package:eshop_pro/cubits/user_details_cubit.dart';
import 'package:eshop_pro/data/models/address.dart';
import 'package:eshop_pro/data/models/cart.dart';
import 'package:eshop_pro/data/models/paymentMethod.dart';
import 'package:eshop_pro/data/models/product.dart';
import 'package:eshop_pro/data/models/promoCode.dart';
import 'package:eshop_pro/data/repositories/cartRepository.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

abstract class GetUserCartState {}

class GetUserCartInitial extends GetUserCartState {}

class GetUserCartFetchInProgress extends GetUserCartState {}

class GetUserCartFetchSuccess extends GetUserCartState {
  final Cart cart;

  GetUserCartFetchSuccess({required this.cart});
}

class GetUserCartFetchFailure extends GetUserCartState {
  final String errorMessage;

  GetUserCartFetchFailure(this.errorMessage);
}

class GetUserCartCubit extends Cubit<GetUserCartState> {
  final CartRepository _cartRepository = CartRepository();

  GetUserCartCubit() : super(GetUserCartInitial());

  void fetchUserCart({required Map<String, dynamic> params}) {
    emit(GetUserCartFetchInProgress());

    _cartRepository
        .fetchUserCart(params: params)
        .then((value) => emit(GetUserCartFetchSuccess(cart: value)))
        .catchError((e) {
      emit(GetUserCartFetchFailure(e.toString()));
    });
  }

  Cart getCartDetail() {
    if (state is GetUserCartFetchSuccess) {
      return (state as GetUserCartFetchSuccess).cart;
    }
    return Cart.fromJson({});
  }

  emitSuccessState(Cart cart) {
    emit(GetUserCartFetchSuccess(cart: cart));
  }

  getCartProductLength() {
    if (state is GetUserCartFetchSuccess) {
      return (state as GetUserCartFetchSuccess).cart.cartProducts != null &&
              (state as GetUserCartFetchSuccess).cart.cartProducts!.isNotEmpty
          ? (state as GetUserCartFetchSuccess).cart.cartProducts!.length
          : 0;
    }
    return 0;
  }

  addDeliveryInstruction(String instruction) {
    if (state is GetUserCartFetchSuccess) {
      (state as GetUserCartFetchSuccess).cart.deliveryInstruction = instruction;
      emit(GetUserCartFetchSuccess(
          cart: (state as GetUserCartFetchSuccess).cart));
    }
  }

  addEmailAddress(String emailAddress) {
    if (state is GetUserCartFetchSuccess) {
      (state as GetUserCartFetchSuccess).cart.emailAddress = emailAddress;
      emit(GetUserCartFetchSuccess(
          cart: (state as GetUserCartFetchSuccess).cart));
    }
  }

  changeSelectedAddress(Address address) {
    if (state is GetUserCartFetchSuccess) {
      (state as GetUserCartFetchSuccess).cart.selectedAddress = address;
      emit(GetUserCartFetchSuccess(
          cart: (state as GetUserCartFetchSuccess).cart));
    }
  }

  changePaymantMethod(PaymentModel paymentModel) {
    if (state is GetUserCartFetchSuccess) {
      (state as GetUserCartFetchSuccess).cart.selectedPaymentMethod =
          paymentModel;
      emit(GetUserCartFetchSuccess(
          cart: (state as GetUserCartFetchSuccess).cart));
    }
  }

  useWalletBalance(bool useWalletBalance, double walletBalance) {
    if (state is GetUserCartFetchSuccess) {
      Cart cart = (state as GetUserCartFetchSuccess).cart;
      cart.useWalletBalance = useWalletBalance;
      if (useWalletBalance) {
        if (walletBalance >= cart.overallAmount!) {
          // Case 1: Wallet has enough balance to cover the total amount
          cart.walletAmount = cart.overallAmount;
          cart.overallAmount = 0.0;
          cart.selectedPaymentMethod = null;
        } else {
          // Case 2: Wallet has less balance than the total amount
          double remainingAmount = cart.overallAmount! - walletBalance;
          cart.walletAmount = walletBalance;
          cart.overallAmount =
              remainingAmount; // Return the remaining amount to pay
        }
      } else {
        // Wallet deselected
        cart.useWalletBalance = false;
        cart.overallAmount =
            cart.originalOverallAmount; // Restore original amount
        cart.walletAmount = 0.0; // Reset wallet contribution
      }
      emit(GetUserCartFetchSuccess(cart: cart));
    }
  }

  setErrorMessage(int productId, String errorMessage) {
    if (state is GetUserCartFetchSuccess) {
      CartProduct? cartProduct =
          (state as GetUserCartFetchSuccess).cart.cartProducts!.firstWhere(
                (product) => product.id == productId,
                orElse: () => CartProduct(),
              );
      if (cartProduct != CartProduct()) {
        cartProduct.errorMessage = errorMessage;
      }

      emit(GetUserCartFetchSuccess(
          cart: (state as GetUserCartFetchSuccess).cart));
    }
  }

  setPromoCode(BuildContext context, PromoCode promoCode) {
    if (state is GetUserCartFetchSuccess) {
      Cart cart = (state as GetUserCartFetchSuccess).cart;
      cart.overallAmount = promoCode.finalTotal!;
      cart.couponDiscount = promoCode.finalDiscount!;
      cart.promoCode = promoCode;
      emitSuccessState(cart);
      if (cart.useWalletBalance == true) {
        useWalletBalance(true,
            context.read<UserDetailsCubit>().getuserDetails().balance ?? 0);
      }
    }
  }

  removePromoCode() {
    if (state is GetUserCartFetchSuccess) {
      Cart cart = (state as GetUserCartFetchSuccess).cart;
      cart.promoCode = null;
      cart.couponDiscount = 0;
      cart.overallAmount = cart.originalOverallAmount;
      emitSuccessState(cart);
    }
  }

  double calculateItemTotalForProduct(Cart cart, int productId) {
    double total = 0.0;

    // Iterate over each cart product
    for (var cartProduct in cart.cartProducts!) {
      // Check if the product ID matches the specific product ID
      if (cartProduct.productDetails![0].id == productId) {
        // Add the total of this variant to the running total
        total += cartProduct.specialPrice! * cartProduct.qty!;
      }
    }

    return total;
  }

  resetCart() {
    if (state is GetUserCartFetchSuccess) {
      List<CartProduct>? saveForLaterProducts =
          (state as GetUserCartFetchSuccess).cart.saveForLaterProducts;

      // Create a new empty Cart object
      Cart cart = Cart(
        cartProducts: [], // Explicitly setting cartProducts to an empty list
        saveForLaterProducts:
            saveForLaterProducts ?? [], // Retain saveForLaterProducts
      );

      // Emit loading state before emitting the updated state
      emit(GetUserCartFetchInProgress());

      // Emit the updated state with the reset cart
      emit(GetUserCartFetchSuccess(cart: cart));
    }
  }

  void setStripePayId(String stripePayId) {
    if (state is GetUserCartFetchSuccess) {
      (state as GetUserCartFetchSuccess).cart.stripePayId = stripePayId;
      emit(GetUserCartFetchSuccess(
          cart: (state as GetUserCartFetchSuccess).cart));
    }
  }

  updateProductDetails(int cartProductId, Product product) {
    if (state is GetUserCartFetchSuccess) {
      CartProduct? cartProduct = (state as GetUserCartFetchSuccess)
          .cart
          .cartProducts!
          .firstWhereOrNull(
            (product) => product.id == cartProductId,
          );
      if (cartProduct != null) {
        cartProduct.productDetails![0] = product;
      }

      emit(GetUserCartFetchSuccess(
          cart: (state as GetUserCartFetchSuccess).cart));
    }
  }
}
