import 'dart:io';

import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/auth/authCubit.dart';
import 'package:eshop_pro/cubits/auth/signUpCubit.dart';
import 'package:eshop_pro/cubits/settingsAndLanguagesCubit.dart';
import 'package:eshop_pro/cubits/storesCubit.dart';

import 'package:eshop_pro/cubits/user_details_cubit.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/ui/widgets/customRoundedButton.dart';

import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';

import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class SocialLoginWidget extends StatelessWidget {
  const SocialLoginWidget({
    super.key,
    required bool isChecked,
    required bool isSignUpScreen,
  })  : _isChecked = isChecked,
        _isSignUpScreen = isSignUpScreen;

  final bool _isChecked;
  final bool _isSignUpScreen;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpCubit, SignUpState>(
        listener: (context, state) async {
      if (state is SignUpSuccess) {
        if (state.userDetails.active == '0') {
          Utils.showSnackBar(
              context: context, message: deactivatedErrorMessageKey);
          return;
        }

        context.read<AuthCubit>().authenticateUser(
            userDetails: state.userDetails, token: state.token);

        context
            .read<UserDetailsCubit>()
            .emitUserSuccessState(state.userDetails.toJson(), state.token);
        await Utils.syncFavoritesToUser(context);
        context.read<StoresCubit>().fetchStores();
        FocusScope.of(context).unfocus();
        if (Get.previousRoute == Routes.mainScreen) {
          Utils.popNavigation(context);
        } else {
          Utils.navigateToScreen(context, Routes.mainScreen, replaceAll: true);
        }
      }
      if (state is SignUpFailure) {
        Utils.showSnackBar(context: context, message: state.errorMessage);
      }
    }, builder: (context, state) {
      return Platform.isAndroid
          ? buildSocialLoginButton(context, state, googleLoginType)
          : context
                          .read<SettingsAndLanguagesCubit>()
                          .getSettings()
                          .systemSettings!
                          .apple ==
                      1 &&
                  context
                          .read<SettingsAndLanguagesCubit>()
                          .getSettings()
                          .systemSettings!
                          .google !=
                      1
              ? buildSocialLoginButton(context, state, appleLoginType)
              : context
                              .read<SettingsAndLanguagesCubit>()
                              .getSettings()
                              .systemSettings!
                              .google ==
                          1 &&
                      context
                              .read<SettingsAndLanguagesCubit>()
                              .getSettings()
                              .systemSettings!
                              .apple !=
                          1
                  ? buildSocialLoginButton(context, state, googleLoginType)
                  : Row(
                      children: [
                        Flexible(
                            child: buildSocialLoginButton(
                                context, state, googleLoginType)),
                        DesignConfig.defaultWidthSizedBox,
                        Flexible(
                            child: buildSocialLoginButton(
                                context, state, appleLoginType)),
                      ],
                    );
    });
  }

  Widget buildSocialLoginButton(
      BuildContext context, SignUpState state, String loginType) {
    if ((loginType == googleLoginType &&
            context
                    .read<SettingsAndLanguagesCubit>()
                    .getSettings()
                    .systemSettings!
                    .google ==
                1) ||
        ((loginType == appleLoginType &&
            context
                    .read<SettingsAndLanguagesCubit>()
                    .getSettings()
                    .systemSettings!
                    .apple ==
                1))) {
      return CustomRoundedButton(
        widthPercentage: 1,
        buttonTitle: '',
        showBorder: true,
        borderColor: Theme.of(context).inputDecorationTheme.iconColor,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        onTap: state is SignUpProgress && state.loginType == loginType
            ? () {}
            : () {
                if (_isChecked) {
                  context.read<SignUpCubit>().signUpUser(loginType);
                } else {
                  Utils.showSnackBar(
                      message: pleaseAcceptTermsAndConditionAndPrivacyPolicyKey,
                      context: context);
                  return;
                }
              },
        child: state is SignUpProgress && state.loginType == loginType
            ? CustomCircularProgressIndicator(
                indicatorColor: Theme.of(context).colorScheme.primary,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Utils.setSvgImage(loginType == googleLoginType
                      ? 'google_logo'
                      : 'apple_logo'),
                  DesignConfig.defaultWidthSizedBox,
                  CustomTextContainer(
                    textKey: _isSignUpScreen
                        ? loginType == googleLoginType
                            ? signUpWithGoogleKey
                            : signUpWithAppleKey
                        : loginType == googleLoginType
                            ? signInWithGoogleKey
                            : signInWithAppleKey,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.67)),
                  )
                ],
              ),
      );
    }
    return const SizedBox.shrink();
  }
}
