import 'package:eshop_pro/ui/screens/auth/createAccountScreen.dart';
import 'package:eshop_pro/ui/screens/cart/cartScreen.dart';
import 'package:eshop_pro/ui/screens/cart/orderConfirmScreen.dart';
import 'package:eshop_pro/ui/screens/cart/placeOrderScreen.dart';
import 'package:eshop_pro/ui/screens/categoty/categoryScreen.dart';
import 'package:eshop_pro/ui/screens/categoty/subCategoryScreen.dart';
import 'package:eshop_pro/ui/screens/explore/exploreScreen.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/widgets/allFaqListScreen.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/widgets/allCustomerImagesScreen.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/widgets/compareWithSimilarItemsContainer.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/widgets/fullScreenImageScreen.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/widgets/ratingContainer.dart';
import 'package:eshop_pro/ui/screens/explore/sellerDetailScreen.dart';
import 'package:eshop_pro/ui/screens/explore/widgets/allFeaturedSellerList.dart';
import 'package:eshop_pro/ui/screens/home/notificationScreen.dart';
import 'package:eshop_pro/ui/screens/onBoardingScreen.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/productDetailsScreen.dart';
import 'package:eshop_pro/ui/screens/productFilters/productFiltersScreen.dart';
import 'package:eshop_pro/ui/screens/profile/address/addNewAddressScreen.dart';
import 'package:eshop_pro/ui/screens/profile/address/myAddressScreen.dart';
import 'package:eshop_pro/ui/screens/profile/customerSupport/askQueryScreen.dart';
import 'package:eshop_pro/ui/screens/profile/customerSupport/chatScreen.dart';
import 'package:eshop_pro/ui/screens/profile/customerSupport/customerSupportScreen.dart';
import 'package:eshop_pro/ui/screens/profile/customerSupport/userListScreen.dart';
import 'package:eshop_pro/ui/screens/profile/editProfileScreen.dart';
import 'package:eshop_pro/ui/screens/home/favoriteScreen.dart';
import 'package:eshop_pro/ui/screens/profile/orders/myOrderScreen.dart';
import 'package:eshop_pro/ui/screens/profile/transaction/addMoneyScreen.dart';
import 'package:eshop_pro/ui/screens/profile/transaction/widgets/paypalWebviewScreen.dart';
import 'package:eshop_pro/ui/screens/searchScreen.dart';
import 'package:eshop_pro/ui/screens/splashScreen.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';

import 'package:get/get_navigation/src/routes/get_route.dart';

import '../ui/screens/auth/forgotPasswordScreen.dart';
import '../ui/screens/auth/loginScreen.dart';
import '../ui/screens/auth/otpVerificationScreen.dart';

import '../ui/screens/auth/signupScreen.dart';
import '../ui/screens/mainScreen.dart';
import '../ui/screens/profile/address/mapScreen.dart.dart';
import '../ui/screens/profile/faqScreen.dart';
import '../ui/screens/profile/orders/orderDetailScreen.dart';
import '../ui/screens/profile/policyScreen.dart';
import '../ui/screens/profile/promoCodeScreen.dart';
import '../ui/screens/profile/referAndEarnScreen.dart';
import '../ui/screens/profile/settings/changePasswordScreen.dart';
import '../ui/screens/profile/settings/deleteAccountScreen.dart';
import '../ui/screens/profile/settings/settingScreen.dart';
import '../ui/screens/profile/termsAndPolicyScreen.dart';
import '../ui/screens/profile/transaction/transactionScreen.dart';
import '../ui/screens/profile/transaction/walletScreen.dart';

class Routes {
  static String mainScreen = "/";
  static String splashScreen = "/splash";
  static String authenticationScreen = "/authentication";
  static String onBoardingScreen = "/onBoarding";

  static String signupScreen = "/signup";
  static String loginScreen = "/login";
  static String forgotPasswordScreen = "/forgotPassword";
  static String otpVerificationScreen = "/otpVerification";
  static String createAccountScreen = "/createAccount";
  static String exploreScreen = "/explore";
  static String productFiltersScreen = "/productFilters";
  static String termsAndPolicyScreen = "/termsAndPolicy";
  static String settingScreen = "/settings";
  static String changePasswordScreen = "/changePassword";
  static String deleteAccountScreen = "/deleteAccount";
  static String walletScreen = "/wallet";
  static String policyScreen = "/policy";
  static String editProfileScreen = "/editProfile";
  static String faqScreen = "/faq";
  static String referAndEarnScreen = "/referAndEarn";
  static String transactionScreen = "/transaction";
  static String myOrderScreen = "/myOrder";
  static String myAddressScreen = "/myAddress";
  static String addNewAddressScreen = "/addNewAddress";
  static String mapScreen = "/map";
  static String promoCodeScreen = "/promoCode";
  static String orderDetailsScreen = "/orderDetails";
  static String productDetailsScreen = "/productDetails";
  static String favoriteScreen = "/favorite";
  static String addMoneyScreen = "/addMoney";
  static String customerSupportScreen = "/customerSupport";
  static String askQueryScreen = "/askQuery";
  static String userListScreen = "/userList";
  static String paypalWebviewScreen = "/paypalWebview";
  static String categoryScreen = "/category";
  static String subCategoryScreen = "/subCategory";
  static String notificationScreen = "/notification";
  static String allFeaturedSellerList = "/allFeaturedSellerList";
  static String sellerDetailScreen = "/sellerDetail";
  static String customerImagesScreen = "/customerImages";
  static String fullScreenImageScreen = "/fullScreenImage";
  static String allFaqListScreen = "/allFaqList";
  static String allReviewScreen = "/allReview";
  static String comparisonScreen = "/comparisonScreen";
  static String cartScreen = "/cart";
  static String searchScreen = "/search";
  static String placeOrderScreen = "/placeOrder";
  static String orderConfirmedScreen = "/orderConfirmed";
  static String chatScreen = "/chat";

  static String currentRoute = splashScreen;
  static String previousRoute = splashScreen;
  static final List<GetPage> getPages = [
    GetPage(name: mainScreen, page: () => MainScreen.getRouteInstance()),
    GetPage(name: splashScreen, page: () => SplashScreen.getRouteInstance()),
    GetPage(
        name: onBoardingScreen,
        page: () => OnBoardingScreen.getRouteInstance()),
    GetPage(name: signupScreen, page: () => SignupScreen.getRouteInstance()),
    GetPage(name: loginScreen, page: () => LoginScreen.getRouteInstance()),
    GetPage(
        name: forgotPasswordScreen,
        page: () => ForgotPasswordScreen.getRouteInstance()),
    GetPage(
        name: otpVerificationScreen,
        page: () => OtpVerificationScreen.getRouteInstance()),
    GetPage(
        name: createAccountScreen,
        page: () => CreateAccountScreen.getRouteInstance()),
    GetPage(name: exploreScreen, page: () => ExploreScreen.getRouteInstance()),
    GetPage(
        name: productFiltersScreen,
        page: () => ProductFiltersScreen.getRouteInstance()),
    GetPage(
        name: termsAndPolicyScreen,
        page: () => TermsAndPolicyScreen.getRouteInstance()),
    GetPage(name: settingScreen, page: () => SettingScreen.getRouteInstance()),
    GetPage(
        name: changePasswordScreen,
        page: () => ChangePasswordScreen.getRouteInstance()),
    GetPage(
        name: deleteAccountScreen,
        page: () => DeleteAccountScreen.getRouteInstance()),
    GetPage(name: walletScreen, page: () => WalletScreen.getRouteInstance()),
    GetPage(name: policyScreen, page: () => PolicyScreen.getRouteInstance()),
    GetPage(
        name: editProfileScreen,
        page: () => EditProfileScreen.getRouteInstance()),
    GetPage(name: faqScreen, page: () => FaqScreen.getRouteInstance()),
    GetPage(
        name: referAndEarnScreen,
        page: () => ReferAndEarnScreen.getRouteInstance()),
    GetPage(
        name: transactionScreen,
        page: () => TransactionScreen.getRouteInstance()),
    GetPage(name: myOrderScreen, page: () => MyOrderScreen.getRouteInstance()),
    GetPage(
        name: addNewAddressScreen,
        page: () => AddNewAddressScreen.getRouteInstance()),
    GetPage(
        name: myAddressScreen, page: () => MyAddressScreen.getRouteInstance()),
    GetPage(name: mapScreen, page: () => MapScreen.getRouteInstance()),
    GetPage(
        name: promoCodeScreen, page: () => PromoCodeScreen.getRouteInstance()),
    GetPage(
        name: orderDetailsScreen,
        page: () => OrderDetailScreen.getRouteInstance()),
    GetPage(
        name: productDetailsScreen,
        page: () => ProductDetailsScreen.getRouteInstance()),
    GetPage(
        name: favoriteScreen, page: () => FavoriteScreen.getRouteInstance()),
    GetPage(
        name: addMoneyScreen, page: () => AddMoneyScreen.getRouteInstance()),
    GetPage(
        name: customerSupportScreen,
        page: () => CustomerSupportScreen.getRouteInstance()),
    GetPage(
        name: askQueryScreen, page: () => AskQueryScreen.getRouteInstance()),
    GetPage(
        name: userListScreen, page: () => ContactListScreen.getRouteInstance()),
    GetPage(
        name: paypalWebviewScreen,
        page: () => PaypalWebviewScreen.getRouteInstance()),
    GetPage(
        name: categoryScreen, page: () => CategoryScreen.getRouteInstance()),
    GetPage(
        name: subCategoryScreen,
        page: () => SubCategoryScreen.getRouteInstance()),
    GetPage(
        name: notificationScreen,
        page: () => NotificationScreen.getRouteInstance()),
    GetPage(
        name: allFeaturedSellerList,
        page: () => AllFeaturedSellerList.getRouteInstance()),
    GetPage(
        name: sellerDetailScreen,
        page: () => SellerDetailScreen.getRouteInstance()),
    GetPage(
        name: customerImagesScreen,
        page: () => AllCustomerImagesScreen.getRouteInstance()),
    GetPage(
        name: fullScreenImageScreen,
        page: () => FullScreenImage.getRouteInstance()),
    GetPage(
        name: allFaqListScreen,
        page: () => AllFaqListScreen.getRouteInstance()),
    GetPage(
        name: allReviewScreen, page: () => RatingContainer.getRouteInstance()),
    GetPage(
        name: comparisonScreen,
        page: () => ComparisonScreen.getRouteInstance()),
    GetPage(name: searchScreen, page: () => SearchScreen.getRouteInstance()),
    GetPage(name: cartScreen, page: () => CartScreen.getRouteInstance()),
    GetPage(
        name: placeOrderScreen,
        page: () => PlaceOrderScreen.getRouteInstance()),
    GetPage(
        name: orderConfirmedScreen,
        page: () => OrderConfirmScreen.getRouteInstance()),
    GetPage(name: chatScreen, page: () => ChatScreen.getRouteInstance()),
  ];

  ///[This will check if user is login or not. If user is login then navigate to target screen]
  ///[If user is not login then it will redirect user to login screen]
  static Widget _checkAuthenticity({required Widget to}) {
    if (Utils.isUserLoggedIn()) {
      return to;
    }
    return LoginScreen.getRouteInstance();
  }
}
