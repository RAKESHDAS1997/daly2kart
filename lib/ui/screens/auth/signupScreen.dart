import 'package:country_code_picker/country_code_picker.dart';
import 'package:eshop_pro/cubits/auth/signUpCubit.dart';
import 'package:eshop_pro/cubits/settingsAndLanguagesCubit.dart';
import 'package:eshop_pro/cubits/user_details_cubit.dart';

import 'package:eshop_pro/ui/screens/auth/widgets/aggrementTextContainer.dart';
import 'package:eshop_pro/ui/screens/auth/widgets/socialLoginWidget.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';

import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/routes.dart';

import '../../../utils/constants.dart';
import '../../../utils/utils.dart';
import '../../../utils/validator.dart';
import '../../widgets/customTextFieldContainer.dart';
import 'widgets/loginContainer.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  static Widget getRouteInstance() => BlocProvider(
        create: (context) => SignUpCubit(),
        child: const SignupScreen(),
      );
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _mobileController = TextEditingController();
  String _countryCode = initialCountryCode;
  bool _isChecked = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserDetailsCubit, UserDetailsState>(
      listener: (context, state) {
        if (state is UserDetailsFetchSuccess &&
            !context
                .read<SettingsAndLanguagesCubit>()
                .getIsFirebaseAuthentication()) {
          Utils.showSnackBar(
              context: context, message: 'OTP sent successfully');
          Utils.navigateToScreen(context, Routes.otpVerificationScreen,
              arguments: {
                'mobileNumber': _mobileController.text.trim(),
                'countryCode': _countryCode,
                'verificationID': '',
              });
        }
        if (state is UserDetailsFetchFailure) {
          Utils.showSnackBar(context: context, message: state.errorMessage);
        }
      },
      builder: (context, state) {
        return Scaffold(
            body: LoginContainer(
          titleText: signUpKey,
          descriptionText: weWillSendVerificationCodeToKey,
          buttonText: sendOTPKey,
          onTapButton: () => _isLoading || state is UserDetailsFetchInProgress
              ? () {}
              : onTapSendOTPButton(state),
          content: buildContent(),
          footerWidget: buildFooterWidget(context),
          showBackButton: false,
          buttonWidget: _isLoading || state is UserDetailsFetchInProgress
              ? const CustomCircularProgressIndicator()
              : null,
          showSkipButton: true,
        ));
      },
    );
  }

  Widget buildContent() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: 25),
        child: Row(
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsetsDirectional.only(
                      end: 0.0, bottom: 0.0, top: 0, start: 0),
                  margin: const EdgeInsetsDirectional.only(end: 5),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          width: 1,
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                  child: CountryCodePicker(
                    onChanged: (countryCode) {
                      _countryCode = countryCode.toString();
                    },
                    flagWidth: 25,
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.67)),
                    padding: EdgeInsets.zero,
                    // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                    initialSelection: initialCountryCode,
                    // favorite: const ['+91', 'IN'],
                    showFlagDialog: true,
                    comparator: (a, b) => b.name!.compareTo(a.name!),
                    //Get the country information relevant to the initial selection
                    onInit: (code) {},
                    alignLeft: true,
                  ),
                )),
            Expanded(
              flex: 2,
              child: CustomTextFieldContainer(
                hintTextKey: mobileNumberKey,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.phone,
                textEditingController: _mobileController,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Allow only digits
                  LengthLimitingTextInputFormatter(15), // Limit to 15 digits
                ],
                validator: (v) => Validator.validatePhoneNumber(v, context),
                labelKey: '',
                suffixWidget: IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () => _mobileController.clear(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildFooterWidget(BuildContext context) {
    return Column(
      children: <Widget>[
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
                  textKey: orSignupWithKey,
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
          SocialLoginWidget(isChecked: _isChecked, isSignUpScreen: true),
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

  void signInWithPhoneNumber() async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        // timeout: const Duration(seconds: 60),
        phoneNumber: '$_countryCode${_mobileController.text.trim()}',
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          //if otp code does not verify

          if (e.code == 'invalid-phone-number') {
            Utils.showSnackBar(
                context: context, message: invalidMobileErrorMsgKey);
          } else if (e.code == 'network-request-failed') {
            Utils.showSnackBar(context: context, message: noInternetKey);
          } else {
            Utils.showSnackBar(
                context: context, message: verificationErrorMessageKey);
          }

          setState(() {
            _isLoading = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isLoading = false;
          });
          Utils.showSnackBar(
              message: 'OTP sent successfully', context: context);
          Utils.navigateToScreen(context, Routes.otpVerificationScreen,
              arguments: {
                'mobileNumber': _mobileController.text.trim(),
                'countryCode': _countryCode,
                'verificationID': verificationId,
              })!;
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on Exception catch (_) {
      Utils.showSnackBar(
          context: context, message: verificationErrorMessageKey);
    }
  }

  onTapSendOTPButton(UserDetailsState state) {
    FocusScope.of(context).unfocus();
    if (!_isChecked) {
      Utils.showSnackBar(
          message: pleaseAcceptTermsAndConditionAndPrivacyPolicyKey,
          context: context);
      return;
    }
    if (_formKey.currentState!.validate()) {
      {
        //if firebase authentication is enabled then send otp otherwise fetch user details and redirect to otp scree

        if (context
            .read<SettingsAndLanguagesCubit>()
            .getIsFirebaseAuthentication()) {
          setState(() {
            _isLoading = true;
          });
          signInWithPhoneNumber();
        } else {
          context.read<UserDetailsCubit>().fetchUserDetails(params: {
            Api.mobileApiKey: _mobileController.text.trim(),
          });
        }
      }
    }
  }
}
