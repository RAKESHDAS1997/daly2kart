import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/cart/getUserCart.dart';
import 'package:eshop_pro/cubits/cart/manageCartCubit.dart';
import 'package:eshop_pro/cubits/favorites/removeFavoriteCubit.dart';
import 'package:eshop_pro/cubits/settingsAndLanguagesCubit.dart';

import 'package:eshop_pro/data/models/product.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/widgets/variantSelector.dart';
import 'package:eshop_pro/ui/screens/explore/widgets/ratingAndReviewCountContainer.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/productDetailsScreen.dart';
import 'package:eshop_pro/ui/styles/colors.dart';
import 'package:eshop_pro/ui/widgets/addToCartButton.dart';

import 'package:eshop_pro/ui/widgets/customImageWidget.dart';
import 'package:eshop_pro/ui/widgets/customRoundedButton.dart';
import 'package:eshop_pro/ui/widgets/customTextButton.dart';

import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/ui/widgets/favoriteButton.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/storesCubit.dart';
import '../../../../utils/labelKeys.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final Color? backgroundColor;

  ProductCard({
    Key? key,
    required this.product,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool isProductStyle1 = true,
      isProductStyle2 = false,
      isProductStyle3 = false;

  @override
  Widget build(BuildContext context) {
   

    return BlocBuilder<StoresCubit, StoresState>(

      builder: (context, state) {
        if(state is StoresFetchSuccess){
           isProductStyle1 = context
                  .read<StoresCubit>()
                  .getDefaultStore()
                  .storeSettings!
                  .productStyle ==
              'style_1';

          isProductStyle2 = context
                  .read<StoresCubit>()
                  .getDefaultStore()
                  .storeSettings!
                  .productStyle ==
              'style_2';

          isProductStyle3 = context
                  .read<StoresCubit>()
                  .getDefaultStore()
                  .storeSettings!
                  .productStyle ==
              'style_3';
        }
        return BlocBuilder<RemoveFavoriteCubit, RemoveFavoriteState>(
          builder: (context, state) {
            return GestureDetector(
              onTap: () {
                Utils.navigateToScreen(context, Routes.productDetailsScreen,
                        arguments: widget.product.type == comboProductType
                            ? ProductDetailsScreen.buildArguments(
                                product: widget.product, isComboProduct: true)
                            : ProductDetailsScreen.buildArguments(
                                product: widget.product,
                              ))!
                    .then((value) => setState(() {}));
              },
              child: Container(
                width: (MediaQuery.of(context).size.width -
                        appContentHorizontalPadding * 3) /
                    2,
                padding: const EdgeInsetsDirectional.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomImageWidget(
                      url: (widget.product.image ?? "").isNotEmpty
                          ? (widget.product.image ?? "")
                          : widget.product.imageMd!,
                      width: double.maxFinite,
                      height: 190,
                      borderRadius: 8,
                      child: isProductStyle1
                          ? buildOnImageWidgetsForStyle1(context)
                          : isProductStyle2
                              ? buildOnImageWidgetsForStyle2(context)
                              : buildOnImageWidgetsForStyle3(context),
                    ),
                    const SizedBox(height: appContentHorizontalPadding * (0.5)),
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if ((isProductStyle2 || isProductStyle3) &&
                                  widget.product.hasAnyRating()) ...[
                                RatingAndReviewCountContainer(
                                  rating: widget.product.rating ?? "",
                                  ratingCount:
                                      widget.product.noOfRatings?.toString() ?? "",
                                  textColor: Theme.of(context).colorScheme.primary,
                                ),
                                DesignConfig.smallHeightSizedBox,
                              ],
                              CustomTextContainer(
                                textKey: 'By ${widget.product.storeName ?? ""}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.67)),
                              ),
                            ],
                          ),
                          CustomTextContainer(
                            textKey: widget.product.name ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Wrap(
                              runSpacing: 4.0,
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.center,
    
                              ///here we are checking if the product has more than one variant  otherwise no need to show dropdown
                              children:
                                  widget.product.type == variableProductType &&
                                          widget.product.availableVariants != []
                                      ? buildPriceWidgetForVariableProduct(context)
                                      : buildPriceWidgetForSimpleProduct(context)),
                          widget.product.isProductOutOfStock()
                              ? Padding(
                                  padding: const EdgeInsetsDirectional.only(top: 8),
                                  child: CustomTextContainer(
                                      textKey: outOfStockKey,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(color: cancelledStatusColor)),
                                )
                              : !isProductStyle1
                                  ? widget.product.type == variableProductType
                                      ? buildAddToCartButtonForVariable()
                                      : BlocBuilder<ManageCartCubit,
                                          ManageCartState>(
                                          builder: (context, state) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsetsDirectional.only(
                                                      top: 8),
                                              child: AddToCartButton(
                                                  widthPercentage: 1.0,
                                                  height: 32,
                                                  productId: widget.product.type ==
                                                          comboProductType
                                                      ? widget.product.id!
                                                      : widget.product
                                                          .selectedVariant!.id!,
                                                  type: widget.product.type ==
                                                          comboProductType
                                                      ? 'combo'
                                                      : 'regular',
                                                  productType:
                                                      widget.product.productType!,
                                                  stockType:
                                                      widget.product.stockType!,
                                                  stock: widget.product.type ==
                                                          variableProductType
                                                      ? widget.product
                                                          .selectedVariant!.stock!
                                                      : widget.product.stock!,
                                                  sellerId:
                                                      widget.product.sellerId!,
                                                  qty: widget.product
                                                          .minimumOrderQuantity ??
                                                      1),
                                            );
                                          },
                                        )
                                  : const SizedBox.shrink()
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  CustomRoundedButton buildAddToCartButtonForVariable() {
    return CustomRoundedButton(
        widthPercentage: 1.0,
        height: 32,
        buttonTitle: addToCartKey,
        showBorder: false,
        style: Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(color: Theme.of(context).colorScheme.onPrimary),
        onTap: openBottomSheetForVariableProduct);
  }

  openBottomSheetForVariableProduct() {
    Utils.openModalBottomSheet(context,
        BlocBuilder<GetUserCartCubit, GetUserCartState>(
      builder: (context, state) {
        return BlocBuilder<ManageCartCubit, ManageCartState>(
          builder: (context, state) {
            return Column(
              children: <Widget>[
                VariantSelector(
                  variants: widget.product.variants ?? [],
                  product: widget.product,
                  isFromVariantSelectorPopup: true,
                ),
                isProductAddedinCart()
                    ? Container(
                        height: 50,
                        padding: const EdgeInsetsDirectional.all(12),
                        margin: const EdgeInsetsDirectional.all(
                            appContentHorizontalPadding),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            CustomTextContainer(
                                textKey:
                                    '${context.read<SettingsAndLanguagesCubit>().getTranslatedValue(labelKey: itemTotalKey)} : ${Utils.priceWithCurrencySymbol(price: context.read<GetUserCartCubit>().calculateItemTotalForProduct(context.read<GetUserCartCubit>().getCartDetail(), widget.product.id!), context: context)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary)),
                            CustomTextButton(
                                buttonTextKey: confirmKey,
                                onTapButton: () {
                                  Navigator.pop(context);
                                  Utils.navigateToScreen(
                                      context, Routes.cartScreen,
                                      arguments: true);
                                },
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary))
                          ],
                        ),
                      )
                    : const SizedBox.shrink()
              ],
            );
          },
        );
      },
    ));
  }

  Widget get specialPriceText => CustomTextContainer(
      textKey: Utils.priceWithCurrencySymbol(
          price: widget.product.getPrice(), context: context),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isProductStyle1
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary,
          ));
  Widget get basePriceText => CustomTextContainer(
      textKey: Utils.priceWithCurrencySymbol(
          price: widget.product.getBasePrice(), context: context),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            decoration: TextDecoration.lineThrough,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.67),
          ));
  Widget get basePriceWithoutSpecialPrice => CustomTextContainer(
        textKey: Utils.priceWithCurrencySymbol(
            price: widget.product.getBasePrice(), context: context),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      );
  Widget get discountText => CustomTextContainer(
      textKey:
          "${Utils.formatDouble(widget.product.getDiscoutPercentage())}% off",
      style: Theme.of(context)
          .textTheme
          .labelSmall
          ?.copyWith(color: successStatusColor));

  Widget buildVaiantDropdown() {
    return GestureDetector(
        onTap: openBottomSheetForVariableProduct,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: CustomTextContainer(
                textKey: widget.product.selectedVariant!.variantValues ?? '',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ));
  }

  Stack buildOnImageWidgetsForStyle1(BuildContext context) {
    return Stack(
      children: [
        Positioned.directional(
          textDirection: Directionality.of(context),
          top: 7.5,
          end: 7.5,
          child: FavoriteButton(
            product: widget.product,
          ),
        ),
        if (widget.product.hasAnyRating())
          Positioned.directional(
            textDirection: Directionality.of(context),
            bottom: 7.5,
            end: 7.5,
            child: RatingAndReviewCountContainer(
              rating: widget.product.rating ?? "",
              ratingCount: widget.product.noOfRatings?.toString() ?? "",
            ),
          )
      ],
    );
  }

  Stack buildOnImageWidgetsForStyle2(BuildContext context) {
    return Stack(children: [
      widget.product.hasSpecialPrice()
          ? Positioned.directional(
              textDirection: Directionality.of(context),
              top: 0,
              end: 0,
              child: Container(
                  height: 20,
                  padding: const EdgeInsetsDirectional.all(2),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8))),
                  child: CustomTextContainer(
                      textKey:
                          "${Utils.formatDouble(widget.product.getDiscoutPercentage())}% off",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary))),
            )
          : const SizedBox(),
      Positioned.directional(
        textDirection: Directionality.of(context),
        bottom: 7.5,
        end: 7.5,
        child: FavoriteButton(product: widget.product),
      )
    ]);
  }

  Stack buildOnImageWidgetsForStyle3(BuildContext context) {
    return Stack(
      children: [
        Positioned.directional(
          textDirection: Directionality.of(context),
          top: 7.5,
          end: 7.5,
          child: FavoriteButton(
            product: widget.product,
          ),
        ),
        widget.product.hasSpecialPrice()
            ? Positioned.directional(
                textDirection: Directionality.of(context),
                top: 0,
                start: 0,
                child: Container(
                    height: 20,
                    padding: const EdgeInsetsDirectional.all(2),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8))),
                    child: CustomTextContainer(
                        textKey:
                            "${Utils.formatDouble(widget.product.getDiscoutPercentage())}% off",
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary))),
              )
            : const SizedBox(),
      ],
    );
  }

  buildPriceWidgetForSimpleProduct(BuildContext context) {
    return [
      if (widget.product.hasSpecialPrice()) ...[
        specialPriceText,
        const SizedBox(
          width: 4,
        ),
        basePriceText,
        const SizedBox(
          width: 4,
        ),
        if (isProductStyle1) discountText else const SizedBox(),
      ] else ...[
        basePriceWithoutSpecialPrice,
      ],
    ];
  }

  buildPriceWidgetForVariableProduct(BuildContext context) {
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
             
                child: widget.product.hasSpecialPrice()
                    ? specialPriceText
                    : basePriceWithoutSpecialPrice,
              ),
              if (widget.product.selectedVariant != null && !isProductStyle1)
                Flexible(flex: 1, child: buildVaiantDropdown())
            ],
          ),
        ],
      ),
      if (widget.product.hasSpecialPrice()) ...[
        basePriceText,
        if (isProductStyle1) ...[
          const SizedBox(
            width: 4,
          ),
          discountText
        ] else
          const SizedBox(),
      ]
    ];
  }

  isProductAddedinCart() {
    return context.read<GetUserCartCubit>().getCartDetail().cartProducts !=
            null &&
        context
                .read<GetUserCartCubit>()
                .getCartDetail()
                .cartProducts!
                .indexWhere((element) =>
                    element.productDetails![0].id == widget.product.id) !=
            -1;
  }
}
