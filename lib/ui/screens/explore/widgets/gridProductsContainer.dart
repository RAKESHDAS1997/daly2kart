import 'package:eshop_pro/app/routes.dart';

import 'package:eshop_pro/data/models/product.dart';

import 'package:eshop_pro/ui/screens/home/widgets/productCard.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/productDetailsScreen.dart';

import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/ui/widgets/customTextButton.dart';

import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';


class GridProductsContainer extends StatelessWidget {
  final bool isExploreScreen;
  final bool forSellerDetailScreen;

  final List<Product> products;
  final Function loadMoreProducts;
  final bool hasMore;
  final bool fetchMoreError;

  const GridProductsContainer({
    super.key,
    this.isExploreScreen = true,
    this.forSellerDetailScreen = false,
    required this.products,
    required this.loadMoreProducts,
    required this.hasMore,
    required this.fetchMoreError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: !isExploreScreen && !forSellerDetailScreen
            ? 0
            : MediaQuery.of(context).padding.top +
                appContentHorizontalPadding +
                130,
      ),
      Flexible(
          child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).colorScheme.primaryContainer,
        padding: const EdgeInsetsDirectional.only(
          start: appContentHorizontalPadding,
          end: appContentHorizontalPadding,
        ),
        child: NotificationListener<ScrollUpdateNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels ==
                notification.metrics.maxScrollExtent) {
              if (hasMore) {
                loadMoreProducts();
              }
            }
            return true;
          },
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.only(
              top: appContentHorizontalPadding,
              bottom: 75,
            ),
            child: LayoutBuilder(builder: (context, boxConstraint) {
              return Wrap(
                alignment: WrapAlignment.start,
                spacing: appContentHorizontalPadding,
                runSpacing: appContentHorizontalPadding,
                children: List.generate(products.length, (index) {
                  final product = products[index];

                  if (hasMore) {
                 
                    if (index == products.length - 1) {
             
                      if (fetchMoreError) {
                        return Center(
                          child: CustomTextButton(
                              buttonTextKey: retryKey,
                              onTapButton: () {
                                loadMoreProducts();
                              }),
                        );
                      }

                      return Center(
                        child: CustomCircularProgressIndicator(
                            indicatorColor:
                                Theme.of(context).colorScheme.primary),
                      );
                    }
                  }
                  return GestureDetector(
                      onTap: () => {
                            Utils.navigateToScreen(
                                context, Routes.productDetailsScreen,
                                arguments: product.type == comboProductType
                                    ? ProductDetailsScreen.buildArguments(
                                        product: product, isComboProduct: true)
                                    : ProductDetailsScreen.buildArguments(
                                        product: product,
                                      ))
                          },
                      child: ProductCard(
                        product: product,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ));
                }).toList(),
              );
            }),
          ),
        ),
      ))
    ]);
  }
}
