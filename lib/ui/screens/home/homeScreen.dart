import 'dart:io';

import 'package:eshop_pro/cubits/category/categorySliderCubit.dart';

import 'package:eshop_pro/cubits/offerCubit.dart';
import 'package:eshop_pro/cubits/product/mostSellingProductCubit.dart';
import 'package:eshop_pro/cubits/product/productsCubit.dart';
import 'package:eshop_pro/cubits/sectionCubit.dart';
import 'package:eshop_pro/cubits/seller/bestSellerCubit.dart';
import 'package:eshop_pro/cubits/settingsAndLanguagesCubit.dart';
import 'package:eshop_pro/cubits/sliderCubit.dart';
import 'package:eshop_pro/cubits/user_details_cubit.dart';
import 'package:eshop_pro/ui/screens/home/widgets/bestSellerSection.dart';
import 'package:eshop_pro/ui/screens/home/widgets/brandSection.dart';
import 'package:eshop_pro/ui/screens/home/widgets/categorySection.dart';
import 'package:eshop_pro/ui/screens/home/widgets/addDeliveryLocationWidget.dart';
import 'package:eshop_pro/ui/screens/home/widgets/categorySliderSection.dart';
import 'package:eshop_pro/ui/screens/home/widgets/featuredSectionContainer.dart';
import 'package:eshop_pro/ui/screens/home/widgets/featuredSellerSection.dart';
import 'package:eshop_pro/ui/screens/home/widgets/mostSellingProductSection.dart';
import 'package:eshop_pro/ui/screens/home/widgets/offerSection.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/ui/widgets/error_screen.dart';

import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/brand/brandsCubit.dart';
import '../../../cubits/category/category_cubit.dart';
import '../../../cubits/featuredSellerCubit.dart';
import '../../../cubits/storesCubit.dart';
import '../../../data/models/store.dart';
import 'widgets/homeAppBar.dart';
import 'widgets/sliderSection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey _deliveryWidgetKey = GlobalKey();
  @override
  void initState() {
    super.initState();

    checkForAppUpdate();
    getApiData();
  }

  checkForAppUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (context.read<SettingsAndLanguagesCubit>().state
          is SettingsAndLanguagesFetchSuccess) {
        if (context.read<SettingsAndLanguagesCubit>().isUpdateRequired()) {
          openUpdateDialog();
        }
      }
    });
  }

  getApiData() {
    Future.delayed(Duration.zero).then((value) {
      int storeId = context.read<StoresCubit>().getDefaultStore().id!;
      if (mounted) {
        context.read<CategoryCubit>().fetchCategories(storeId: storeId);
        context
            .read<CategorySliderCubit>()
            .getCategoriesSliders(storeId: storeId);
        context.read<OfferCubit>().getOfferSliders(storeId: storeId);
        context.read<SliderCubit>().getSliders(storeId: storeId);
        context
            .read<FeaturedSellerCubit>()
            .fetchFeaturedSellers(storeId: storeId);
        context.read<MostSellingProductsCubit>().getMostSellingProducts(
            storeId: storeId,
            userId: context.read<UserDetailsCubit>().getUserId());
        context.read<FeaturedSectionCubit>().getSections(storeId: storeId);
        context.read<BestSellersCubit>().getBestSellers(storeId: storeId);
        context.read<BrandsCubit>().getBrands(storeId: storeId);
      }
    });
  }

  openUpdateDialog() {
    Utils.openAlertDialog(context, barrierDismissible: false, onTapNo: () {
      exit(0); // Forcefully close the app
    }, onTapYes: () {
      Utils.rateApp(context);
    },
        message: forceUpdateTitleKey,
        content: forceUpdateDescKey,
        noLabel: exitKey,
        yesLabel: updateKey);
  }

  late Store defaultStore;
  @override
  Widget build(BuildContext context) {
    defaultStore = context.read<StoresCubit>().getDefaultStore();
    return Scaffold(
      appBar: HomeAppBar(),
      body: RefreshIndicator(
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        onRefresh: () async {
          //this will clear the text edit controller value
          setState(() {
            _deliveryWidgetKey = GlobalKey();
          });

          getApiData();
        },
        child: BlocBuilder<StoresCubit, StoresState>(builder: (context, state) {
          if (state is StoresFetchSuccess) {
            return ListView(
              children: <Widget>[
                AddDeliveryLocationWidget(key: _deliveryWidgetKey),
                CategorySection(),
                const SliderSection(),
                const FeaturedSellerSection(),
                BrandSection(),
                const CategorySliderSection(),
                const MostSellingProductSection(),
                BlocProvider(
                  create: (context) => ProductsCubit(),
                  child: const OfferSection(),
                ),
                BestSellerSection(),
                const FeaturedSectionContainer(),
              ],
            );
          }
          if (state is StoresFetchFailure) {
            return ErrorScreen(
                text: state.errorMessage,
                onPressed: () {
                  context.read<StoresCubit>().fetchStores();
                });
          }
          if (state is StoresFetchInProgress) {
            return Center(
                child: CustomCircularProgressIndicator(
              indicatorColor: Theme.of(context).colorScheme.primary,
            ));
          }
          return const Center(child: SizedBox.shrink());
        }),
      ),
    );
  }
}
