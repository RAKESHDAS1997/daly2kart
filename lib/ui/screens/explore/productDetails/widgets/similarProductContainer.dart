import 'package:eshop_pro/cubits/product/productsCubit.dart';
import 'package:eshop_pro/cubits/storesCubit.dart';
import 'package:eshop_pro/data/models/product.dart';
import 'package:eshop_pro/ui/screens/home/widgets/productCard.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/ui/widgets/customDefaultContainer.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SimilarProductContainer extends StatefulWidget {
  final Product product;
  const SimilarProductContainer({Key? key, required this.product})
      : super(key: key);

  @override
  _SimilarProductContainerState createState() =>
      _SimilarProductContainerState();
}

class _SimilarProductContainerState extends State<SimilarProductContainer> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<ProductsCubit>().getProducts(
          storeId: context.read<StoresCubit>().getDefaultStore().id!,
          categoryIds: widget.product.type == comboProductType
              ? null
              : widget.product.categoryId.toString(),
          productId: widget.product.type == comboProductType
              ? widget.product.id
              : null,
          apiUrl: widget.product.type == comboProductType
              ? Api.getSimilarComboProducts
              : Api.getSimilarProducts);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductsCubit, ProductsState>(
      listener: (context, state) {
        if (state is ProductsFetchSuccess) {
          state.products
              .removeWhere((element) => element.id == widget.product.id);
        }
      },
      builder: (context, state) {
        if (state is ProductsFetchSuccess && state.products.isNotEmpty) {
          return Column(
            children: [
              DesignConfig.smallHeightSizedBox,
              CustomDefaultContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomTextContainer(
                      textKey: similarProductsKey,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    DesignConfig.defaultHeightSizedBox,
                    SizedBox(
                      height: 365,
                      child: ListView.separated(
                        separatorBuilder: (context, index) =>
                            DesignConfig.defaultWidthSizedBox,
                        padding: const EdgeInsetsDirectional.only(
                            end: appContentHorizontalPadding),
                        clipBehavior: Clip.none,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: state.products.length,
                        itemBuilder: (context, index) =>
                            state.products[index].id != widget.product.id
                                ? ProductCard(
                                    product: state.products[index],
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  )
                                : SizedBox(),
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
