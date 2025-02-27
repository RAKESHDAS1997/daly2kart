import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/cart/getUserCart.dart';
import 'package:eshop_pro/cubits/cart/manageCartCubit.dart';
import 'package:eshop_pro/cubits/cart/removeProductFromCartCubit.dart';
import 'package:eshop_pro/cubits/promoCode/validatePromoCodeCubit.dart';
import 'package:eshop_pro/cubits/settingsAndLanguagesCubit.dart';
import 'package:eshop_pro/cubits/storesCubit.dart';
import 'package:eshop_pro/cubits/user_details_cubit.dart';
import 'package:eshop_pro/data/models/cart.dart';
import 'package:eshop_pro/ui/screens/cart/widgets/cartProductList.dart';
import 'package:eshop_pro/ui/screens/cart/widgets/priceDetailContainer.dart';

import 'package:eshop_pro/ui/widgets/customAppbar.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/ui/widgets/customDefaultContainer.dart';
import 'package:eshop_pro/ui/widgets/customRoundedButton.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/ui/widgets/error_screen.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CartScreen extends StatefulWidget {
  final bool shoulPop;

  const CartScreen({Key? key, this.shoulPop = false}) : super(key: key);
  static Widget getRouteInstance() => BlocProvider(
        create: (context) => RemoveFromCartCubit(),
        child: CartScreen(
          shoulPop: Get.arguments ?? true,
        ),
      );
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  GlobalKey _cartListKey = GlobalKey(), _priceDetailKey = GlobalKey();
  bool _enableChangeAddress = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (!context.read<UserDetailsCubit>().isGuestUser()) getUserCart();
    });
  }

  getUserCart() {
    context.read<GetUserCartCubit>().fetchUserCart(params: {
      Api.storeIdApiKey: context.read<StoresCubit>().getDefaultStore().id,

      Api.onlyDeliveryChargeApiKey: 0,
      Api.userIdApiKey: context.read<UserDetailsCubit>().getUserId(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ValidatePromoCodeCubit(),
      child: Scaffold(
          appBar: CustomAppbar(
            titleKey: cartKey,
            showBackButton: widget.shoulPop ? true : false,
          ),
          body: context.read<UserDetailsCubit>().isGuestUser()
              ? ErrorScreen(
                  onPressed: () =>
                      Utils.navigateToScreen(context, Routes.loginScreen),
                  text: loginToAddToCartKey,
                  buttonText: loginKey,
                  image: 'empty_cart',
                )
              : BlocListener<GetUserCartCubit, GetUserCartState>(
                  listener: (context, state) {},
                  child: BlocListener<ManageCartCubit, ManageCartState>(
                    listener: (context, manageState) {
                      if (manageState is ManageCartFetchSuccess) {
                        // if we are reloading cart, we need to get the user cart otherwise we will get the cart from the managecartstate
                        if (manageState.reloadCart) {
                          getUserCart();
                        } else {
                          if (context.read<GetUserCartCubit>().state
                              is GetUserCartFetchSuccess) {
                            GetUserCartFetchSuccess state = context
                                .read<GetUserCartCubit>()
                                .state as GetUserCartFetchSuccess;
                            manageState.cart.promoCode = state.cart.promoCode;
                            manageState.cart.couponDiscount =
                                state.cart.couponDiscount;
                        
                            manageState.cart.saveForLaterProducts =
                                state.cart.saveForLaterProducts;
                            manageState.cart.selectedAddress =
                                state.cart.selectedAddress;
                            manageState.cart.deliveryInstruction =
                                state.cart.deliveryInstruction;
                            manageState.cart.emailAddress =
                                state.cart.emailAddress;
                          }
                          context
                              .read<GetUserCartCubit>()
                              .emitSuccessState(manageState.cart);
                        }
                        refreshState();
                      }
                    },
                    child: BlocBuilder<GetUserCartCubit, GetUserCartState>(
                      builder: (context, state) {
                        if (state is GetUserCartFetchSuccess) {
                      
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              MultiBlocListener(
                                listeners: [
                                  BlocListener<RemoveFromCartCubit,
                                          RemoveFromCartState>(
                                      listener: (context, remvovestate) {
                                    if (remvovestate
                                        is RemoveFromCartFetchSuccess) {
                                      //here when we remove from cart we need to refresh the state so that change price will be reflected
                                      refreshState();
                                    }
                                  }),
                              
                                  BlocListener<ValidatePromoCodeCubit,
                                          ValidatePromoCodeState>(
                                      listener: (context, state) {
                                    if (context.read<GetUserCartCubit>().state
                                        is GetUserCartFetchSuccess) {
                                      Cart cart = (context
                                              .read<GetUserCartCubit>()
                                              .state as GetUserCartFetchSuccess)
                                          .cart;
                                      if (state
                                          is ValidatePromoCodeFetchSuccess) {
                                        //when promo code is applied we need to update the cart
                                        cart.overallAmount =
                                            state.promoCode.finalTotal!;

                                        cart.couponDiscount =
                                            state.promoCode.finalDiscount!;
                                        cart.promoCode = state.promoCode;

                                        context
                                            .read<GetUserCartCubit>()
                                            .emitSuccessState(cart);
                                        if (cart.useWalletBalance == true) {
                                          context
                                              .read<GetUserCartCubit>()
                                              .useWalletBalance(
                                                  true,
                                                  context
                                                          .read<
                                                              UserDetailsCubit>()
                                                          .getuserDetails()
                                                          .balance ??
                                                      0);
                                        }
                                      }
                                      if (state
                                          is ValidatePromoCodeFetchFailure) {
                                        Utils.showSnackBar(
                                            context: context,
                                            message: state.errorMessage);
                                        cart.overallAmount = state.finalTotal;
                                        cart.promoCode = null;
                                        cart.couponDiscount = 0;
                                        context
                                            .read<GetUserCartCubit>()
                                            .emitSuccessState(cart);
                                      }
                                    }
                                  })
                                ],
                                child: (state.cart.cartProducts == null ||
                                            (state.cart.cartProducts != null &&
                                                state.cart.cartProducts!
                                                    .isEmpty)) &&
                                        (state.cart.saveForLaterProducts ==
                                                null ||
                                            (state.cart.saveForLaterProducts !=
                                                    null &&
                                                state.cart.saveForLaterProducts!
                                                    .isEmpty))
                                    ? ErrorScreen(
                                        text: emptyCartkey,
                                        image: 'empty_cart',
                                        onPressed: () {},
                                        child: CustomRoundedButton(
                                          widthPercentage: 0.5,
                                          buttonTitle: addFromFavoritesKey,
                                          showBorder: false,
                                          onTap: () => Utils.navigateToScreen(
                                              context, Routes.favoriteScreen),
                                        ),
                                      )
                                    : buildBodyContent(state, context),
                              ),
                              buildPlaceOrderButton(state)
                            ],
                          );
                        }
                        if (state is GetUserCartFetchFailure) {
                          return ErrorScreen(
                              onPressed: getUserCart,
                              text: state.errorMessage,
                              image: state.errorMessage == noInternetKey
                                  ? "no_internet"
                                  : 'empty_cart',
                              child: state is GetUserCartFetchInProgress
                                  ? CustomCircularProgressIndicator(
                                      indicatorColor:
                                          Theme.of(context).colorScheme.primary,
                                    )
                                  : null);
                        }
                        return CustomCircularProgressIndicator(
                            indicatorColor:
                                Theme.of(context).colorScheme.primary);
                      },
                    ),
                  ),
                )),
    );
  }

  refreshState() {
    _cartListKey = GlobalKey();
    _priceDetailKey = GlobalKey();
  }

  Widget buildBodyContent(GetUserCartFetchSuccess state, BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 58),
      children: [
        CartProductList(
          key: _cartListKey,
          cart: state.cart,
          removeFromCartCubit: context.read<RemoveFromCartCubit>(),
        ),
        DesignConfig.smallHeightSizedBox,
        if (_enableChangeAddress &&
            context.read<GetUserCartCubit>().getCartDetail().selectedAddress !=
                null)
          changeAddressWidget(),
        if (state.cart.cartProducts != null &&
            state.cart.cartProducts!.isNotEmpty)
          PriceDetailContainer(
            key: _priceDetailKey,
            cart: state.cart,
          ),
      ],
    );
  }

  changeAddressWidget() {
    return GestureDetector(
      onTap: () => Utils.navigateToScreen(
        context,
        Routes.placeOrderScreen,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: CustomDefaultContainer(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextContainer(
                  textKey: changeAddressKey,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Divider(
                  height: 12,
                  thickness: 0.5,
                ),
                Utils.getAddressWidget(
                    context,
                    context
                        .read<GetUserCartCubit>()
                        .getCartDetail()
                        .selectedAddress!),
              ],
            )),
            const Icon(Icons.arrow_forward_ios, size: 24)
          ],
        )),
      ),
    );
  }

  buildPlaceOrderButton(GetUserCartState state) {
    if (state is GetUserCartFetchSuccess &&
        state.cart.cartProducts != null &&
        state.cart.cartProducts!.isNotEmpty) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            margin: const EdgeInsetsDirectional.symmetric(
                horizontal: appContentHorizontalPadding,
                vertical: appContentHorizontalPadding / 2),
            child: CustomRoundedButton(
              widthPercentage: 1,
              buttonTitle: placeOrderKey,
              showBorder: false,
              onTap: () {
                if (state.cart.subTotal != null &&
                    state.cart.subTotal! <
                        double.parse(context
                            .read<SettingsAndLanguagesCubit>()
                            .getSettings()
                            .systemSettings!
                            .minimumCartAmount!
                            .toString())) {
                  Utils.showSnackBar(
                      context: context,
                      duration: const Duration(seconds: 7),
                      message:
                          '${context.read<SettingsAndLanguagesCubit>().getTranslatedValue(labelKey: minOrderAmountWarning1Key)}${Utils.priceWithCurrencySymbol(context: context, price: double.parse(context.read<SettingsAndLanguagesCubit>().getSettings().systemSettings!.minimumCartAmount.toString()))}. ${context.read<SettingsAndLanguagesCubit>().getTranslatedValue(labelKey: minOrderAmountWarning2Key)}');
                  return;
                }
                Utils.navigateToScreen(context, Routes.placeOrderScreen)!
                    .then((value) {
                  if (value != null && value) {
                    setState(() {
                      _enableChangeAddress = true;
                    });
                  }
                });
              },
            )),
      );
    }
    return const SizedBox.shrink();
  }
}
