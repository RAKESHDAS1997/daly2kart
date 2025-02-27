
import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/brand/brandsCubit.dart';
import 'package:eshop_pro/cubits/storesCubit.dart';
import 'package:eshop_pro/ui/screens/explore/exploreScreen.dart';
import 'package:eshop_pro/ui/screens/home/widgets/buildHeader.dart';
import 'package:eshop_pro/ui/widgets/customImageWidget.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/brand.dart';
import '../../../../utils/utils.dart';

class BrandSection extends StatelessWidget {
  BrandSection({Key? key}) : super(key: key);
  double extraWidthAndHeight = 0;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    extraWidthAndHeight = context
                .read<StoresCubit>()
                .getDefaultStore()
                .storeSettings!
                .brandStyle ==
            'brands_style_1'
        ? 0
        : 10;
    return BlocConsumer<BrandsCubit, BrandsState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is BrandsFetchSuccess) {
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
                  title: brandsKey,
                  onTap: () {},
                  showSeeAllButton: false,
                ),
                DesignConfig.defaultHeightSizedBox,
                SizedBox(
                  height: (context
                              .read<StoresCubit>()
                              .getDefaultStore()
                              .storeSettings!
                              .brandStyle ==
                          'brands_style_1')
                      ? 150 + extraWidthAndHeight
                      : 100 + extraWidthAndHeight,
                  child: ListView.separated(
                      separatorBuilder: (context, index) =>
                          DesignConfig.defaultWidthSizedBox,
                      padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: appContentHorizontalPadding),
                      clipBehavior: Clip.none,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                 
                      itemCount: state.brands.length,
                      itemBuilder: (context, index) =>
                          buildBrands(state.brands[index], size, context)),
                ),
              ],
            ),
          );
        }
        return const Center(child: SizedBox.shrink());
      },
    );
  }

//here Brands_card_style set in every store. 'style_1' is for rectangle and 'style_2' is for square. 'style_3' is for circle
//Brands_style is whether to display Brands name or not
  buildBrands(Brand brand, Size size, BuildContext context) {
    return GestureDetector(
      onTap: () => Utils.navigateToScreen(context, Routes.exploreScreen,
          arguments: ExploreScreen.buildArguments(
              brandId: brand.id.toString(), title: brand.name)),
      child: SizedBox(
        width: 75 + extraWidthAndHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomImageWidget(
              url: brand.image!,
              width: 75 + extraWidthAndHeight,
              height: 100 + extraWidthAndHeight,
              borderRadius: borderRadius,
            ),
            if (context
                    .read<StoresCubit>()
                    .getDefaultStore()
                    .storeSettings!
                    .brandStyle ==
                'brands_style_1') ...[
              const SizedBox(
                height: 8,
              ),
              Expanded(
                child: CustomTextContainer(
                  textKey: brand.name ?? "",
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}
