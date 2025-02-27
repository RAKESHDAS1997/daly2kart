import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/product/comboProductsCubit.dart';
import 'package:eshop_pro/cubits/product/productsCubit.dart';
import 'package:eshop_pro/cubits/seller/sellersCubit.dart';
import 'package:eshop_pro/cubits/storesCubit.dart';
import 'package:eshop_pro/data/models/seller.dart';
import 'package:eshop_pro/ui/screens/explore/exploreScreen.dart';
import 'package:eshop_pro/ui/widgets/customAppbar.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/ui/widgets/customDefaultContainer.dart';
import 'package:eshop_pro/ui/widgets/customImageWidget.dart';
import 'package:eshop_pro/ui/widgets/customRoundedButton.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/ui/widgets/error_screen.dart';
import 'package:eshop_pro/ui/widgets/favoriteButton.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class SellerDetailScreen extends StatefulWidget {
  final Seller? seller;
  final int? sellerId;
  const SellerDetailScreen({Key? key, this.seller, this.sellerId})
      : super(key: key);
  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return BlocProvider(
      create: (context) => SellersCubit(),
      child: SellerDetailScreen(
        seller: arguments['seller'] as Seller?,
        sellerId: arguments['sellerId'] as int?,
      ),
    );
  }

  @override
  _SellerDetailScreenState createState() => _SellerDetailScreenState();
}

class _SellerDetailScreenState extends State<SellerDetailScreen> {
  Seller? seller;
  bool _isExpanded = false;
  @override
  void initState() {
    super.initState();
    if (widget.seller != null) {
      seller = widget.seller!;
    } else {
      Future.delayed(Duration.zero, () => fetchSeller());
    }
  }

  fetchSeller() {
    context.read<SellersCubit>().getSellers(
        storeId: context.read<StoresCubit>().getDefaultStore().id!,
        sellerIds: [widget.sellerId!]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        titleKey: sellerDetailsKey,
      ),
      body: BlocListener<SellersCubit, SellersState>(listener:
          (context, state) {
        if (state is SellersFetchSuccess) {
          setState(() {
            seller = state.sellers.first;
          });
        }
      }, child:
          BlocBuilder<SellersCubit, SellersState>(builder: (context, state) {
        if (seller != null || state is SellersFetchSuccess) {
          return Column(
            children: <Widget>[
              const SizedBox(
                height: 12,
              ),
              sellerDetailContainer(),
              DesignConfig.smallHeightSizedBox,
              Expanded(
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => ProductsCubit(),
                    ),
                    BlocProvider(
                      create: (context) => ComboProductsCubit(),
                    ),
                  ],
                  child: ExploreScreen(
                    sellerId: seller!.sellerId,
                    isExploreScreen: false,
                    forSellerDetailScreen: true,
                  ),
                ),
              )
            ],
          );
        } else if (state is SellersFetchFailure) {
          return ErrorScreen(text: state.errorMessage, onPressed: fetchSeller);
        } else {
          return CustomCircularProgressIndicator(
            indicatorColor: Theme.of(context).colorScheme.primary,
          );
        }
      })),
    );
  }

  sellerDetailContainer() {
    return CustomDefaultContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CustomImageWidget(
                  url: seller!.storeLogo ?? "",
                  borderRadius: 50,
                  isCircularImage: true,
                ),
                DesignConfig.defaultWidthSizedBox,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextContainer(
                              textKey: seller!.storeName ?? "",
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          FavoriteButton(
                            size: 40,
                            isSeller: true,
                            sellerId: widget.seller != null
                                ? widget.seller!.sellerId
                                : widget.sellerId,
                            seller: seller,
                            unFavoriteColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                      DesignConfig.smallHeightSizedBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Column(
                                  children: [
                                    CustomTextContainer(
                                        textKey:
                                            seller!.totalProducts.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                    const SizedBox(height: 2),
                                    CustomTextContainer(
                                        textKey: productsKey,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  color: Theme.of(context)
                                      .inputDecorationTheme
                                      .iconColor,
                                  width: 1,
                                  height: 50,
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        CustomTextContainer(
                                            textKey:
                                                seller!.sellerRating.toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    CustomTextContainer(
                                        textKey: ratingsKey,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05),
                          CustomRoundedButton(
                            widthPercentage: 0.2,
                            buttonTitle: chatKey,
                            horizontalPadding: 5,
                            height: 36,
                            showBorder: false,
                            onTap: () => Utils.navigateToScreen(
                                context, Routes.chatScreen,
                                arguments: seller!.userId),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (seller!.storeDescription != null &&
              seller!.storeDescription!.isNotEmpty) ...[
            const SizedBox(
              height: 20,
            ),
            Text.rich(
              TextSpan(
                text: _isExpanded
                    ? seller!.storeDescription ?? ""
                    : seller!.storeDescription?.substring(
                            0,
                            seller!.storeDescription!.length > 100
                                ? 100
                                : seller!.storeDescription?.length) ??
                        "",
                children: [
                  if (seller!.storeDescription != null &&
                      seller!.storeDescription!.length > 100)
                    TextSpan(
                      text: _isExpanded ? " Read Less" : "... Read More",
                      style: Theme.of(context).textTheme.bodyMedium,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                    ),
                ],
              ),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.8),
                  ),
            ),
          ]
        ],
      ),
    );
  }
}
