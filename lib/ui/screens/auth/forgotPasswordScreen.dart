import 'package:country_code_picker/country_code_picker.dart';
import 'package:eshop_pro/cubits/auth/resetPasswordCubit.dart';
import 'package:eshop_pro/ui/screens/auth/widgets/loginContainer.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/routes.dart';

import '../../../utils/api.dart';
import '../../../utils/utils.dart';
import '../../../utils/validator.dart';
import '../../widgets/customCircularProgressIndicator.dart';
import '../../widgets/customTextFieldContainer.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);
  static Widget getRouteInstance() => BlocProvider(
        create: (context) => ResetPasswordCubit(),
        child: const ForgotPasswordScreen(),
      );
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
        listener: (context, state) {
          if (state is ResetPasswordSuccess) {
            Utils.showSnackBar(message: state.successMessage, context: context);
            Utils.navigateToScreen(context, Routes.loginScreen);
          } else if (state is ResetPasswordFailure) {
            Utils.showSnackBar(message: state.errorMessage, context: context);
          }
        },
        builder: (context, state) {
          return LoginContainer(
            titleText: forgotPasswordTitleKey,
            descriptionText: weWillSendVerificationCodeToKey,
            buttonText: resetPasswordKey,
            onTapButton: state is ResetPasswordInProgress ? () {} : callApi,
            content: buildContent(),
            buttonWidget: state is ResetPasswordInProgress
                ? const CustomCircularProgressIndicator()
                : null,
          );
        },
      ),
    );
  }

  Widget buildContent() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: 25, bottom: 120),
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
                    onChanged: (countryCode) {},
                    flagWidth: 25,
                    padding: const EdgeInsetsDirectional.all(0),
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
                  LengthLimitingTextInputFormatter(15), // Limit to 16 digits
                ],
                labelKey: '',
                validator: (v) => Validator.validatePhoneNumber(v, context),
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

  callApi() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      {
        context.read<ResetPasswordCubit>().resetPassword(params: {
          Api.mobileNoApiKey: _mobileController.text.trim(),
        });
      }
    }
  }
}
