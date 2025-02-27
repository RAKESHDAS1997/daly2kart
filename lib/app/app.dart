import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/address/getAddressCubit.dart';
import 'package:eshop_pro/cubits/auth/authCubit.dart';
import 'package:eshop_pro/cubits/cart/getUserCart.dart';
import 'package:eshop_pro/cubits/cart/manageCartCubit.dart';
import 'package:eshop_pro/cubits/favorites/addFavoriteCubit.dart';
import 'package:eshop_pro/cubits/favorites/getFavoriteCubit.dart';
import 'package:eshop_pro/cubits/favorites/removeFavoriteCubit.dart';
import 'package:eshop_pro/cubits/order/orderCubit.dart';
import 'package:eshop_pro/cubits/order/updateOrderCubit.dart';
import 'package:eshop_pro/cubits/storesCubit.dart';
import 'package:eshop_pro/cubits/settingsAndLanguagesCubit.dart';
import 'package:eshop_pro/cubits/transaction/transactionCubit.dart';
import 'package:eshop_pro/data/models/cartItem.dart';

import 'package:eshop_pro/data/repositories/authRepository.dart';
import 'package:eshop_pro/data/repositories/productRepository.dart';
import 'package:eshop_pro/data/repositories/settingsRepository.dart';
import 'package:eshop_pro/data/repositories/storeRepository.dart';
import 'package:eshop_pro/firebase_options.dart';
import 'package:eshop_pro/ui/screens/profile/customerSupport/widgets/chatController.dart';
import 'package:eshop_pro/utils/hiveBoxKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cubits/category/category_cubit.dart';
import '../cubits/user_details_cubit.dart';
import '../ui/styles/colors.dart';
import '../utils/constants.dart';

final productRepository = ProductRepository();
late PackageInfo packageInfo;
final RouteController routeController = Get.put(RouteController());
final ChatController chatController = Get.put(ChatController());
String currentChatUserId = '';
String? lastSnackbarMessage = ''; // this is used to show snackbar only once
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late SharedPreferences sharedPreferences;
Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  packageInfo = await PackageInfo.fromPlatform();

  //Register the licence of font
  //If using google-fonts
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark));

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Future.delayed(Duration.zero, () async {
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.reload();
  });
  await Hive.initFlutter();
  await Hive.openBox(authBoxKey);
  await Hive.openBox(settingsBoxKey);
  // Register the cart adapter
  Hive.registerAdapter(CartItemAdapter());
  await Hive.openBox<CartItem>(cartBoxKey);
  if (!Hive.isBoxOpen(productsBoxKey)) {
    await Hive.openBox(productsBoxKey);
  }
  if (!Hive.isBoxOpen(favoritesBoxKey)) {
    await Hive.openBox(favoritesBoxKey);
  }
  await Hive.openBox(searchBoxKey);


  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => StoresCubit(StoreRepository())),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit(AuthRepository())),
        BlocProvider<UserDetailsCubit>(create: (_) => UserDetailsCubit()),
        BlocProvider<SettingsAndLanguagesCubit>(
            create: (_) => SettingsAndLanguagesCubit(SettingsRepository())),
        BlocProvider<GetUserCartCubit>(create: (_) => GetUserCartCubit()),
        BlocProvider(
          create: (context) => ManageCartCubit(),
        ),
        BlocProvider<RemoveFavoriteCubit>(
            create: (context) => RemoveFavoriteCubit()),
        BlocProvider(
          create: (context) => AddFavoriteCubit(),
        ),
        BlocProvider<CategoryCubit>(create: (context) => CategoryCubit()),
        BlocProvider(
          create: (context) => FavoritesCubit(),
        ),
        BlocProvider(
          create: (context) => GetAddressCubit(),
        ),
        BlocProvider(
          create: (context) => TransactionCubit(),
        ),
        // we have taken this cubit as global so that we can update order status from notification
        BlocProvider(
          create: (context) => OrdersCubit(),
        ),
        BlocProvider(
          create: (context) => UpdateOrderCubit(),
        ),
      ],
      child: Builder(builder: (context) {
        return BlocBuilder<SettingsAndLanguagesCubit,
            SettingsAndLanguagesState>(
          builder: (context, state) {
            final currentLanguage = context
                .watch<SettingsAndLanguagesCubit>()
                .getCurrentAppLanguage();

            return BlocBuilder<StoresCubit, StoresState>(
              builder: (context, state) {
                final defaultStore =
                    context.read<StoresCubit>().getDefaultStore();

                return GetMaterialApp(
                  navigatorKey: navigatorKey,
                  textDirection: currentLanguage.isThisRTL()
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  theme: Theme.of(context).copyWith(
                    textTheme:
                        GoogleFonts.rubikTextTheme(Theme.of(context).textTheme),
                    scaffoldBackgroundColor: Utils.getColorFromHexValue(
                            defaultStore.backgroundColor) ??
                        const Color(0xFFF5F8F9),
                    shadowColor: const Color(0x3F000000),
                    hintColor: secondaryColor.withOpacity(0.67),
                    appBarTheme: const AppBarTheme(
                      backgroundColor: Colors.white,
                    ),
                    iconTheme: IconThemeData(color: secondaryColor),
                    dividerColor: borderColor.withOpacity(0.4),
                    inputDecorationTheme: InputDecorationTheme(
                      iconColor: borderColor.withOpacity(0.4),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: borderColor.withOpacity(0.4)),
                        borderRadius: const BorderRadius.all(
                            Radius.circular(borderRadius)),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: borderColor.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(borderRadius)),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: errorColor),
                          borderRadius: BorderRadius.circular(borderRadius)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: borderColor.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(borderRadius)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: borderColor.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(borderRadius)),
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: secondaryColor.withOpacity(0.67)),
                          borderRadius: BorderRadius.circular(borderRadius)),
                    ),

                    bottomNavigationBarTheme:
                        const BottomNavigationBarThemeData(
                            backgroundColor: Colors.white, elevation: 1),
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: Utils.getColorFromHexValue(
                              defaultStore.primaryColor) ??
                          primaryColor,
                      primary: Utils.getColorFromHexValue(
                              defaultStore.primaryColor) ??
                          primaryColor,
                      primaryContainer: Utils.getColorFromHexValue('#FFFFFF'),

                      surface: Utils.getColorFromHexValue(
                          defaultStore.backgroundColor),
                      secondary: Utils.getColorFromHexValue(
                              defaultStore.secondaryColor) ??
                          secondaryColor, 
                      shadow: const Color(0x3F000000),

                      error: errorColor,
                    ),
                  ),
                  debugShowCheckedModeBanner: false,
                  getPages: Routes.getPages,
                  initialRoute: Routes.splashScreen,
                  routingCallback: (routing) {
                    if (routing != null) {
                      routeController.updateCurrentRoute(routing.current);
                    }
                  },
                );
              },
            );
          },
        );
      }),
    );
  }
}

class RouteController extends GetxController {
  var currentRoute = ''.obs;

  @override
  void onInit() {
    ever(currentRoute, (route) {
   
    });
    super.onInit();
  }

  void updateCurrentRoute(String route) {
    currentRoute.value = route;
  }
}
