import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/product/getProductRatingCubit.dart';
import 'package:eshop_pro/data/models/product.dart';
import 'package:eshop_pro/ui/widgets/customDefaultContainer.dart';
import 'package:eshop_pro/ui/widgets/customImageWidget.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomerPhotoContainer extends StatefulWidget {
  final Product product;
  final bool isComboProduct;
  const CustomerPhotoContainer(
      {Key? key, required this.product, required this.isComboProduct})
      : super(key: key);

  @override
  _CustomerPhotoContainerState createState() => _CustomerPhotoContainerState();
}

class _CustomerPhotoContainerState extends State<CustomerPhotoContainer> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<ProductRatingCubit>().getProductRating(
          params: {
            Api.productIdApiKey: widget.product.id,
            Api.hasImagesApiKey: 1,
          },
          apiUrl: widget.isComboProduct
              ? Api.getComboProductRating
              : Api.getProductRating);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductRatingCubit, ProductRatingState>(
      builder: (context, state) {
        if (state is ProductRatingSuccess &&
            state.productRating.ratingData.isNotEmpty) {
          return CustomDefaultContainer(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              DesignConfig.smallHeightSizedBox,
              CustomTextContainer(
                  textKey: imagesUploadedByCustomersKey,
                  style: Theme.of(context).textTheme.titleMedium),
              DesignConfig.smallHeightSizedBox,
              SizedBox(
                height: 90,
                child: ListView.separated(
                    separatorBuilder: (context, index) =>
                        DesignConfig.smallWidthSizedBox,
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        state.productRating.getAllImages().keys.length > 4
                            ? 4
                            : state.productRating.getAllImages().keys.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: () => Utils.navigateToScreen(
                                context, Routes.fullScreenImageScreen,
                                arguments: {
                                  'imageUrl': state.productRating
                                      .getAllImages()
                                      .keys
                                      .toList()[index],
                                  'reviews': state.productRating
                                      .getAllImages()
                                      .values
                                      .toList(),
                                  'index': index,
                                  'imageUrls': state.productRating
                                      .getAllImages()
                                      .keys
                                      .toList()
                                }),
                            child: CustomImageWidget(
                              url: state.productRating
                                  .getAllImages()
                                  .keys
                                  .toList()[index],
                              width: (MediaQuery.of(context).size.width / 4) -
                                  (appContentHorizontalPadding),
                              height: 90,
                              borderRadius: borderRadius,
                            ),
                          ),
                          if (index == 3 &&
                              state.productRating.getAllImages().keys.length >
                                  4)
                            GestureDetector(
                              onTap: () => Utils.navigateToScreen(
                                  context, Routes.customerImagesScreen,
                                  arguments: {
                                    'productId': widget.product.id,
                                    'isComboProduct': widget.isComboProduct
                                  }),
                              child: Container(
                                height: 90,
                                width: (MediaQuery.of(context).size.width / 4) -
                                    (appContentHorizontalPadding),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.5),
                                  borderRadius:
                                      BorderRadius.circular(borderRadius),
                                ),
                                alignment: Alignment.center,
                                child: CustomTextContainer(
                                    textKey:
                                        '+${state.productRating.getAllImages().length - 3}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary)),
                              ),
                            )
                        ],
                      );
                    }),
              )
            ]),
          );
        }
        return const SizedBox();
      },
    );
  }
}
