import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eshop_pro/cubits/auth/authCubit.dart';
import 'package:eshop_pro/cubits/updateUserCubit.dart';
import 'package:eshop_pro/ui/widgets/customAppbar.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/ui/widgets/customRoundedButton.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/ui/widgets/customTextFieldContainer.dart';
import 'package:eshop_pro/ui/widgets/error_screen.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../cubits/user_details_cubit.dart';
import '../../../utils/api.dart';
import '../../../utils/labelKeys.dart';
import '../../../utils/utils.dart';
import '../../../utils/validator.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
  });
  static Widget getRouteInstance() => BlocProvider(
        create: (context) => UpdateUserCubit(),
        child: const EditProfileScreen(),
      );
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, TextEditingController> controllers = {};
  Map<String, FocusNode> focusNodes = {};
  File? _selectedImage;
  String _mimeType = '';
  final ImagePicker _picker = ImagePicker();

  final List formFields = [
    usernameKey,
    phoneNumberKey,
    emailKey,
    referralCodeKey
  ];
  @override
  void initState() {
    super.initState();
    _selectedImage = null;
    formFields.forEach((key) {
      controllers[key] = TextEditingController();
      focusNodes[key] = FocusNode();
    });
    setFormFieldValues();
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

  void setFormFieldValues() {
    Future.delayed(Duration.zero, () {
      controllers[usernameKey]!.text =
          context.read<UserDetailsCubit>().getUserName() ?? '';
      controllers[emailKey]!.text =
          context.read<UserDetailsCubit>().getUserEmail();
      controllers[phoneNumberKey]!.text =
          context.read<UserDetailsCubit>().getUserMobile();
      controllers[referralCodeKey]!.text =
          context.read<UserDetailsCubit>().getReferalCode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(titleKey: profileKey),
      body: BlocBuilder<UserDetailsCubit, UserDetailsState>(
        bloc: context.read<UserDetailsCubit>(),
        builder: (context, state) {
          if (state is UserDetailsFetchSuccess) {
            return ListView(
                padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: appContentHorizontalPadding,
                    vertical: appContentHorizontalPadding * 2),
                children: [
                  userImageWidget(state.userDetails.image ?? ''),
                  const SizedBox(
                    height: 24,
                  ),
                  formWidget(),
                ]);
          } else if (state is UserDetailsFetchFailure) {
            return ErrorScreen(
                text: state.errorMessage,
                onPressed: () => context
                    .read<UserDetailsCubit>()
                    .fetchUserDetails(
                        params: Utils.getParamsForVerifyUser(context)));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  formWidget() {
    return Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CustomTextFieldContainer(
            labelKey: usernameKey,
            hintTextKey: usernameKey,
            textEditingController: controllers[usernameKey]!,
            focusNode: focusNodes[usernameKey],
            textInputAction: TextInputAction.next,
            validator: (v) => Validator.validateName(context, v),
            isFieldValueMandatory: false,
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[emailKey]);
            },
          ),
          CustomTextFieldContainer(
            labelKey: emailKey,
            hintTextKey: emailKey,
            readOnly: context.read<AuthCubit>().getUserDetails().type !=
                    phoneLoginType
                ? true
                : false,
            textEditingController: controllers[emailKey]!,
            focusNode: focusNodes[emailKey],
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => Validator.validateEmail(context, v),
            isFieldValueMandatory: false,
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[phoneNumberKey]);
            },
          ),
          CustomTextFieldContainer(
            labelKey: phoneNumberKey,
            hintTextKey: phoneNumberKey,
            readOnly: context.read<AuthCubit>().getUserDetails().type ==
                    phoneLoginType
                ? true
                : false,
            textEditingController: controllers[phoneNumberKey]!,
            focusNode: focusNodes[phoneNumberKey],
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Allow only digits
              LengthLimitingTextInputFormatter(15), // Limit to 16 digits
            ],
            validator: (v) => Validator.validatePhoneNumber(v, context),
            isFieldValueMandatory: false,
            onFieldSubmitted: (v) {
              focusNodes[phoneNumberKey]!.unfocus();
              // FocusScope.of(context).requestFocus(focusNodes[referralCodeKey]);
            },
          ),
          CustomTextFieldContainer(
            labelKey: referralCodeKey,
            hintTextKey: referralCodeKey,
            textEditingController: controllers[referralCodeKey]!,
            focusNode: focusNodes[referralCodeKey],
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.text,
            isFieldValueMandatory: false,
            readOnly: true,
            onFieldSubmitted: (v) {
              focusNodes[referralCodeKey]!.unfocus();
            },
          ),
          const SizedBox(
            height: appContentVerticalSpace * 2,
          ),
          BlocConsumer<UpdateUserCubit, UpdateUserState>(
            listener: (context, state) {
              if (state is UpdateUserFetchFailure) {
                Utils.showSnackBar(
                    context: context, message: state.errorMessage);
              }
              if (state is UpdateUserFetchSuccess) {
                Utils.showSnackBar(
                    context: context, message: state.successMessage);
                context.read<UserDetailsCubit>().emitUserSuccessState(
                    state.userDetails.toJson(),
                    (context.read<UserDetailsCubit>().state
                            as UserDetailsFetchSuccess)
                        .token);
                Navigator.of(context).pop();
              }
            },
            builder: (context, state) {
              return CustomRoundedButton(
                  widthPercentage: 1.0,
                  buttonTitle: saveKey,
                  showBorder: false,
                  child: state is UpdateUserFetchInProgress
                      ? const CustomCircularProgressIndicator()
                      : null,
                  onTap: () async {
                    if (state is! UpdateUserFetchInProgress) {
                      if (_formKey.currentState!.validate()) {
                        Map<String, dynamic> params = {
                          Api.userIdApiKey:
                              context.read<UserDetailsCubit>().getUserId(),
                          Api.usernameApiKey:
                              controllers[usernameKey]!.text.trim(),
                          Api.emailApiKey: controllers[emailKey]!.text.trim(),
                          Api.mobileApiKey:
                              controllers[phoneNumberKey]!.text.trim(),
                          Api.referralCodeApiKey:
                              controllers[referralCodeKey]!.text.trim(),
                        };
                        if (_selectedImage != null) {
                          MultipartFile file = await MultipartFile.fromFile(
                            _selectedImage!.path,
                            contentType: DioMediaType('image', _mimeType),
                          );
                          params.addAll({'image': file});
                        }

                        context
                            .read<UpdateUserCubit>()
                            .updateUser(params: params);
                      }
                    }
                  });
            },
          )
        ]));
  }

  userImageWidget(String imageUrl) {
    return Center(
      child: Stack(
        children: [
          ClipOval(
              child: Utils.buildProfilePicture(context, 124, imageUrl,
                  selectedFile: _selectedImage,
                  assetImage: _selectedImage != null,
                  outerBorderColor: Colors.transparent)),
          Positioned(
            bottom: 0,
            right: 10,
            child: GestureDetector(
              onTap: _showPicker,
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        width: 2,
                        color: Theme.of(context).colorScheme.onPrimary)),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 24,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      String fileName = pickedFile.path.split('/').last;
      String fileExtension = fileName.split('.').last.toLowerCase();

      switch (fileExtension) {
        case 'jpeg':
        case 'jpg':
          _mimeType = 'image/jpeg';
          break;
        case 'png':
          _mimeType = 'image/png';
          break;
        case 'gif':
          _mimeType = 'image/gif';
          break;
        default:
          // Handle unsupported file types
          Utils.showSnackBar(
              message: 'Unsupported file type', context: context);
          _mimeType = '';
          return;
      }

      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      // User canceled the picker
    }
  }

  /// Selection dialog that prompts the user to select an existing photo or take a new one
  void _showPicker() {
    Utils.openModalBottomSheet(
        context,
        Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const CustomTextContainer(textKey: 'Photo Library'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const CustomTextContainer(textKey: 'Camera'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        isScrollControlled: false,
        staticContent: true);
  }
}
