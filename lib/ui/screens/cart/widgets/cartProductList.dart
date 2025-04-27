import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/cart/getUserCart.dart';
import 'package:eshop_pro/cubits/cart/manageCartCubit.dart';
import 'package:eshop_pro/cubits/cart/removeProductFromCartCubit.dart';
import 'package:eshop_pro/cubits/promoCode/validatePromoCodeCubit.dart';
import 'package:eshop_pro/cubits/storesCubit.dart';
import 'package:eshop_pro/data/models/cart.dart';
import 'package:eshop_pro/data/models/product.dart';
import 'package:eshop_pro/ui/screens/cart/widgets/quantitySelector.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/productDetailsScreen.dart';
import 'package:eshop_pro/ui/widgets/addToCartButton.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/ui/widgets/customRoundedButton.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:eshop_pro/ui/styles/colors.dart';

import 'package:eshop_pro/ui/widgets/customImageWidget.dart';

import 'package:eshop_pro/utils/utils.dart';

class CartProductList extends StatefulWidget {
  final bool? isFinalCartScreen;
  final Cart cart;
  final RemoveFromCartCubit removeFromCartCubit;

  const CartProductList({
    Key? key,
    required this.cart,
    this.isFinalCartScreen = false,
    required this.removeFromCartCubit,
  }) : super(key: key);

  @override
  _CartProductListState createState() => _CartProductListState();
}

class _CartProductListState extends State<CartProductList> {
  late Cart cart;
  List<CartProduct> savedForLaterProducts = [];
  late TextStyle bodyMedtextStyle;
  @override
  initState() {
    super.initState();
    cart = widget.cart;
  }

  @override
  Widget build(BuildContext context) {
    bodyMedtextStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.8));

    return BlocBuilder<GetUserCartCubit, GetUserCartState>(
      builder: (context, state) {
        if (state is GetUserCartFetchSuccess) {
          return BlocListener<RemoveFromCartCubit, RemoveFromCartState>(
            bloc: widget.removeFromCartCubit,
            listener: (context, remvovestate) {
              if (remvovestate is RemoveFromCartFetchSuccess) {
                //here we need to update the cart from the total quantity and sub total and delivery charge which is response from remove from cart api
                if (!remvovestate.isRemoveForSavedForLater) {
                  // we have opend modal bottom sheet so we need to pop it wen we remove it from cart lisr
                  //need not to do this for saved for later list
                  Navigator.of(context).pop();
                }

                Utils.showSnackBar(
                    context: context, message: remvovestate.successMessage);
                if (remvovestate.isRemoveForSavedForLater &&
                    state.cart.saveForLaterProducts != null) {
                  //if we are removing from saved for later list we need to remove the product from the saved for later list
                  state.cart.saveForLaterProducts!.removeWhere(
                      (element) => element.cartId == remvovestate.id);
                } else {
                  //if we are removing from cart list we need to remove the product from the cart list and also need to update the sub total, item total, discount, overall amount, delivery charge, tax amount, total quantity and promo code
                  if (state.cart.cartProducts != null) {
                    state.cart.cartProducts!.removeWhere(
                        (element) => element.cartId == remvovestate.id);
                  }
                  state.cart.subTotal = remvovestate.subTotal;
                  state.cart.itemTotal = remvovestate.itemTotal;
                  state.cart.discount = remvovestate.discount;
                  state.cart.overallAmount = remvovestate.overallAmount;
                  state.cart.deliveryCharge = remvovestate.deliveryCharge;
                  state.cart.taxAmount = remvovestate.taxAmount;
                  state.cart.totalQuantity = remvovestate.totalQuantity;
                  if (state.cart.promoCode != null) {
                    context
                        .read<ValidatePromoCodeCubit>()
                        .validatePromoCode(params: {
                      Api.finalTotalApiKey: state.cart.subTotal,
                      Api.promoCodeApiKey: state.cart.promoCode!.promoCode
                    });
                  }
                }

                context.read<GetUserCartCubit>().emitSuccessState(state.cart);
              }
              if (remvovestate is RemoveFromCartFetchFailure) {
                Navigator.of(context).pop();
                Utils.showSnackBar(
                    context: context, message: remvovestate.errorMessage);
              }
            },
            child: BlocBuilder<ManageCartCubit, ManageCartState>(
              builder: (context, manageState) {
                return Column(
                  children: [
                    if (cart.cartProducts != null &&
                        cart.cartProducts!.isNotEmpty)
                      buildCartList(false, widget.cart.cartProducts!),
                    if (cart.saveForLaterProducts != null &&
                        cart.saveForLaterProducts!.isNotEmpty &&
                        !widget.isFinalCartScreen!)
                      buildSavedForLaterContainer(),
                  ],
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  ListView buildCartList(bool isSavedForLaterList, List<CartProduct> products) {
    return ListView.separated(
      separatorBuilder: (context, index) => DesignConfig.smallHeightSizedBox,
      itemCount: products.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding:
          const EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
      itemBuilder: (context, index) {
        CartProduct product = products[index];

        return GestureDetector(
          onTap: () {
            if (product.cartProductType == 'combo') {
              Get.toNamed(Routes.productDetailsScreen,
                  arguments: ProductDetailsScreen.buildArguments(
                      product: product.productDetails![0],
                      isComboProduct: true));
            } else {
              Get.toNamed(
                Routes.productDetailsScreen,
                arguments: ProductDetailsScreen.buildArguments(
                    product: product.productDetails![0]),
              );
            }
          },
          child: Container(
              padding: const EdgeInsetsDirectional.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    CustomImageWidget(
                        url: (product.image ?? ""),
                        width: 86,
                        height: 100,
                        borderRadius: 8),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: CustomTextContainer(
                                  textKey:
                                      product.productDetails![0].name ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              if (isSavedForLaterList)
                                buildRemoveProductButton(
                                  product,
                                  products,
                                  context,
                                )
                              else
                                buildRemoveOrSaveForLaterButton(
                                  product,
                                  products,
                                  context,
                                )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.symmetric(
                                vertical: 4.0),
                            child: CustomTextContainer(
                              textKey: product.shortDescription ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      height: 1.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.67)),
                            ),
                          ),
                          if (product.type == variableProductType)
                            Padding(
                              padding: const EdgeInsetsDirectional.symmetric(
                                  vertical: 4),
                              child: Utils.buildVariantContainer(
                                  context,
                                  product.productVariants![0].attrName!,
                                  product.productVariants![0].variantValues!),
                            ),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              product.specialPrice != null &&
                                      product.specialPrice! > 0 &&
                                      product.specialPrice != product.price
                                  ? Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                              text:
                                                  Utils.priceWithCurrencySymbol(
                                                context: context,
                                                price: product.specialPrice!,
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  )),
                                          const TextSpan(text: "  "),
                                          TextSpan(
                                              text:
                                                  Utils.priceWithCurrencySymbol(
                                                      price: product.price!,
                                                      context: context),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary
                                                        .withOpacity(0.67),
                                                  )),
                                          const TextSpan(text: "  "),
                                          TextSpan(
                                              text:
                                                  "${Utils.formatDouble(getDiscoutPercentage(product.price!, product.specialPrice!))}% off",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                      color:
                                                          successStatusColor)),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : CustomTextContainer(
                                      textKey: Utils.priceWithCurrencySymbol(
                                          price: product.price!,
                                          context: context),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                    ),
                              if (!widget.isFinalCartScreen!) ...[
                                if (isSavedForLaterList &&
                                    ((product.type != variableProductType &&
                                            !product.productDetails![0]
                                                .isProductOutOfStock()) ||
                                        (product.type == variableProductType &&
                                            !product.productDetails![0]
                                                .isVariantOutOfStock(product
                                                    .productDetails![0]
                                                    .variants![0]))))
                                  AddToCartButton(
                                      reloadCart: true,
                                      widthPercentage: 0.25,
                                      productId:
                                          product.cartProductType == 'combo'
                                              ? product.id!
                                              : product.productVariantId!,
                                      type: product.cartProductType == 'combo'
                                          ? 'combo'
                                          : 'regular',
                                      productType: product.type!,
                                      qty: product.qty,
                                      sellerId: product.sellerId!,
                                      stockType:
                                          product.productDetails![0].stockType!,
                                      stock: product.type == variableProductType
                                          ? product.productVariants![0].stock!
                                          : product.productDetails![0].stock!)
                                else
                                  FittedBox(
                                    child: QuantitySelector(
                                      initialQuantity: product.qty ??
                                          product.minimumOrderQuantity ??
                                          1,
                                      minimumOrderQuantity:
                                          product.minimumOrderQuantity ?? 1,
                                      maximumAllowedQuantity:
                                          product.totalAllowedQuantity ?? 1,
                                      quantityStepSize:
                                          product.quantityStepSize ?? 1,
                                      stockType: product
                                              .productDetails![0].stockType ??
                                          '',
                                      stock: product.type == variableProductType
                                          ? product.productVariants![0].stock!
                                          : product.productDetails![0].stock!,
                                      product: product,
                                      primaryTheme: false,
                                    ),
                                  )
                              ]
                            ],
                          ),
                        ],
                      ),
                    )
                  ]),
                  if (product.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: CustomTextContainer(
                        textKey: product.errorMessage ?? "",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            height: 1.0,
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  if (widget.isFinalCartScreen!) ...[
                    Divider(
                        color:
                            Theme.of(context).inputDecorationTheme.iconColor),
                    buildPriceDetailRow(
                      netAmountKey,
                      product.netAmount!.toString(),
                    ),
                    buildPriceDetailRow(
                      taxKey,
                      product.taxAmount!.toString(),
                    ),
                    buildPriceDetailRow(
                      totalKey,
                      product.specialPrice!.toString(),
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    )
                  ]
                ],
              )),
        );
      },
    );
  }

  double getDiscoutPercentage(double price, double specialPrice) {
    if (specialPrice != 0.0) {
      return ((price - specialPrice) * 100) / price;
    }
    return 0.0;
  }

  buildPriceDetailRow(String title, String value, {TextStyle? textStyle}) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          start: appContentHorizontalPadding,
          end: appContentHorizontalPadding,
          bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CustomTextContainer(
            textKey: title,
            style: bodyMedtextStyle,
          ),
          CustomTextContainer(
            textKey: Utils.priceWithCurrencySymbol(
                price: double.tryParse(value) ?? 0, context: context),
            style: textStyle ?? bodyMedtextStyle,
          )
        ],
      ),
    );
  }


  buildRemoveProductButton(
      CartProduct product, List<CartProduct> products, BuildContext context) {
    return BlocBuilder<RemoveFromCartCubit, RemoveFromCartState>(
      bloc: widget.removeFromCartCubit,
      builder: (context, state) {
        return IconButton(
            icon: state is RemoveFromCartFetchInProgress &&
                    state.isRemoveForSavedForLater &&
                    state.products!
                            .firstWhere((element) => element.id == product.id)
                            .removeProductInProgress ==
                        true
                ? CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).colorScheme.secondary)
                : Icon(
                    Icons.close_outlined,
                    size: 24,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.67),
                  ),
            onPressed: () =>
                removeProductFromCartFunction(state, product, products, true));
      },
    );
  }

  buildRemoveOrSaveForLaterButton(
      CartProduct product, List<CartProduct> products, BuildContext context) {
    return IconButton(
        icon: Icon(
          Icons.close_outlined,
          size: 24,
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.67),
        ),
        onPressed: () => Utils.openModalBottomSheet(
              context,
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: appContentHorizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        CustomImageWidget(
                            url: (product.image ?? ""),
                            width: 86,
                            height: 100,
                            borderRadius: 8),
                        DesignConfig.smallWidthSizedBox,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              CustomTextContainer(
                                textKey: removeFromCartTitlekey,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              CustomTextContainer(
                                textKey: removeFromCartDesckey,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.67)),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    DesignConfig.smallHeightSizedBox,
                    Row(
                      children: [
                        Expanded(
                          child: BlocBuilder<RemoveFromCartCubit,
                              RemoveFromCartState>(
                            bloc: widget.removeFromCartCubit,
                            builder: (context, state) {
                              return CustomRoundedButton(
                                  widthPercentage: 0.4,
                                  buttonTitle: removeKey,
                                  showBorder: true,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  borderColor: Theme.of(context).hintColor,
                                  style: const TextStyle().copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  child: state
                                              is RemoveFromCartFetchInProgress &&
                                          !state.isRemoveForSavedForLater &&
                                          state.products!
                                                  .firstWhere((element) =>
                                                      element.id == product.id)
                                                  .removeProductInProgress ==
                                              true
                                      ? CustomCircularProgressIndicator(
                                          indicatorColor: Theme.of(context)
                                              .colorScheme
                                              .secondary)
                                      : null,
                                  onTap: () => removeProductFromCartFunction(
                                      state, product, products, false));
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: BlocConsumer<ManageCartCubit, ManageCartState>(
                            listener: (bcontext, state) {
                           
                            },
                            builder: (context, state) {
                              return CustomRoundedButton(
                                widthPercentage: 0.4,
                                buttonTitle: saveForLaterkey,
                                showBorder: false,
                                child: state is ManageCartFetchInProgress
                                    ? const CustomCircularProgressIndicator()
                                    : null,
                                onTap: () {
                                  if (state is ManageCartFetchInProgress)
                                    return;
                                  context
                                      .read<ManageCartCubit>()
                                      .manageUserCart(product.id,
                                          isAddedToSaveLater: true,
                                          reloadCart: true,
                                          params: {
                                        Api.storeIdApiKey: context
                                            .read<StoresCubit>()
                                            .getDefaultStore()
                                            .id,
                                        Api.productVariantIdApiKey:
                                            product.cartProductType == 'combo'
                                                ? product.id
                                                : product.productVariantId,
                                        Api.productTypeApiKey:
                                            product.cartProductType == 'combo'
                                                ? 'combo'
                                                : 'regular',
                                        Api.isSavedForLaterApiKey: 1,
                                        Api.qtyApiKey: product.qty
                                      });
                                  Future.delayed(
                                      const Duration(milliseconds: 500), () {
                                    Navigator.pop(context);
                                  });
                                },
                              
                              );
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              staticContent: true,
            ));
  }

  removeProductFromCartFunction(
    RemoveFromCartState state,
    CartProduct product,
    List<CartProduct> products,
    bool isRemoveForSavedForLater,
  ) {
    if (state is RemoveFromCartFetchInProgress &&
        state.products!
                .firstWhere((element) => element.id == product.id)
                .removeProductInProgress ==
            true) return;
    widget.removeFromCartCubit.removeProductFromCart(
        params: {
          Api.storeIdApiKey: context.read<StoresCubit>().getDefaultStore().id,
          Api.productVariantIdApiKey: product.cartProductType == 'combo'
              ? product.id
              : product.productVariantId,
          Api.productTypeApiKey:
              product.cartProductType == 'combo' ? 'combo' : 'regular',
          Api.isSavedForLaterApiKey: isRemoveForSavedForLater ? 1 : 0,
        },
        products: products,
        cartId: product.cartId!,
        isRemoveForSavedForLater: isRemoveForSavedForLater);
  }

  buildSavedForLaterContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(appContentHorizontalPadding),
          child: CustomTextContainer(
            textKey: saveForLaterkey,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        buildCartList(true, widget.cart.saveForLaterProducts ?? [])
      ],
    );
  }
}
