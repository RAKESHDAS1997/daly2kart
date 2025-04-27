import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/product/productsCubit.dart';
import 'package:eshop_pro/cubits/seller/bestSellerCubit.dart';
import 'package:eshop_pro/cubits/storesCubit.dart';
import 'package:eshop_pro/ui/screens/explore/exploreScreen.dart';
import 'package:eshop_pro/ui/screens/explore/widgets/allFeaturedSellerList.dart';
import 'package:eshop_pro/ui/screens/home/widgets/buildHeader.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/ui/widgets/customImageWidget.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/ui/widgets/error_screen.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/settingsAndLanguagesCubit.dart';
import '../../../../data/models/product.dart';
import '../../../../data/models/seller.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/designConfig.dart';

class BestSellerSection extends StatelessWidget {
  BestSellerSection({Key? key}) : super(key: key);
  List<Product> products = [];
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductsCubit(),
      child: MultiBlocListener(
          listeners: [
            BlocListener<BestSellersCubit, BestSellersState>(
              listener: (context, state) {
                if (state is BestSellersFetchSuccess) {
                  // For each seller, fetch their products
                  state.sellers.forEach((seller) {
                    context.read<ProductsCubit>().getProducts(
                        storeId:
                            context.read<StoresCubit>().getDefaultStore().id!,
                        sellerId: seller.sellerId);
                  });
                }
              },
            ),
          ],
          child: BlocBuilder<BestSellersCubit, BestSellersState>(
            builder: (context, state) {
              if (state is BestSellersFetchSuccess) {
                return Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  padding: const EdgeInsetsDirectional.symmetric(
                      vertical: appContentHorizontalPadding),
                  margin: const EdgeInsetsDirectional.only(
                      bottom: appContentHorizontalPadding / 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BuildHeader(
                          title: bestSellersTitleKey,
                          subtitle: bestSellersDescKey,
                          showSeeAllButton: state.sellers.length >
                              maxLimitOfBestSellersInHome,
                          onTap: () => Utils.navigateToScreen(
                              context, Routes.allFeaturedSellerList,
                              arguments: AllFeaturedSellerList.buildArguments(
                                  title: bestSellersTitleKey,
                                  sellers: state.sellers.toList()))),
                      DesignConfig.defaultHeightSizedBox,
                      SizedBox(
                        height: 360,
                        child: ListView.separated(
                            separatorBuilder: (context, index) =>
                                DesignConfig.defaultWidthSizedBox,
                            padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: appContentHorizontalPadding),
                            clipBehavior: Clip.none,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: state.sellers.length >
                                    maxLimitOfBestSellersInHome
                                ? maxLimitOfBestSellersInHome
                                : state.sellers.length,
                            itemBuilder: (context, index) {
                              final seller = state.sellers[index];
                              return BlocBuilder<ProductsCubit, ProductsState>(
                                builder: (context, productstate) {
                                  List<Product> products = [];
                                  int totalProducts = 0;
                                  if (productstate is ProductsFetchSuccess) {
                                    if (productstate.sellerId ==
                                        seller.sellerId) {
                                      products.addAll(productstate.products);
                                      totalProducts = productstate.total;
                                    }
                                    if (totalProducts > 0) {
                                      return SellerListItem(
                                        seller: seller,
                                        products: products,
                                        totalProducts: seller.totalProducts ??
                                            totalProducts,
                                        isLoading: productstate
                                                is ProductsFetchInProgress &&
                                            productstate.sellerId ==
                                                seller.sellerId,
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  }
                                  if (state is ProductsFetchInProgress) {
                                    return CustomCircularProgressIndicator(
                                      indicatorColor:
                                          Theme.of(context).colorScheme.primary,
                                    );
                                  }
                                  return ErrorScreen(
                                      text: '',
                                      onPressed: () {
                                        state.sellers.forEach((seller) {
                                          context
                                              .read<ProductsCubit>()
                                              .getProducts(
                                                  storeId: context
                                                      .read<StoresCubit>()
                                                      .getDefaultStore()
                                                      .id!,
                                                  sellerId: seller.sellerId);
                                        });
                                      });
                                },
                              );
                            }),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          )),
    );
  }
}

class SellerListItem extends StatelessWidget {
  final Seller seller;
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final int totalProducts;

  const SellerListItem(
      {required this.seller,
      required this.products,
      this.isLoading = false,
      this.error,
      required this.totalProducts});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => totalProducts > 0
          ? 

          Utils.navigateToScreen(
              context,
              Routes.sellerDetailScreen,
              arguments: {
                'seller': seller,
              },
            )
          : null,
      child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          padding: const EdgeInsetsDirectional.all(appContentHorizontalPadding),
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8)),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomImageWidget(
                      url: seller.storeThumbnail ?? '',
                      borderRadius: 8,
                      width: 70,
                      height: 70,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextContainer(
                            textKey: seller.storeName ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text.rich(
                            TextSpan(
                              style: Theme.of(context).textTheme.labelMedium!,
                              children: [
                                TextSpan(
                                  text: context
                                      .read<SettingsAndLanguagesCubit>()
                                      .getTranslatedValue(
                                          labelKey: productsKey),
                                ),
                                const TextSpan(
                                  text: ' : ',
                                ),
                                TextSpan(text: totalProducts.toString()),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                DesignConfig.defaultHeightSizedBox,
                LayoutBuilder(builder: (context, boxConstraints) {
                  return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(
                          totalProducts > 4 ? 4 : totalProducts, (index) {
                        final product = products[index];
                        if (isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (error != null)
                          // ignore: curly_braces_in_flow_control_structures
                          return CustomTextContainer(
                            textKey: error!,
                            style: const TextStyle(color: Colors.red),
                          );
                        else if (products.isNotEmpty)
                          // ignore: curly_braces_in_flow_control_structures
                          return GestureDetector(
                            onTap: () => Utils.navigateToScreen(
                                context, Routes.exploreScreen,
                                arguments: ExploreScreen.buildArguments(
                                  title: bestSellersTitleKey,
                                  sellerId: seller.sellerId,
                                )),
                            child: Container(
                                width: (MediaQuery.of(context).size.width *
                                        0.7 /
                                        2) -
                                    (appContentHorizontalPadding * 2),
                                height: (MediaQuery.of(context).size.width *
                                        0.7 /
                                        2) -
                                    (appContentHorizontalPadding * 2),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: index == 3 && totalProducts > 3
                                      ? Colors.black.withOpacity(0.5)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(product.image ?? ''),
                                    fit: BoxFit.cover,
                                    colorFilter: index == 3 && totalProducts > 3
                                        ? ColorFilter.mode(
                                            Colors.black.withOpacity(0.5),
                                            BlendMode.srcATop)
                                        : null,
                                  ),
                                ),
                                child: index == 3 && totalProducts > 3
                                    ? CustomTextContainer(
                                        textKey: '+${totalProducts - 4}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall!
                                            .copyWith(color: Colors.white),
                                      )
                                    : null),
                          );

                        return const Center(
                            child: CustomTextContainer(
                                textKey: 'No products available'));
                      }));
                })
              ])),
    );
  }
}
