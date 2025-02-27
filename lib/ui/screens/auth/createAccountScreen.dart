import 'package:eshop_pro/cubits/auth/generateReferCodeCubit.dart';
import 'package:eshop_pro/cubits/auth/registerUserCubit.dart';
import 'package:eshop_pro/data/repositories/authRepository.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/utils/validator.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../app/routes.dart';

import '../../../utils/api.dart';
import '../../../utils/utils.dart';
import '../../widgets/customTextFieldContainer.dart';
import '../../widgets/showHidePasswordButton.dart';
import 'widgets/loginContainer.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen(
      {Key? key, required this.mobileNumber, required this.countryCode})
      : super(key: key);
  final String mobileNumber, countryCode;
  static Widget getRouteInstance() {
    Map<String, dynamic> arguments = Get.arguments as Map<String, dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RegisterUserCubit(),
        ),
        BlocProvider(
          create: (context) => GenerateReferCodeCubit(),
        ),
      ],
      child: CreateAccountScreen(
        mobileNumber: arguments['mobileNumber'],
        countryCode: arguments['countryCode'],
      ),
    );
  }

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  Map<String, TextEditingController> controllers = {};
  Map<String, FocusNode> focusNodes = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _hidePassword = true;
  final List formFields = [
    usernameKey,
    emailKey,
    passwordKey,
    referralCodeKey,
    'friendCode'
  ];
  @override
  void initState() {
    super.initState();
    formFields.forEach((key) {
      controllers[key] = TextEditingController();
      focusNodes[key] = FocusNode();
    });
    Future.delayed(Duration.zero, () {
      context.read<GenerateReferCodeCubit>().getGenerateReferCode();
    });
  }

  @override
  void dispose() {
    controllers.forEach((key, controller) {
      controller.dispose();
    });
    focusNodes.forEach((key, focusNode) {
      focusNode.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocConsumer<RegisterUserCubit, RegisterUserState>(
      listener: (context, state) {
        if (state is RegisterUserSuccess) {
          Utils.showSnackBar(context: context, message: state.sucsessMessage);
          Utils.navigateToScreen(context, Routes.loginScreen, replaceAll: true);
        }
        if (state is RegisterUserFailure) {
          Utils.showSnackBar(context: context, message: state.errorMessage);
        }
      },
      builder: (context, state) {
        return LoginContainer(
          titleText: createNewAccountKey,
          descriptionText: createNewAccountDescKey,
          buttonText: createAccountKey,
          onTapButton: state is RegisterUserProgress ? () {} : callSignupApi,
          content: buildContentWidget(),
          buttonWidget: state is RegisterUserProgress
              ? const CustomCircularProgressIndicator()
              : null,
        );
      },
    ));
  }

  void callSignupApi() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      {
        context.read<RegisterUserCubit>().registerUser(params: {
          Api.nameApiKey: controllers[usernameKey]!.text.trim(),
          Api.emailApiKey: controllers[emailKey]!.text.trim(),
          Api.passwordApiKey: controllers[passwordKey]!.text.trim(),
          Api.referralCodeApiKey: controllers[referralCodeKey]!.text.trim(),
          Api.friendsCodeApiKey: controllers['friendCode']!.text.trim(),
          Api.mobileApiKey: widget.mobileNumber,
          Api.countryCodeApiKey: widget.countryCode,
          Api.fcmIdApiKey: await AuthRepository.getFcmToken(),
        });
      }
    }
  }

  Widget buildContentWidget() {
    return BlocListener<GenerateReferCodeCubit, GenerateReferCodeState>(
      listener: (context, state) {
        if (state is GenerateReferCodeFetchSuccess) {
          controllers[referralCodeKey]!.text = state.referCode;
        }
      },
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(top: 25),
          child: Column(
            children: <Widget>[
              CustomTextFieldContainer(
                hintTextKey: usernameKey,
                textEditingController: controllers[usernameKey]!,
                focusNode: focusNodes[usernameKey],
                textInputAction: TextInputAction.next,
                validator: (v) => Validator.validateName(context, v),
                prefixWidget: const Icon(Icons.account_circle_outlined),
                onFieldSubmitted: (v) {
                  FocusScope.of(context).requestFocus(focusNodes[emailKey]);
                },
              ),
              CustomTextFieldContainer(
                hintTextKey: emailKey,
                textEditingController: controllers[emailKey]!,
                focusNode: focusNodes[emailKey],
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => Validator.validateEmail(context, v),
                prefixWidget: const Icon(Icons.alternate_email_outlined),
                onFieldSubmitted: (v) {
                  FocusScope.of(context).requestFocus(focusNodes[passwordKey]);
                },
              ),
              CustomTextFieldContainer(
                hintTextKey: passwordKey,
                textEditingController: controllers[passwordKey]!,
                hideText: _hidePassword,
                focusNode: focusNodes[passwordKey],
                textInputAction: TextInputAction.next,
                validator: (v) => Validator.validatePassword(context, v),
                maxLines: 1,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp('[ ]')),
                ],
                prefixWidget: const Icon(Icons.lock_outline),
                suffixWidget: ShowHidePasswordButton(
                  hidePassword: _hidePassword,
                  onTapButton: () {
                    setState(() {
                      _hidePassword = !_hidePassword;
                    });
                  },
                ),
                onFieldSubmitted: (v) {
                  FocusScope.of(context)
                      .requestFocus(focusNodes[referralCodeKey]);
                },
              ),
              CustomTextFieldContainer(
                hintTextKey: referralCodeKey,
                textEditingController: controllers['friendCode']!,
                focusNode: focusNodes[referralCodeKey],
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                prefixWidget: const Icon(Icons.card_giftcard_outlined),
                onFieldSubmitted: (v) {
                  focusNodes[referralCodeKey]!.unfocus();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool validateAndSave() {
    final form = _formKey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }
}
