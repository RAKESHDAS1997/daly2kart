import 'package:eshop_pro/cubits/auth/authCubit.dart';
import 'package:eshop_pro/cubits/delete_account_cubit.dart';
import 'package:eshop_pro/cubits/user_details_cubit.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/ui/widgets/filterContainerForBottomSheet.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/routes.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/labelKeys.dart';
import '../../../../utils/utils.dart';
import '../../../../utils/validator.dart';
import '../../../widgets/customAppbar.dart';
import '../../../widgets/customRoundedButton.dart';
import '../../../widgets/customTextButton.dart';
import '../../../widgets/customTextContainer.dart';
import '../../../widgets/customTextFieldContainer.dart';
import '../../../widgets/showHidePasswordButton.dart';

class DeleteAccountScreen extends StatelessWidget {
  static Widget getRouteInstance() => BlocProvider(
        create: (context) => DeleteAccountCubit(),
        child: const DeleteAccountScreen(),
      );
  const DeleteAccountScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(
        titleKey: deleteAccountKey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(appContentHorizontalPadding),
        child: Column(
          children: <Widget>[
            CustomTextContainer(
              textKey: deleteAccntWarning1Key,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.8)),
            ),
            const SizedBox(
              height: 8,
            ),
            CustomTextContainer(
              textKey: deleteAccntWarning2Key,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.8)),
            ),
            DesignConfig.defaultHeightSizedBox,
            buildDeleteButton(),
            const SizedBox(
              height: 8,
            ),
            CustomTextButton(
                buttonTextKey: backToProfileKey,
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
                onTapButton: () {
                  Utils.popNavigation(context);
                  Utils.popNavigation(context);
                })
          ],
        ),
      ),
    );
  }

  Widget buildDeleteButton() {
    return BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
      listener: (context, state) async {
        if (state is DeleteAccountFailure) {
          if (state.errorMessage == requireRecentLoginErrorMessageKey) {
            Utils.openAlertDialog(
              context,
              message: requireRecentLoginKey,
              content: state.errorMessage,
              noLabel: cancelKey,
              yesLabel: logoutKey,
              onTapYes: () {
                Navigator.of(context).pop();
                context.read<AuthCubit>().signOut(context);
                Utils.navigateToScreen(context, Routes.loginScreen,
                    replaceAll: true);
              },
            );
          } else {
            Utils.showSnackBar(message: state.errorMessage, context: context);
          }
        }
        if (state is AccountDeleted) {
          Utils.showSnackBar(message: state.successMessage, context: context);
          await Future.delayed(const Duration(seconds: 1));

          Utils.navigateToScreen(context, Routes.loginScreen, replaceAll: true);
        }
      },
      builder: (context, state) {
        return CustomRoundedButton(
          widthPercentage: 1.0,
          buttonTitle: deleteMyAccountKey,
          showBorder: false,
          child: state is DeleteAccountProgress
              ? const CustomCircularProgressIndicator()
              : null,
          onTap: () {
            if (state is DeleteAccountProgress) {
              return;
            }
            if (isDemoApp) {
              Utils.showSnackBar(
                  message: deleteAcctNotAllowedInDemoAppKey, context: context);
              return;
            }
            context.read<UserDetailsCubit>().getUserType() == phoneLoginType
                ? openDialog(context)
                : context
                    .read<DeleteAccountCubit>()
                    .deleteUserAccount(isSocialLogin: true, params: {});
          },
        );
      },
    );
  }

  openDialog(BuildContext context) {
    final TextEditingController _mobileController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    FocusNode? _passwordFocus = FocusNode();
    bool _hidePassword = true;
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    Utils.openModalBottomSheet(context,
            StatefulBuilder(builder: (context, StateSetter setState) {
      return BlocProvider(
        create: (context) => DeleteAccountCubit(),
        child: BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
          listener: (context, state) async {
            if (state is DeleteAccountFailure) {
              Navigator.of(context).pop();
              Utils.showSnackBar(message: state.errorMessage, context: context);
            }
            if (state is AccountDeleted) {
              Utils.showSnackBar(
                  message: state.successMessage, context: context);
              await Future.delayed(const Duration(seconds: 1));

              Utils.navigateToScreen(context, Routes.loginScreen,
                  replaceAll: true);
            }
          },
          builder: (context, state) {
            return FilterContainerForBottomSheet(
                title: deleteAccountKey,
                borderedButtonTitle: cancelKey,
                primaryButtonTitle: deleteAccountKey,
                borderedButtonOnTap: () => Navigator.of(context).pop(),
                primaryChild: state is DeleteAccountProgress
                    ? const CustomCircularProgressIndicator()
                    : null,
                primaryButtonOnTap: () {
                  if (state is DeleteAccountProgress) {
                    return;
                  }
                  if (_formKey.currentState!.validate()) {
                    context
                        .read<DeleteAccountCubit>()
                        .deleteUserAccount(isSocialLogin: false, params: {
                      Api.mobileApiKey: _mobileController.text.trim(),
                      Api.passwordApiKey: _passwordController.text.trim()
                    });
                  }
                },
                content: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      CustomTextFieldContainer(
                        hintTextKey: mobileNumberKey,
                        textEditingController: _mobileController,
                        labelKey: '',
                        keyboardType: TextInputType.number,

                        textInputAction: TextInputAction.next,
                        // maxLength: 15,
                        inputFormatters: [
                          FilteringTextInputFormatter
                              .digitsOnly, // Allow only digits
                          LengthLimitingTextInputFormatter(
                              15), // Limit to 15 digits
                        ],
                        validator: (v) =>
                            Validator.validatePhoneNumber(v, context),
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
                        validator: (v) =>
                            Validator.validatePassword(context, v),
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
                          _passwordFocus.unfocus();
                        },
                      ),
                    ],
                  ),
                ));
          },
        ),
      );
    }), staticContent: true)
        .then((value) {});
  }
}
