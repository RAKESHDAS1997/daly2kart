import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/auth/authCubit.dart';

import 'package:eshop_pro/cubits/storesCubit.dart';
import 'package:eshop_pro/cubits/settingsAndLanguagesCubit.dart';
import 'package:eshop_pro/data/models/settings.dart';
import 'package:eshop_pro/data/repositories/authRepository.dart';
import 'package:eshop_pro/data/repositories/settingsRepository.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/ui/widgets/customImageWidget.dart';
import 'package:eshop_pro/ui/widgets/error_screen.dart';

import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/user_details_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();

  static Widget getRouteInstance() => const SplashScreen();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    callApi();
  }

  void navigateToNextScreen() async {
    Settings settings = context.read<SettingsAndLanguagesCubit>().getSettings();

    if (context.read<AuthCubit>().state is Unauthenticated) {
      if (context.read<SettingsAndLanguagesCubit>().getshowOnBoardingScreen()) {
        ///[If there is no image or video added by admin then do not navigate to onborading screen]
        if ((settings.systemSettings?.showVideosInOnBoardingScreen() ??
            false)) {
          if ((settings.systemSettings?.onBoardingVideo?.isEmpty ?? false)) {
          
            navigateToLoginScreen();
          } else {
            Utils.navigateToScreen(context, Routes.onBoardingScreen,
                replaceAll: true);
          }
        } else {
          if ((settings.systemSettings?.onBoardingImage?.isEmpty ?? false)) {
            
            navigateToLoginScreen();
          } else {
            Utils.navigateToScreen(context, Routes.onBoardingScreen,
                replaceAll: true);
          }
        }
      } else {
        navigateToLoginScreen();
      }
    } else {
      Future.delayed(Duration(seconds: 2), () {
        Utils.navigateToScreen(context, Routes.mainScreen, replaceAll: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: BlocConsumer<SettingsAndLanguagesCubit, SettingsAndLanguagesState>(
          listener: (context, state) {
        if (state is SettingsAndLanguagesFetchSuccess) {
          navigateToNextScreen();
        } else if (state is SettingsAndLanguagesFetchFailure) {
          Utils.showSnackBar(message: state.errorMessage, context: context);
        }
      }, builder: (context, state) {
        if (state is SettingsAndLanguagesFetchFailure) {
          return ErrorScreen(
            text: state.errorMessage,
            onPressed: callApi,
            child: state is SettingsAndLanguagesFetchInProgress
                ? CustomCircularProgressIndicator(
                    indicatorColor: Theme.of(context).colorScheme.onPrimary,
                  )
                : null,
          );
        }
        if (state is SettingsAndLanguagesFetchSuccess) {
          return BlocBuilder<StoresCubit, StoresState>(
            builder: (context, state) {
              if (state is StoresFetchSuccess) {
                return Container(
                    color: Theme.of(context).colorScheme.primary,
                    alignment: Alignment.center,
                    child: CustomImageWidget(
                      url: context.read<StoresCubit>().getDefaultStore().image,
                      width: 200,
                      height: 200,
                      borderRadius: 16,
                    ));
              } else if (state is StoresFetchFailure) {
                return ErrorScreen(
                  text: state.errorMessage,
                  onPressed: callApi,
                  child: state is StoresFetchInProgress
                      ? CustomCircularProgressIndicator(
                          indicatorColor:
                              Theme.of(context).colorScheme.onPrimary,
                        )
                      : null,
                );
              }
              return CustomCircularProgressIndicator(
                indicatorColor: Theme.of(context).colorScheme.onPrimary,
              );
            },
          );
        }
        return CustomCircularProgressIndicator(
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
        );
      }),
    );
  }

  void callApi() {
    Future.delayed(Duration.zero, () {
      context.read<SettingsAndLanguagesCubit>().fetchSettingsAndLanguages();
      context.read<StoresCubit>().fetchStores();
      context
          .read<UserDetailsCubit>()
          .fetchUserDetails(params: Utils.getParamsForVerifyUser(context));
    });
  }

  navigateToLoginScreen() {
    //if guest user open app first time , it will redirect to login screen
    //if user is logged in and open app second time or further then it will redirect to main screen

    if (SettingsRepository().getFirstTimeUser()) {
      Utils.navigateToScreen(context, Routes.loginScreen, replaceAll: true);
    } else {
      context.read<UserDetailsCubit>().resetUserDetailsState();
      AuthRepository().setIsLogIn(false);
      context.read<AuthCubit>().checkIsAuthenticated();

      Utils.navigateToScreen(context, Routes.mainScreen, replaceAll: true);
    }
  }
}
