import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/auth/authCubit.dart';
import 'package:eshop_pro/cubits/auth/signInCubit.dart';
import 'package:eshop_pro/cubits/auth/signUpCubit.dart';
import 'package:eshop_pro/cubits/storesCubit.dart';
import 'package:eshop_pro/data/repositories/authRepository.dart';
import 'package:eshop_pro/data/repositories/settingsRepository.dart';

import 'package:eshop_pro/ui/screens/auth/widgets/loginContainer.dart';
import 'package:eshop_pro/ui/screens/auth/widgets/socialLoginWidget.dart';
import 'package:eshop_pro/ui/widgets/customTextButton.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/ui/widgets/customTextFieldContainer.dart';
import 'package:eshop_pro/ui/widgets/showHidePasswordButton.dart';
import 'package:eshop_pro/utils/validator.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../cubits/settingsAndLanguagesCubit.dart';
import '../../../cubits/user_details_cubit.dart';
import '../../../utils/api.dart';
import '../../../utils/constants.dart';
import '../../../utils/utils.dart';
import '../../widgets/customCircularProgressIndicator.dart';
import 'widgets/aggrementTextContainer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static Widget getRouteInstance() => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SignInCubit(),
          ),
          BlocProvider(
            create: (context) => SignUpCubit(),
          ),
        ],
        child: const LoginScreen(),
      );
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController =
      TextEditingController(text: isDemoApp ? '9898765432' : null);
  final TextEditingController _passwordController =
      TextEditingController(text: isDemoApp ? '123456' : null);
  bool _hidePassword = true;
  bool _isChecked = false;
  FocusNode? _passwordFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<StoresCubit>().resetState();
      SettingsRepository().setFirstTimeUser(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<SignInCubit, SignInState>(
        listener: (context, state) async {
          if (state is SignInSuccess) {
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
            FocusScope.of(context).unfocus();
            context.read<StoresCubit>().fetchStores();
            if (Get.previousRoute == Routes.mainScreen) {
              Utils.popNavigation(context);
            } else {
              Utils.navigateToScreen(context, Routes.mainScreen,
                  replaceAll: true);
            }
          }
          if (state is SignInFailure) {
            Utils.showSnackBar(context: context, message: state.errorMessage);
          }
        },
        builder: (context, state) {
          return LoginContainer(
            titleText: welcomeBackKey,
            descriptionText: pleaseEnterLoginDetailsKey,
            buttonText: signInKey,
            onTapButton: state is SignInProgress ? () {} : callSignInApi,
            buttonWidget: state is SignInProgress
                ? const CustomCircularProgressIndicator()
                : null,
            content: buildContentWidget(),
            footerWidget: buildFooterWidget(),
            showSkipButton: true,
          );
        },
      ),
      bottomNavigationBar: Container(
        alignment: Alignment.center,
        height: 50,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            border: Border(
                top: BorderSide(
                    color: Theme.of(context).inputDecorationTheme.iconColor!))),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: context
                    .read<SettingsAndLanguagesCubit>()
                    .getTranslatedValue(labelKey: dontHaveAccountKey),
              ),
              const TextSpan(
                text: ' ',
              ),
              TextSpan(
                  text: context
                      .read<SettingsAndLanguagesCubit>()
                      .getTranslatedValue(labelKey: signUpKey),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () =>
                        Utils.navigateToScreen(context, Routes.signupScreen)),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget buildContentWidget() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: 25),
        child: Column(
          children: <Widget>[
            CustomTextFieldContainer(
              hintTextKey: mobileNumberKey,
              textEditingController: _mobileController,
              labelKey: '',
              keyboardType: TextInputType.phone,

              textInputAction: TextInputAction.next,
              // maxLength: 15,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Allow only digits
                LengthLimitingTextInputFormatter(15), // Limit to 15 digits
              ],
              validator: (v) => Validator.validatePhoneNumber(v, context),
              prefixWidget: const Icon(Icons.call_outlined),
              onFieldSubmitted: (v) {
                FocusScope.of(context).requestFocus(_passwordFocus);
              },
            ),
            CustomTextFieldContainer(
              hintTextKey: passwordKey,
              textEditingController: _passwordController,
              labelKey: '',
              prefixWidget: const Icon(Icons.lock_outline),
              hideText: _hidePassword,
              keyboardType: TextInputType.text,
              focusNode: _passwordFocus,
              textInputAction: TextInputAction.done,
              maxLines: 1,
              validator: (v) => Validator.validatePassword(context, v),
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp('[ ]')),
              ],
              suffixWidget: ShowHidePasswordButton(
                hidePassword: _hidePassword,
                onTapButton: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
              ),
              onFieldSubmitted: (v) {
                _passwordFocus!.unfocus();
              },
            ),
            const SizedBox(
              height: 15,
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: CustomTextButton(
                  buttonTextKey: forgotPasswordKey,
                  onTapButton: () {
                    Utils.navigateToScreen(
                        context, Routes.forgotPasswordScreen);
                  },
                  textStyle: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ))
          ],
        ),
      ),
    );
  }

  void callSignInApi() async {
    FocusScope.of(context).unfocus();
    if (!_isChecked) {
      Utils.showSnackBar(
          message: pleaseAcceptTermsAndConditionAndPrivacyPolicyKey,
          context: context);
      return;
    }
    if (_formKey.currentState!.validate()) {
      {
        String fcm = await AuthRepository.getFcmToken();
        context.read<SignInCubit>().login(params: {
          Api.mobileApiKey: _mobileController.text.trim(),
          Api.passwordApiKey: _passwordController.text.trim(),
          Api.fcmIdApiKey: fcm,
        });
      }
    }
  }

  buildFooterWidget() {
    return Column(
      children: [
        if ((context
                    .read<SettingsAndLanguagesCubit>()
                    .getSettings()
                    .systemSettings!
                    .google ==
                1) ||
            ((context
                    .read<SettingsAndLanguagesCubit>()
                    .getSettings()
                    .systemSettings!
                    .apple ==
                1))) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: Theme.of(context).inputDecorationTheme.iconColor,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: appContentHorizontalPadding),
                child: CustomTextContainer(
                  textKey: orLoginWithKey,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.67)),
                ),
              ),
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: Theme.of(context).inputDecorationTheme.iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
          SocialLoginWidget(
            isChecked: _isChecked,
            isSignUpScreen: false,
          ),
          const SizedBox(
            height: 25,
          ),
        ],
        AggrementTextContainer(
            isChecked: _isChecked,
            onChanged: (newValue) {
              setState(() {
                _isChecked = newValue!;
              });
            }),
        const SizedBox(
          height: 25,
        ),
      ],
    );
  }
}
