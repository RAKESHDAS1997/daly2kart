import 'package:eshop_pro/cubits/auth/authCubit.dart';
import 'package:eshop_pro/cubits/storesCubit.dart';
import 'package:eshop_pro/cubits/user_details_cubit.dart';
import 'package:eshop_pro/ui/screens/mainScreen.dart';
import 'package:eshop_pro/ui/widgets/customAppbar.dart';
import 'package:eshop_pro/ui/widgets/customTextButton.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/routes.dart';
import '../../../cubits/settingsAndLanguagesCubit.dart';
import '../../../data/models/language.dart';
import '../../../utils/constants.dart';
import '../../../utils/designConfig.dart';
import '../../../utils/labelKeys.dart';
import '../../../utils/utils.dart';
import '../../widgets/customCircularProgressIndicator.dart';
import '../../widgets/customLabelContainer.dart';
import '../../widgets/customRoundedButton.dart';
import '../../widgets/customTextContainer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Size size;
  late Color textColor;
  final _inAppReview = InAppReview.instance;
  Language? _selectedLanguage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedLanguage =
        (context.read<SettingsAndLanguagesCubit>().getCurrentAppLanguage());
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    textColor = Theme.of(context).colorScheme.secondary.withOpacity(0.9);
    return Scaffold(
      appBar: const CustomAppbar(
        titleKey: myProfileKey,
        showBackButton: false,
      ),
      body: buildBody(),
    );
  }

  buildBody() {
    return BlocBuilder<UserDetailsCubit, UserDetailsState>(
      builder: (context, state) {
        return Stack(
            clipBehavior: Clip.hardEdge,
            alignment: AlignmentDirectional.topStart,
            children: [
              Column(
                children: [
                  Container(
                      height: !context.read<UserDetailsCubit>().isGuestUser()
                          ? 200
                          : 80,
                      color: Colors.white),
                  Expanded(
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: <Widget>[
                        if (!context.read<UserDetailsCubit>().isGuestUser())
                          Container(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            width: size.width,
                            margin: const EdgeInsetsDirectional.only(bottom: 8),
                            padding: EdgeInsetsDirectional.only(
                                start: appContentHorizontalPadding,
                                end: appContentHorizontalPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                buildLabel(accountKey),
                                buildListTile(
                                    Icons.person_2_outlined,
                                    profileKey,
                                    (() => Utils.navigateToScreen(
                                        context, Routes.editProfileScreen,
                                        arguments: true))),
                                buildListTile(
                                    Icons.account_balance_wallet_outlined,
                                    walletKey,
                                    () => Utils.navigateToScreen(
                                        context, Routes.walletScreen)),
                                buildListTile(
                                    Icons.receipt_outlined,
                                    transactionKey,
                                    () => Utils.navigateToScreen(
                                            context, Routes.transactionScreen,
                                            arguments: {
                                              'transactionType':
                                                  defaultTransactionType
                                            })),
                              ],
                            ),
                          ),
                        buildListContainer(
                          [
                            buildLabel(settingsKey),
                            buildListTile(Icons.translate, changeLanguageKey,
                                openLanguageBottomSheet),
                            if (!context.read<UserDetailsCubit>().isGuestUser())
                              buildListTile(
                                  Icons.settings_outlined,
                                  settingsKey,
                                  () => Utils.navigateToScreen(
                                      context, Routes.settingScreen)),
                          ],
                        ),
                        buildListContainer(
                          [
                            buildLabel(supportAndInfoKey),
                            if (!context.read<UserDetailsCubit>().isGuestUser())
                              buildListTile(
                                  Icons.support_agent_outlined,
                                  customerSupportKey,
                                  () => Utils.navigateToScreen(
                                      context, Routes.customerSupportScreen)),
                            buildListTile(
                                Icons.perm_phone_msg_outlined,
                                contactUsKey,
                                () => navigatoToPolicyScreen(contactUsKey)),
                            buildListTile(
                                Icons.question_mark,
                                faqKey,
                                () => Utils.navigateToScreen(
                                    context, Routes.faqScreen)),
                            buildListTile(Icons.info_outline, aboutUsKey,
                                () => navigatoToPolicyScreen(aboutUsKey)),
                            buildListTile(
                                Icons.policy_outlined,
                                termsAndPolicyKey,
                                () => Utils.navigateToScreen(
                                    context, Routes.termsAndPolicyScreen)),
                          ],
                        ),
                        buildListContainer([
                          buildLabel(moreKey),
                          buildListTile(
                              Icons.monetization_on_outlined,
                              referAndEarnKey,
                              () => Utils.navigateToScreen(
                                  context, Routes.referAndEarnScreen)),
                          buildListTile(
                              Icons.star_outline, rateUsKey, openRateUsDialog),
                          buildListTile(Icons.share_outlined, shareAppKey, () {
                            Share.share(
                                'Download $appName App from below link : $storeUrl',
                                subject: appName);
                          }),
                          if (!context.read<UserDetailsCubit>().isGuestUser())
                            buildListTile(
                                Icons.logout, logoutKey, openLogoutDialog),
                        ], bottomSpace: false)
                      ],
                    ),
                  ),
                ],
              ),
              buildProfileContainer(),
              if (!context.read<UserDetailsCubit>().isGuestUser())
                buildOrderCouponsAndAddressContainer(),
            ]);
      },
    );
  }

  Widget buildProfileContainer() {
    return BlocBuilder<UserDetailsCubit, UserDetailsState>(
        builder: (context, state) {
      if (state is UserDetailsFetchSuccess) {
        return Container(
          height: 90,
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: appContentHorizontalPadding),
          color: Theme.of(context).colorScheme.primary,
          child: Row(
            children: <Widget>[
              Utils.buildProfilePicture(
                  context, 60, state.userDetails.image ?? "",
                  selectedFile: null,
                  assetImage: false,
                  outerBorderColor: Colors.transparent),
              DesignConfig.defaultWidthSizedBox,
              !context.read<UserDetailsCubit>().isGuestUser()
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CustomTextContainer(
                          textKey: state.userDetails.username ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                        ),
                        CustomTextContainer(
                            textKey: state.userDetails.email ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ))
                      ],
                    )
                  : CustomTextButton(
                      buttonTextKey: loginKey,
                      onTapButton: () {
                        Utils.navigateToScreen(
                          context,
                          Routes.loginScreen,
                        );
                      },
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(
                              decoration: TextDecoration.underline,
                              decorationThickness: 2.0,
                              decorationColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              color: Theme.of(context).colorScheme.onPrimary),
                    ),
            ],
          ),
        );
      }
      return SizedBox();
    });
  }

  buildOrderCouponsAndAddressContainer() {
    return Positioned(
      top: 85,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
        child: Container(
          height: 120,
          width: size.width - appContentHorizontalPadding * 2,
          padding: const EdgeInsets.all(8),
          decoration: ShapeDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              shadows: DesignConfig.appShadow),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildCotentBox(
                    'my_order.svg', myOrderKey, Routes.myOrderScreen),
                buildCotentBox(
                    'coupons.svg', couponsKey, Routes.promoCodeScreen),
                buildCotentBox(
                    'address.svg', addressKey, Routes.myAddressScreen),
              ]),
        ),
      ),
    );
  }

  Widget buildCotentBox(String image, String title, String route) {
    return GestureDetector(
      onTap: () => Utils.navigateToScreen(context, route),
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.all(8),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: 42,
                height: 42,
                padding: const EdgeInsets.all(9),
                decoration: ShapeDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: SvgPicture.asset(Utils.getImagePath(image))),
            const SizedBox(height: 8),
            CustomTextContainer(
              textKey: title,
              style: Theme.of(context).textTheme.titleSmall,
            )
          ],
        ),
      ),
    );
  }

  Container buildListContainer(List<Widget> children,
      {bool bottomSpace = true}) {
    return Container(
      color: Colors.white,
      width: size.width,
      padding: const EdgeInsets.symmetric(
        horizontal: appContentHorizontalPadding,
      ),
      margin: bottomSpace ? const EdgeInsetsDirectional.only(bottom: 8) : null,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  buildLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      child: CustomTextContainer(
        textKey: title,
        style: Theme.of(context).textTheme.titleMedium!,
      ),
    );
  }

  buildListTile(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsetsDirectional.only(bottom: appContentVerticalSpace),
        decoration:
            BoxDecoration(border: Border.all(color: Colors.transparent)),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              padding: const EdgeInsets.all(7),
              decoration: ShapeDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Icon(
                icon,
                size: 22,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            CustomTextContainer(
              textKey: title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: textColor),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: textColor,
            ),
          ],
        ),
      ),
    );
  }

  void openRateUsDialog() async {
    if (await _inAppReview.isAvailable()) {
      _inAppReview.requestReview();
    } else {
      Utils.showSnackBar(message: defaultErrorMessageKey, context: context);
    }
  }

  void openLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext bldcontext) {
        double width = MediaQuery.of(context).size.width;
        return AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            elevation: 0.0,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 56,
            ),
            content: StatefulBuilder(builder: (context, setState) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      width: width,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 30,
                          ),
                          DesignConfig.defaultHeightSizedBox,
                          CustomTextContainer(
                            textKey: logoutKey,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(
                            height: 4.0,
                          ),
                          CustomTextContainer(
                            textKey: areYouSureYouWantToLogoutKey,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          DesignConfig.defaultHeightSizedBox,
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: CustomRoundedButton(
                                  widthPercentage: 0.2,
                                  buttonTitle: noKey,
                                  showBorder: true,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  borderColor: Theme.of(context)
                                      .inputDecorationTheme
                                      .iconColor,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                  onTap: () => Utils.popNavigation(context),
                                ),
                              ),
                              const SizedBox(
                                width: 24,
                              ),
                              Expanded(
                                child: BlocConsumer<AuthCubit, AuthState>(
                                  listener: (context, state) {
                                    if (state is Unauthenticated) {
                                      print('from here');
                                      context
                                          .read<UserDetailsCubit>()
                                          .resetUserDetailsState();
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      context.read<StoresCubit>().resetState();
                                      Navigator.of(context).pop();
                                      MainScreen.mainScreenKey.currentState
                                          ?.changeCurrentIndex(0);
                                    }
                                  },
                                  builder: (context, state) {
                                    if (state is AuthInitial) {
                                      return const CircularProgressIndicator();
                                    }
                                    return CustomRoundedButton(
                                      widthPercentage: 0.2,
                                      buttonTitle: logoutKey,
                                      showBorder: false,
                                      child: _isLoading
                                          ? const CustomCircularProgressIndicator()
                                          : null,
                                      onTap: () {
                                        if (state is Authenticated) {
                                          if (_isLoading) return;
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          context
                                              .read<AuthCubit>()
                                              .signOut(context);
                                        } else {
                                          Utils.errorDialog(
                                              context, pleaseLoginKey);
                                        }
                                      },
                                    );
                                  },
                                ),
                              )
                            ],
                          )
                        ],
                      )),
                ],
              );
            }));
      },
    );
  }

  void navigatoToPolicyScreen(String policy) {
    final settings = context.read<SettingsAndLanguagesCubit>().getSettings();

    Utils.navigateToScreen(context, Routes.policyScreen, arguments: {
      'title': policy,
      'content': policy == aboutUsKey ? settings.aboutUs : settings.contactUs
    });
  }

  void openLanguageBottomSheet() {
    Utils.openModalBottomSheet(
      context,
      staticContent: false,
      BlocBuilder<SettingsAndLanguagesCubit, SettingsAndLanguagesState>(
        bloc: context.read<SettingsAndLanguagesCubit>(),
        builder: (context, state) {
          if (state is SettingsAndLanguagesFetchSuccess) {
            return Container(
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.symmetric(
                    horizontal: appContentHorizontalPadding, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextContainer(
                      textKey: appLanguageKey,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    DesignConfig.smallHeightSizedBox,
                    Expanded(
                      child: ListView.separated(
                        itemCount: state.languages.length,
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (_, index) {
                          Language language = state.languages[index];
                          return RadioListTile(
                            contentPadding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(
                                horizontal: -4, vertical: -2),
                            title: CustomLabelContainer(
                              textKey: language.language
                                      .toString()
                                      .capitalizeFirst ??
                                  '',
                              isFieldValueMandatory: false,
                            ),
                            value: language.code,
                            groupValue: _selectedLanguage!.code!,
                            onChanged: (value) {
                              setState(() {
                                _selectedLanguage = language;
                                context
                                    .read<SettingsAndLanguagesCubit>()
                                    .changeLanguage(language);
                                Future.delayed(
                                    const Duration(milliseconds: 500), () {
                                  Navigator.of(context).pop();
                                });
                              });
                            },
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: 2);
                        },
                      ),
                    ),
                  ],
                ));
          }
          if (state is SettingsAndLanguagesFetchFailure) {
            return const Center(
                child: CustomTextContainer(textKey: dataNotAvailableKey));
          }
          return CustomCircularProgressIndicator(
              indicatorColor: Theme.of(context).colorScheme.primary);
        },
      ),
    );
  }
}
