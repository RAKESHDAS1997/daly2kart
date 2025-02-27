import 'package:eshop_pro/cubits/auth/authCubit.dart';
import 'package:eshop_pro/cubits/storesCubit.dart';
import 'package:eshop_pro/data/repositories/authRepository.dart';
import 'package:eshop_pro/ui/widgets/customImageWidget.dart';
import 'package:eshop_pro/ui/widgets/customTextButton.dart';

import 'package:eshop_pro/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/routes.dart';

import '../../../../cubits/user_details_cubit.dart';
import '../../../../utils/labelKeys.dart';
import '../../../../utils/utils.dart';
import '../../../widgets/customRoundedButton.dart';
import '../../../widgets/customTextContainer.dart';

class LoginContainer extends StatelessWidget {
  final String titleText;
  final String descriptionText;
  final String buttonText;
  final VoidCallback onTapButton;
  final Widget content;
  final Widget? footerWidget;
  final bool? showBackButton;
  final Widget? buttonWidget;
  final bool showSkipButton;
  const LoginContainer(
      {super.key,
      required this.titleText,
      required this.descriptionText,
      required this.buttonText,
      required this.onTapButton,
      required this.content,
      this.footerWidget,
      this.buttonWidget,
      this.showSkipButton = false,
      this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsetsDirectional.only(
                bottom: MediaQuery.of(context).size.height * (0.4)),
     
            child:
                context.read<StoresCubit>().getDefaultStore().loginImage != ''
                    ? CustomImageWidget(
                        url: context
                            .read<StoresCubit>()
                            .getDefaultStore()
                            .loginImage)
                    : Image.asset(
                        height: double.maxFinite, 
                        Utils.getImagePath('login_bg.png'),
                        fit: BoxFit.cover,
                      ),
          ),
        ),
        Container(
          width: double.maxFinite,
          alignment: Alignment.topLeft,
          height: 130,
          padding: EdgeInsetsDirectional.only(
              start: appContentHorizontalPadding,
              top: MediaQuery.of(context).padding.top + 24,
              end: appContentHorizontalPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.secondary.withOpacity(0.45),
                Theme.of(context).colorScheme.secondary.withOpacity(0)
              ],
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              showBackButton == true
                  ? IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Utils.popNavigation(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ))
                  : CustomTextContainer(
                      textKey: titleText,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(
                              color: Theme.of(context).colorScheme.onPrimary),
                    ),
              if (showSkipButton)
                CustomTextButton(
                    buttonTextKey: skipKey,
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(
                            color: Theme.of(context).colorScheme.onPrimary),
                    onTapButton: () {
                      context.read<UserDetailsCubit>().resetUserDetailsState();
                      AuthRepository().setIsLogIn(false);
                      context.read<AuthCubit>().checkIsAuthenticated();

                      FocusScope.of(context).unfocus();

                      Utils.navigateToScreen(context, Routes.mainScreen,
                          replaceAll: true);
                    }),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
         
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16))),
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(
                  appContentHorizontalPadding,
                  appContentHorizontalPadding,
                  appContentHorizontalPadding,
                  0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CustomTextContainer(
                    textKey: titleText,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextContainer(
                    textKey: descriptionText,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.8)),
                  ),
                  content,
                  const SizedBox(
                    height: 25,
                  ),
                  CustomRoundedButton(
                    widthPercentage: 1,
                    buttonTitle: buttonText,
                    radius: 5,
                    onTap: onTapButton,
                    showBorder: false,
                    child: buttonWidget,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  footerWidget ?? const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
