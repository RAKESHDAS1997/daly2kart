import 'dart:async';
import 'dart:io';

import 'package:eshop_pro/app/app.dart';
import 'package:eshop_pro/cubits/address/getAddressCubit.dart';
import 'package:eshop_pro/cubits/auth/authCubit.dart';
import 'package:eshop_pro/cubits/auth/generateReferCodeCubit.dart';
import 'package:eshop_pro/cubits/brand/brandsCubit.dart';
import 'package:eshop_pro/cubits/cart/getUserCart.dart';
import 'package:eshop_pro/cubits/cart/manageCartCubit.dart';
import 'package:eshop_pro/cubits/cart/removeProductFromCartCubit.dart';
import 'package:eshop_pro/cubits/category/categorySliderCubit.dart';
import 'package:eshop_pro/cubits/favorites/addFavoriteCubit.dart';
import 'package:eshop_pro/cubits/favorites/removeFavoriteCubit.dart';
import 'package:eshop_pro/cubits/featuredSellerCubit.dart';
import 'package:eshop_pro/cubits/offerCubit.dart';
import 'package:eshop_pro/cubits/product/comboProductsCubit.dart';
import 'package:eshop_pro/cubits/product/mostSellingProductCubit.dart';
import 'package:eshop_pro/cubits/product/productsCubit.dart';
import 'package:eshop_pro/cubits/sectionCubit.dart';
import 'package:eshop_pro/cubits/seller/bestSellerCubit.dart';
import 'package:eshop_pro/cubits/seller/sellersCubit.dart';
import 'package:eshop_pro/cubits/sliderCubit.dart';
import 'package:eshop_pro/cubits/updateUserCubit.dart';
import 'package:eshop_pro/cubits/user_details_cubit.dart';
import 'package:eshop_pro/data/models/product.dart';
import 'package:eshop_pro/data/repositories/notificationRepository.dart';
import 'package:eshop_pro/ui/screens/cart/cartScreen.dart';
import 'package:eshop_pro/ui/screens/categoty/categoryScreen.dart';
import 'package:eshop_pro/ui/screens/explore/exploreScreen.dart';
import 'package:eshop_pro/ui/screens/profile/customerSupport/chatScreen.dart';
import 'package:eshop_pro/ui/screens/profile/profileScreen.dart';
import 'package:eshop_pro/ui/widgets/appUnderMaintenanceContainer.dart';

import 'package:eshop_pro/utils/api.dart';

import 'package:eshop_pro/utils/hiveBoxKeys.dart';
import 'package:eshop_pro/utils/notificationUtility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';

import '../../app/routes.dart';

import '../../cubits/settingsAndLanguagesCubit.dart';
import '../../cubits/storesCubit.dart';
import '../../utils/constants.dart';
import '../../utils/labelKeys.dart';
import '../../utils/utils.dart';
import '../widgets/customCircularProgressIndicator.dart';
import '../widgets/error_screen.dart';
import 'home/homeScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static GlobalKey<MainScreenState> mainScreenKey =
      GlobalKey<MainScreenState>();
  static Widget getRouteInstance() => MultiBlocProvider(
        providers: [
          BlocProvider<CategorySliderCubit>(
              create: (_) => CategorySliderCubit()),
          BlocProvider<OfferCubit>(create: (context) => OfferCubit()),
          BlocProvider<SliderCubit>(create: (context) => SliderCubit()),
          BlocProvider<FeaturedSellerCubit>(
              create: (context) => FeaturedSellerCubit()),
          BlocProvider<MostSellingProductsCubit>(
              create: (context) => MostSellingProductsCubit(productRepository)),

          BlocProvider<FeaturedSectionCubit>(
              create: (context) => FeaturedSectionCubit()),
          BlocProvider<BrandsCubit>(create: (context) => BrandsCubit()),

          ///[ProductsCubit]
          BlocProvider<ProductsCubit>(create: (context) => ProductsCubit()),

          ///[Combo ProductsCubit]
          BlocProvider<ComboProductsCubit>(
              create: (context) => ComboProductsCubit()),

          ///[SellersCubit]
          BlocProvider<SellersCubit>(create: (context) => SellersCubit()),

          ///[BestSellersCubit for best sellers]
          BlocProvider<BestSellersCubit>(
              create: (context) => BestSellersCubit()),
          BlocProvider<UpdateUserCubit>(create: (context) => UpdateUserCubit()),

          /// to generate referral code
          BlocProvider<GenerateReferCodeCubit>(
              create: (context) => GenerateReferCodeCubit()),
          //remove product from cart cubit
        ],
        child: MainScreen(key: MainScreen.mainScreenKey),
      );
  @override
  MainScreenState createState() => MainScreenState();
}

List<Product> comparableProducts = [];
String? zipcode;

class MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _canPop = false;
  bool _isLoading = false;
  String channelName = '';
  GlobalKey _homeKey = GlobalKey(),
      _categoryKey = GlobalKey(),
      _exploreKey = GlobalKey(),
      _cartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    Future.delayed(Duration.zero).then((value) async {
      await NotificationUtility.setUpNotificationService(context);
      if (context.read<AuthCubit>().state is Authenticated) {
        channelName =
            context.read<SettingsAndLanguagesCubit>().getPusherChannerName();
        context.read<GetAddressCubit>().getAddress();
      } else {
        context.read<UserDetailsCubit>().resetUserDetailsState();
      }

      if (context.read<UserDetailsCubit>().state is UserDetailsFetchFailure &&
          !context.read<UserDetailsCubit>().isGuestUser()) {
        callUserApi();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeDependencies();

    if (state == AppLifecycleState.resumed) {
      NotificationRepository().getBGNotifications().then((notifications) {
        for (var notification in notifications) {
          NotificationUtility.onReceiveNotification(notification, context);
        }

        if (notifications.isNotEmpty) {
          NotificationRepository().clearNotification();
        }
      });
    }
  }

  callUserApi() {
    context
        .read<UserDetailsCubit>()
        .fetchUserDetails(params: Utils.getParamsForVerifyUser(context));
  }

  changeCurrentIndex(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 3) {
        _cartKey = GlobalKey();
      }
    });
  }

  @override
  void dispose() {
    if (pusherChannel != null) {
      pusherService.disconnectPusher(channelName);
      pusherChannel?.unsubscribe();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: _canPop,
        onPopInvokedWithResult: (didPop, result) {
          if (!_canPop) {
            Utils.openAlertDialog(context,
                message: areYouSureKey,
                content: areYouSureToExitAppKey,
                yesLabel: exitKey, onTapNo: () {
              Navigator.of(context).pop();
            }, onTapYes: () {
              _canPop = true;
              exit(0);
            });
          }
        },
        child: context.read<SettingsAndLanguagesCubit>().appUnderMaintenance()
            ? const AppUnderMaintenanceContainer()
            : Scaffold(
                bottomNavigationBar: buildBottomBar,
                body: MultiBlocListener(
                  listeners: [
                    BlocListener<StoresCubit, StoresState>(
                      listener: (context, state) {
                        if (state is StoresFetchSuccess) {
                          //when store change, need to CAll all apis of bottom tabs to fetch new data due to new store
                          //creating new global keys for each tab will call initState() of each tab
                          setState(() {
                            resetAllStates();
                          });
                        }
                      },
                    ),
                    BlocListener<GenerateReferCodeCubit,
                        GenerateReferCodeState>(
                      listener: (context, state) {
                        if (state is GenerateReferCodeFetchSuccess) {
                          context.read<UpdateUserCubit>().updateUser(params: {
                            Api.userIdApiKey:
                                context.read<UserDetailsCubit>().getUserId(),
                            Api.referralCodeApiKey: state.referCode
                          });
                        }
                      },
                    ),
                    BlocListener<RemoveFavoriteCubit, RemoveFavoriteState>(
                        listener: (context, state) {
                      if (state is RemoveFavoriteSuccess) {
                        Utils.showSnackBar(
                            context: context, message: state.successMessage);
                      }

                      if (state is RemoveFavoriteFailure) {
                        Utils.showSnackBar(
                            context: context, message: state.errorMessage);
                      }
                    }),
                    BlocListener<AddFavoriteCubit, AddFavoriteState>(
                        listener: (context, state) {
                      if (state is AddFavoriteSuccess) {
                        Utils.showSnackBar(
                            context: context, message: state.successMessage);
                      }
                      if (state is AddFavoriteFailure) {
                        Utils.showSnackBar(
                            context: context, message: state.errorMessage);
                      }
                    }),
                    BlocListener<ManageCartCubit, ManageCartState>(
                        listener: (context, state) {
                      if (state is ManageCartFetchSuccess &&
                          state.isAddedToSaveLater == false &&
                          state.changeQuantity == false) {
                        Utils.showSnackBar(
                            context: context, message: itemAddedCartMessageKey);
                      }

                      if (state is ManageCartFetchFailure) {
                        Utils.showSnackBar(
                            context: context, message: state.errorMessage);
                      }
                    })
                  ],
                  child: BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) async {
                      if (state is Unauthenticated) {
                        resetAllStates();
                        context
                            .read<UserDetailsCubit>()
                            .resetUserDetailsState();
                      }
                      if (state is Authenticated) {
                        channelName = context
                            .read<SettingsAndLanguagesCubit>()
                            .getPusherChannerName();
                        context.read<GetAddressCubit>().getAddress();
                        NotificationUtility.initFirebaseState(context);
                      }
                    },
                    builder: (context, state) {
                      return BlocConsumer<UserDetailsCubit, UserDetailsState>(
                        listener: (context, state) async {
                          if (state is UserDetailsFetchSuccess) {
                            if (state.userDetails.active == '0' &&
                                context.read<AuthCubit>().state
                                    is Authenticated) {
                              context.read<AuthCubit>().signOut(context);
                              Utils.showSnackBar(
                                  context: context,
                                  message: deactivatedErrorMessageKey);
                              Utils.navigateToScreen(
                                  context, Routes.loginScreen,
                                  replaceAll: true);
                            } else {
                              if (context
                                          .read<UserDetailsCubit>()
                                          .getUserName() !=
                                      null &&
                                  state.userDetails.referralCode != null &&
                                  state.userDetails.referralCode!.isEmpty) {
                                context
                                    .read<GenerateReferCodeCubit>()
                                    .getGenerateReferCode();
                                context.read<AuthCubit>().authenticateUser(
                                    userDetails: state.userDetails,
                                    token: state.token);
                              }
                            }
                          }
                          if (state is UserDetailsFetchFailure) {
                            Utils.showSnackBar(
                                context: context, message: state.errorMessage);
                            //errror code 102 means User Not Registered so we  will redirect it to login screen
                            if (state.errorCode == 102) {
                              Utils.navigateToScreen(
                                  context, Routes.loginScreen,
                                  replaceAll: true);
                            }
                          }
                        },
                        builder: (context, state) {
                          if (state is UserDetailsFetchFailure) {
                            return ErrorScreen(
                              text: state.errorMessage,
                              onPressed: () {
                                callUserApi();
                                setState(() {
                                  _isLoading = true;
                                });
                                Future.delayed(const Duration(seconds: 2), () {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                });
                              },
                              child: _isLoading
                                  ? const CircularProgressIndicator()
                                  : null,
                            );
                          } else if (state is UserDetailsFetchInProgress) {
                            return CustomCircularProgressIndicator(
                              indicatorColor:
                                  Theme.of(context).colorScheme.primary,
                            );
                          }
                          return IndexedStack(
                            index: _selectedIndex,
                            children: [
                              HomeScreen(key: _homeKey),
                              CategoryScreen(key: _categoryKey),
                              ExploreScreen(
                                  key: _exploreKey, isExploreScreen: true),
                              BlocProvider(
                                create: (context) => RemoveFromCartCubit(),
                                child: CartScreen(key: _cartKey),
                              ),
                              const ProfileScreen()
                            ],
                          );
                        },
                      );
                    },
                  ),
                )));
  }

  resetAllStates() {
    // Change the key to force a rebuild
    _homeKey = GlobalKey();
    _exploreKey = GlobalKey();
    _cartKey = GlobalKey();
    _categoryKey = GlobalKey();

    Hive.box(favoritesBoxKey).clear();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 3) {
        _cartKey = GlobalKey();
      }
    });
  }

  refreshProducts({bool onlyExplore = false}) {
    if (!onlyExplore) {
      _homeKey = GlobalKey();
    }
    _exploreKey = GlobalKey();
  }

  Widget get buildBottomBar => Container(
        height: bottomBarHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          boxShadow: const [
            BoxShadow(
              color: Color(0x14201A1A),
              blurRadius: 12,
              offset: Offset(0, -2),
              spreadRadius: 0,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 8, end: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildNavItem(0, homeKey, 'home.svg', 'home_active.svg'),
              _buildNavItem(
                  1, categoryKey, 'category.svg', 'category_active.svg'),
              _buildNavItem(2, exploreKey, 'explore.svg', 'explore_active.svg'),
              _buildNavItem(3, cartKey, 'cart.svg', 'cart_active.svg'),
              _buildNavItem(4, userKey, 'user.svg', 'user_active.svg'),
            ],
          ),
        ),
      );
  Widget _buildNavItem(
      int index, String title, String inactiveIcon, String activeIcon) {
    return Expanded(
      child: BlocBuilder<SettingsAndLanguagesCubit, SettingsAndLanguagesState>(
        builder: (context, state) {
          return GestureDetector(
            onTap: () {
              _onItemTapped(index);
            },
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                AnimatedBar(isActive: _selectedIndex == index),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(
                      height: 12,
                    ),
                    index == 3
                        ? BlocBuilder<GetUserCartCubit, GetUserCartState>(
                            builder: (context, state) {
                              return Badge(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                textColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                isLabelVisible: context
                                                .read<GetUserCartCubit>()
                                                .getCartProductLength() !=
                                            0 &&
                                        !context
                                            .read<UserDetailsCubit>()
                                            .isGuestUser()
                                    ? true
                                    : false,
                                label: context
                                                .read<GetUserCartCubit>()
                                                .getCartProductLength() !=
                                            0 &&
                                        !context
                                            .read<UserDetailsCubit>()
                                            .isGuestUser()
                                    ? Text(context
                                        .read<GetUserCartCubit>()
                                        .getCartDetail()
                                        .cartProducts!
                                        .length
                                        .toString())
                                    : null,
                                child: _selectedIndex == index
                                    ? SvgPicture.asset(
                                        Utils.getImagePath(activeIcon))
                                    : SvgPicture.asset(
                                        Utils.getImagePath(inactiveIcon)),
                              );
                            },
                          )
                        : _selectedIndex == index
                            ? SvgPicture.asset(Utils.getImagePath(activeIcon))
                            : SvgPicture.asset(
                                Utils.getImagePath(inactiveIcon)),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      context
                          .read<SettingsAndLanguagesCubit>()
                          .getTranslatedValue(labelKey: title),
                      textAlign: TextAlign.center,
                      style: _selectedIndex == index
                          ? Theme.of(context).textTheme.labelMedium
                          : Theme.of(context).textTheme.bodySmall,
                      textDirection: Directionality.of(context),
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class AnimatedBar extends StatelessWidget {
  const AnimatedBar({
    super.key,
    required bool isActive,
  }) : _isActive = isActive;

  final bool _isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: 3,
      width: _isActive ? (MediaQuery.of(context).size.width - 160) / 4 : 0,
      margin: const EdgeInsetsDirectional.only(bottom: 2),
      duration: const Duration(seconds: 1),
      curve: Curves.fastLinearToSlowEaseIn,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
