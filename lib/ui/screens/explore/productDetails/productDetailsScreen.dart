import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/address/cityCubit.dart';
import 'package:eshop_pro/cubits/address/zipcodeCubit.dart';
import 'package:eshop_pro/cubits/cart/getUserCart.dart';
import 'package:eshop_pro/cubits/cart/manageCartCubit.dart';
import 'package:eshop_pro/cubits/faq/faqCubit.dart';
import 'package:eshop_pro/cubits/product/checkProductDeliverabilityCubit.dart';
import 'package:eshop_pro/cubits/product/getProductRatingCubit.dart';

import 'package:eshop_pro/cubits/product/productsCubit.dart';
import 'package:eshop_pro/cubits/settingsAndLanguagesCubit.dart';
import 'package:eshop_pro/cubits/storesCubit.dart';
import 'package:eshop_pro/data/models/cart.dart';

import 'package:eshop_pro/data/models/product.dart';

import 'package:eshop_pro/ui/screens/explore/productDetails/widgets/checkDeliverableContainer.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/widgets/compareWithSimilarItemsContainer.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/widgets/offerContainer.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/widgets/productDetailsContainer.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/widgets/productFaqContainer.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/widgets/productInfoContainer.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/widgets/ratingContainer.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/widgets/sellerDetailContainer.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/widgets/similarProductContainer.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/widgets/variantContainer.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/widgets/variantSelector.dart';
import 'package:eshop_pro/ui/widgets/addToCartButton.dart';

import 'package:eshop_pro/ui/widgets/customAppbar.dart';
import 'package:eshop_pro/ui/widgets/customBottomButtonContainer.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/ui/widgets/customDefaultContainer.dart';
import 'package:eshop_pro/ui/widgets/customImageWidget.dart';
import 'package:eshop_pro/ui/widgets/customRoundedButton.dart';
import 'package:eshop_pro/ui/widgets/customTextButton.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/ui/widgets/error_screen.dart';
import 'package:eshop_pro/ui/widgets/favoriteButton.dart';

import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/hiveBoxKeys.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final List<int>? productIds;
  final bool? isComboProduct;
  final int? storeId;
  const ProductDetailsScreen(
      {super.key,
      required this.product,
      required this.productIds,
      this.isComboProduct,
      this.storeId});

  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProductsCubit(),
        ),
        BlocProvider(
          create: (context) => ProductRatingCubit(),
        ),
        BlocProvider(
          create: (context) => FAQCubit(),
        ),
      ],
      child: ProductDetailsScreen(
        product: arguments['product'] as Product,
        productIds: arguments['productIds'] as List<int>?,
        isComboProduct: arguments['isComboProduct'] ?? false,
        storeId: arguments['storeId'] as int?,
      ),
    );
  }

  static Map<String, dynamic> buildArguments(
      {required Product product,
      List<int>? productIds,
      bool? isComboProduct,
      int? storeId}) {
    return {
      'product': product,
      'productIds': productIds,
      'isComboProduct': isComboProduct,
      'storeId': storeId
    };
  }

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Product product;

  List<Product> comboProducts = [];
  CartProduct? cartProduct;
  final GlobalKey<RatingContainerState> _ratingkey =
      GlobalKey<RatingContainerState>();

  GlobalKey _infoKey = GlobalKey(),
      _detailsKey = GlobalKey(),
      _sellerKey = GlobalKey(),
      _faqKey = GlobalKey(),
      _similarKey = GlobalKey();
  List<String> productVariantIds = [];
  @override
  void initState() {
    super.initState();
    product = widget.product;
  
    if (product.type == comboProductType) {
      productVariantIds = widget.product.productVariantIds!.split(',').toList();
      setVariantOfCombo();
    }
    Future.delayed(Duration.zero, () {
      if (widget.productIds != null) {
        context.read<ProductsCubit>().getProducts(
            storeId: widget.storeId ??
                context.read<StoresCubit>().getDefaultStore().id!,
            isComboProduct: widget.isComboProduct ?? false,
            productIds: widget.productIds!);
      }
    });

    addProductId(product.id!);
  }

  void addProductId(int productId) {
    if (!Hive.box(productsBoxKey).containsKey(productId)) {
      if (Hive.box(productsBoxKey).values.length >= 5) {
        Hive.box(productsBoxKey).delete(Hive.box(productsBoxKey).values.first);
      }

      Hive.box(productsBoxKey).put(productId, productId);
    }
  }


  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return Scaffold(
        appBar: buildAppBar(),
        bottomNavigationBar: BlocBuilder<GetUserCartCubit, GetUserCartState>(
          builder: (context, state) {
            if (state is GetUserCartFetchSuccess &&
                state.cart.cartProducts != null &&
                product.type == variableProductType &&
                product.selectedVariant != null) {
              cartProduct = state.cart.cartProducts!.firstWhereOrNull(
                  (element) =>
                      element.productVariantId == product.selectedVariant!.id);
            }
            return BlocBuilder<ManageCartCubit, ManageCartState>(
              builder: (context, state) {
                if (widget.productIds == null ||
                    context.read<ProductsCubit>().state
                        is ProductsFetchSuccess) {
                  return buildBottomBar();
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
        body: BlocConsumer<ProductsCubit, ProductsState>(
            listener: (context, state) {
          if (state is ProductsFetchSuccess) {
            if (state.products.isNotEmpty) {
              // updateCartProducts(state.products);

              //here we will assign the first
              // product to the product variable only if we are
              //not passing the product model in arguments
              if (state.products[0].id == widget.productIds![0]) {
                setState(() {
                  product = state.products[0];
                });
              }
            }
          }
        }, builder: (context, state) {
          if (widget.productIds == null || state is ProductsFetchSuccess) {
            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels > 100) {
                  // Trigger the animation when user scrolls past 100 pixels
                  _ratingkey.currentState?.onScroll();
                }
                return true;
              },
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.only(bottom: 12),
                child: Column(
                  children: [
                    ProductInfoContainer(
                      product: product,
                      key: _infoKey,
                      isFullScreen: orientation == Orientation.landscape,
                    ),
                    if (widget.product.type != comboProductType &&
                        product.productType == variableProductType) ...[
                      DesignConfig.smallHeightSizedBox,
                      if (context
                              .read<StoresCubit>()
                              .getDefaultStore()
                              .storeSettings!
                              .productStyle ==
                          'style_1')
                        VariantContainer(
                          product: product,
                          onVariantSelected: () {
                            setState(() {
                              _infoKey = GlobalKey();
                            });
                          },
                        )
                      else
                        VariantSelector(
                            variants: product.variants ?? [], product: product),
                    ],

                    if (widget.product.type == comboProductType) ...[
                      comboProductsContainer(widget.product.productDetails!),
                      DesignConfig.smallHeightSizedBox,
                    ],
                    ProductDetailsContainer(
                      product: product,
                      key: _detailsKey,
                    ),
                    DesignConfig.smallHeightSizedBox,
                    const OfferContainer(title: allOffersAndCouponsKey),

                    compareWithSimilarItemsContainer(product: product),
                    if (product.productType != digitalProductType) ...[
                      DesignConfig.smallHeightSizedBox,
                      MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (context) => CityCubit(),
                          ),
                          BlocProvider(
                            create: (context) => ZipcodeCubit(),
                          ),
                          BlocProvider(
                            create: (context) =>
                                CheckProductDeliverabilityCubit(),
                          ),
                        ],
                        child: CheckDeliverableContainer(product: product),
                      ),
                    ],
                    DesignConfig.smallHeightSizedBox,
                    SellerDetailContainer(
                      product: product,
                      key: _sellerKey,
                    ),
                    RatingContainer(
                      product: product,
                      isComboProduct: widget.product.type == comboProductType
                          ? true
                          : false,
                      key: _ratingkey,
                      isFullScreen: false,
                    ),
                    ProductFaqContainer(
                      product: product,
                      key: _faqKey,
                    ),
                 
                    BlocProvider(
                      create: (context) => ProductsCubit(),
                      child: SimilarProductContainer(
                        product: product,
                        key: _similarKey,
                      ),
                    )
                  ],
                ),
              ),
            );
          }
          if (state is ProductsFetchFailure) {
            return ErrorScreen(
                text: state.errorMessage,
                onPressed: () {
                  if (widget.productIds != null) {
                    context.read<ProductsCubit>().getProducts(
                        storeId:
                            context.read<StoresCubit>().getDefaultStore().id!,
                        productIds: widget.productIds!);
                  }
                });
          }
          return CustomCircularProgressIndicator(
            indicatorColor: Theme.of(context).colorScheme.primary,
          );
        }),
      );
    });
  }

  CustomAppbar buildAppBar() {
    return CustomAppbar(
      titleKey: "",
      trailingWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Utils.searchIcon(context),
          FavoriteButton(
            product: widget.product.type == comboProductType
                ? widget.product
                : product,
            size: 40,
          ),
          Utils.cartIcon(context),
        ],
      ),
    );
  }

  comboProductsContainer(List<Product> comboProducts) {
    return CustomDefaultContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextContainer(
            textKey: '${comboProducts.length} Items in this combo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          DesignConfig.defaultHeightSizedBox,
          ListView.separated(
              separatorBuilder: (context, index) =>
                  DesignConfig.defaultHeightSizedBox,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comboProducts.length,
              itemBuilder: (context, index) {
                Product currentProduct = comboProducts[index];

                return GestureDetector(
                  onTap: () {
                    Utils.navigateToScreen(context, Routes.productDetailsScreen,
                        arguments: ProductDetailsScreen.buildArguments(
                            product: currentProduct));
                  },
                  child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                          vertical: appContentHorizontalPadding / 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CustomImageWidget(
                              url: currentProduct.type == variableProductType
                                  ? currentProduct.selectedVariant != null &&
                                          currentProduct.selectedVariant!
                                              .images!.isNotEmpty
                                      ? currentProduct
                                          .selectedVariant!.images!.first
                                      : currentProduct.image ?? ''
                                  : currentProduct.image ?? '',
                              width: 86,
                              height: 100,
                              borderRadius: 8),
                          DesignConfig.smallWidthSizedBox,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                CustomTextContainer(
                                  textKey: currentProduct.type ==
                                              variableProductType &&
                                          currentProduct.selectedVariant != null
                                      ? '${currentProduct.name}/ ${currentProduct.selectedVariant!.variantValues}'
                                      : currentProduct.name ?? "",
                                  maxLines: 3,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                DesignConfig.smallHeightSizedBox,
                                CustomTextContainer(
                                    textKey: Utils.priceWithCurrencySymbol(
                                        price: currentProduct.hasSpecialPrice()
                                            ? currentProduct.getPrice()
                                            : currentProduct.getBasePrice(),
                                        context: context),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        )),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 24,
                          )
                        ],
                      )),
                );
              }),
        ],
      ),
    );
  }

  buildBottomBar() {
    if ((widget.product.type == comboProductType &&
            widget.product.isProductOutOfStock()) ||
        (product.type == variableProductType &&
            context
                    .read<StoresCubit>()
                    .getDefaultStore()
                    .storeSettings!
                    .productStyle ==
                'style_1' &&
            product.isVariantOutOfStock(
                product.selectedVariant ?? product.variants![0])) ||
        product.isProductOutOfStock()) {
      return Container(
        color: Theme.of(context).colorScheme.primary,
        child: const CustomRoundedButton(
            widthPercentage: 1.0,
            buttonTitle: outOfStockKey,
            showBorder: false),
      );
    }

    return product.type == variableProductType &&
            context
                    .read<StoresCubit>()
                    .getDefaultStore()
                    .storeSettings!
                    .productStyle !=
                'style_1'
        ? isProductAddedinCart()
            ? CustomBottomButtonContainer(
                child: Container(
                height: 50,
                padding: const EdgeInsetsDirectional.all(12),
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
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary)),
                    CustomTextButton(
                        buttonTextKey: confirmKey,
                        onTapButton: () => Utils.navigateToScreen(
                            context, Routes.cartScreen, arguments: true),
                        textStyle: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .copyWith(
                                color: Theme.of(context).colorScheme.onPrimary))
                  ],
                ),
              ))
            : const SizedBox.shrink()
        : CustomBottomButtonContainer(
            child: Row(
              children: [
                Expanded(
                  child: AddToCartButton(
                      widthPercentage: isProductAddedinCart() ? 1.0 : 0.4,
                      height: 40,
                      showButtonBorder: !isProductAddedinCart(),
                      isBuyNowButton: false,
                      productId: widget.product.type == comboProductType
                          ? widget.product.id!
                          : product.selectedVariant!.id!,
                      type: widget.product.type == comboProductType
                          ? 'combo'
                          : 'regular',
                      productType: product.productType!,
                      sellerId: product.sellerId!,
                      stock: product.type == variableProductType
                          ? product.selectedVariant!.stock!
                          : product.stock!,
                      stockType: widget.product.type == comboProductType
                          ? widget.product.stockType!
                          : product.stockType!,
                      qty: widget.product.type == comboProductType
                          ? widget.product.minimumOrderQuantity
                          : product.minimumOrderQuantity),
                ),
                if (!isProductAddedinCart()) ...[
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: AddToCartButton(
                        isBuyNowButton: true,
                        title: buyNowKey,
                        widthPercentage: 0.4,
                        height: 40,
                        sellerId: product.sellerId!,
                        productId: widget.product.type == comboProductType
                            ? widget.product.id!
                            : product.selectedVariant!.id!,
                        type: widget.product.type == comboProductType
                            ? 'combo'
                            : 'regular',
                        stockType: widget.product.type == comboProductType
                            ? widget.product.stockType!
                            : product.stockType!,
                        stock: product.type == variableProductType
                            ? product.selectedVariant!.stock!
                            : product.stock!,
                        productType: product.productType!,
                        qty: widget.product.type == comboProductType
                            ? widget.product.minimumOrderQuantity
                            : product.minimumOrderQuantity),
                  )
                ]
              ],
            ),
          );
  }

  isProductAddedinCart() {
    if (context
                .read<StoresCubit>()
                .getDefaultStore()
                .storeSettings!
                .productStyle ==
            'style_1' &&
        cartProduct != null) {
      return true;
    }
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

  void setVariantOfCombo() {
    for (String productId in widget.product.productIds!.split(',').toList()) {
      Product? product = widget.product.productDetails!
          .firstWhereOrNull((p) => p.id.toString() == productId);
      if (product != null) {
        // Create a deep copy of the product to avoid reference issues

        // You might also handle different variants manually based on your product structure

        setState(() {
          if (product.type == variableProductType &&
              productVariantIds.isNotEmpty) {
            var selectedVariant = product.variants!.firstWhere(
                (variant) => productVariantIds.contains(variant.id.toString()),
                orElse: () =>
                    product.variants!.first // default in case no match
                );

            product.selectedVariant = selectedVariant;
            // Remove the assigned variant id from the productVariantIds list
            productVariantIds.remove(selectedVariant.id.toString());
          } else {
            product.selectedVariant = product.variants!.first;
          }
        });
      }
    }
  }
}
