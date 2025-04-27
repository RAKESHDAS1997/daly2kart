import 'package:eshop_pro/cubits/product/productsCubit.dart';
import 'package:eshop_pro/cubits/storesCubit.dart';
import 'package:eshop_pro/data/models/product.dart';
import 'package:eshop_pro/ui/screens/home/widgets/productCard.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/ui/widgets/customDefaultContainer.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/hiveBoxKeys.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class FrequentlyWatchedProductsContainer extends StatefulWidget {
  final Product? product;
  const FrequentlyWatchedProductsContainer({Key? key, this.product})
      : super(key: key);

  @override
  State<FrequentlyWatchedProductsContainer> createState() =>
      _FrequentlyWatchedProductsContainerState();
}

class _FrequentlyWatchedProductsContainerState
    extends State<FrequentlyWatchedProductsContainer> {
  @override
  initState() {
    super.initState();
    List? productIds = Hive.box(productsBoxKey).values.toList();
    if (productIds.isNotEmpty) {
      Future.delayed(Duration.zero, () {
        context.read<ProductsCubit>().getProducts(
            storeId: context.read<StoresCubit>().getDefaultStore().id!,
            productIds: productIds.map((item) => item as int).toList());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductsCubit, ProductsState>(
      listener: (context, state) {
        if (state is ProductsFetchSuccess && widget.product != null) {
          state.products
              .removeWhere((element) => element.id == widget.product!.id);
        }
      },
      builder: (context, state) {
        if (state is ProductsFetchSuccess) {
          return Column(
            children: [
              DesignConfig.smallHeightSizedBox,
              CustomDefaultContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomTextContainer(
                      textKey: recentlyViewedKey,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    DesignConfig.defaultHeightSizedBox,
                    SizedBox(
                      height: 360,
                      child: ListView.separated(
                        separatorBuilder: (context, index) =>
                            DesignConfig.defaultWidthSizedBox,
                        padding: const EdgeInsetsDirectional.only(
                            end: appContentHorizontalPadding),
                        clipBehavior: Clip.none,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: state.products.length,
                        itemBuilder: (context, index) => ProductCard(
                          product: state.products[index],
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        }
        if (state is ProductsFetchInProgress) {
          return CustomCircularProgressIndicator(
            indicatorColor: Theme.of(context).colorScheme.primary,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
