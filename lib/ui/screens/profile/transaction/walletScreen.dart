import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/transaction/sendWithdrawalReqCubit.dart';
import 'package:eshop_pro/cubits/user_details_cubit.dart';
import 'package:eshop_pro/ui/screens/profile/transaction/transactionScreen.dart';

import 'package:eshop_pro/ui/widgets/customAppbar.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/ui/widgets/customRoundedButton.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/ui/widgets/customTextFieldContainer.dart';
import 'package:eshop_pro/ui/widgets/filterContainerForBottomSheet.dart';
import 'package:eshop_pro/ui/widgets/primaryContainerWithBackground.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/settingsAndLanguagesCubit.dart';
import '../../../../cubits/transaction/transactionCubit.dart';
import '../../../../utils/utils.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({
    super.key,
  });
  static Widget getRouteInstance() => BlocProvider(
        create: (context) => UserDetailsCubit(),
        child: const WalletScreen(),
      );
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  GlobalKey _walletKey = GlobalKey();
  @override
  initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context
            .read<UserDetailsCubit>()
            .fetchUserDetails(params: Utils.getParamsForVerifyUser(context));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(
        titleKey: walletKey,
      ),
      body: BlocProvider(
        create: (context) => TransactionCubit(),
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 12,
            ),
            buildWalletContainer(),
            buildTabBar(),
          ],
        ),
      ),
    );
  }

  buildWalletContainer() {
    return PrimaryContainerWithBackground(
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
            horizontal: appContentHorizontalPadding),
        child: Column(
          children: <Widget>[
            CustomTextContainer(
                textKey: currentBalanceKey,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Theme.of(context).colorScheme.onPrimary)),
            const SizedBox(
              height: 4,
            ),
            BlocBuilder<UserDetailsCubit, UserDetailsState>(
              builder: (context, state) {
                return Column(
                  children: [
                    CustomTextContainer(
                        textKey: Utils.priceWithCurrencySymbol(
                            price: context
                                    .read<UserDetailsCubit>()
                                    .getuserDetails()
                                    .balance ??
                                0,
                            context: context),
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary)),
                    DesignConfig.defaultHeightSizedBox,
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: CustomRoundedButton(
                            widthPercentage: 0.2,
                            buttonTitle: addMoneyKey,
                            showBorder: true,
                            backgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                            onTap: () => Utils.navigateToScreen(
                                    context, Routes.addMoneyScreen)!
                                .then((value) {
                              if (value == 'update') {
                                setState(() {
                                  context
                                      .read<UserDetailsCubit>()
                                      .fetchUserDetails(
                                          params: Utils.getParamsForVerifyUser(
                                              context));
                                  context
                                      .read<TransactionCubit>()
                                      .getTransaction(
                                          userId: context
                                              .read<UserDetailsCubit>()
                                              .getUserId(),
                                          transactionType:
                                              walletTransactionType,
                                          type: creditType);
                                  _walletKey = GlobalKey();
                                });
                              }
                            }),
                          ),
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        Expanded(
                          child: CustomRoundedButton(
                            widthPercentage: 0.2,
                            buttonTitle: withdrawMoneyKey,
                            showBorder: true,
                            backgroundColor: Colors.transparent,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                            borderColor:
                                Theme.of(context).colorScheme.onPrimary,
                            onTap: state is UserDetailsFetchSuccess &&
                                    (state.userDetails.balance ?? 0) > 0
                                ? () => openWithdrawBottomSheet(
                                    context.read<UserDetailsCubit>())
                                : () => Utils.showSnackBar(
                                    message: 'Insufficient wallet balance',
                                    context: context),
                          ),
                        )
                      ],
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  buildTabBar() {
    return Expanded(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            Container(
              height: 40,
              padding: const EdgeInsetsDirectional.only(
                  top: 5,
                  start: appContentHorizontalPadding,
                  end: appContentHorizontalPadding),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.secondary,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: Theme.of(context).textTheme.bodyLarge,
                tabs: [
                  buildTabLabel(walletTransactionKey),
                  buildTabLabel(walletWithdrawKey)
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                  physics:
                      const NeverScrollableScrollPhysics(), // This approach forces both tabs to build at once, which may have performance implications if your TransactionScreen is resource-intensive.
                  children: [
                    TransactionScreen(
                      key: _walletKey,
                      transactionType: walletTransactionType,
                      walletType: creditType,
                    ),
                    BlocProvider(
                        create: (context) => TransactionCubit(),
                        child: TransactionScreen(
                          key: TransactionScreen.withdrawScreenKey,
                          transactionType: walletTransactionType,
                          walletType: debitType,
                        )),
                  ]),
            )
          ],
        ),
      ),
    );
  }

  Tab buildTabLabel(String title) {
    return Tab(
      text: context
          .read<SettingsAndLanguagesCubit>()
          .getTranslatedValue(labelKey: title),
    );
  }

  openWithdrawBottomSheet(UserDetailsCubit userDetailsCubit) {
    Map<String, TextEditingController> controllers = {};
    Map<String, FocusNode> focusNodes = {};
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final List formFields = [
      withdrawalAmountKey,
      accountNumberKey,
      nameKey,
      ifscCodeKey,
    ];
    formFields.forEach((key) {
      controllers[key] = TextEditingController();
      focusNodes[key] = FocusNode();
    });
    Utils.openModalBottomSheet(
            context,
            BlocProvider(
              create: (context) => SendWithdrawalRequestCubit(),
              child: BlocConsumer<SendWithdrawalRequestCubit,
                  SendWithdrawalRequestState>(
                listener: (context, state) {
                  if (state is SendWithdrawalRequestSuccess) {
                    if (TransactionScreen.withdrawScreenKey.currentState !=
                        null) {
                      TransactionScreen.withdrawScreenKey.currentState!
                          .addItemInList(state.transaction);
                    }
                    userDetailsCubit.fetchUserDetails(
                        params: Utils.getParamsForVerifyUser(context));
                    Utils.showSnackBar(
                        context: context, message: state.successMessage);
                    final navigator = Navigator.of(context);
                    Future.delayed(const Duration(milliseconds: 500), () {
                      navigator.pop();
                    });
                  }
                  if (state is SendWithdrawalRequestFailure) {
                    Navigator.of(context).pop();
                    Utils.showSnackBar(
                        context: context, message: state.errorMessage);
                  }
                },
                builder: (context, state) {
                  return FilterContainerForBottomSheet(
                      title: '',
                      borderedButtonTitle: cancelKey,
                      primaryButtonTitle: sendKey,
                      primaryChild: state is SendWithdrawalRequestProgress
                          ? const CustomCircularProgressIndicator()
                          : null,
                      borderedButtonOnTap: () => Navigator.of(context).pop(),
                      primaryButtonOnTap: () {
                        if (formKey.currentState!.validate()) {
                          if (state is! SendWithdrawalRequestProgress) {
                            context
                                .read<SendWithdrawalRequestCubit>()
                                .sendWithdrawalRequest(params: {
                              Api.amountApiKey:
                                  controllers[withdrawalAmountKey]!.text.trim(),
                              Api.paymentAddressApiKey:
                                  '${controllers[accountNumberKey]!.text.toString()}\n${controllers[ifscCodeKey]!.text.toString()}\n${controllers[nameKey]!.text.toString()}'
                            });
                          }
                        }
                      },
                      content: Form(
                        key: formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            CustomTextFieldContainer(
                              hintTextKey: withdrawalAmountKey,
                              textEditingController:
                                  controllers[withdrawalAmountKey]!,
                              focusNode: focusNodes[withdrawalAmountKey],
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              validator: (val) {
                                if (val.trim().isEmpty) {
                                  return Validator.emptyValueValidation(
                                      context, val);
                                }
                                final amount = double.tryParse(val);
                                if (amount == null || amount <= 0) {
                                  return context
                                      .read<SettingsAndLanguagesCubit>()
                                      .getTranslatedValue(
                                          labelKey: enterValidAmountKey);
                                }
                              },
                              onFieldSubmitted: (v) {
                                FocusScope.of(context)
                                    .requestFocus(focusNodes[accountNumberKey]);
                              },
                            ),
                            DesignConfig.defaultHeightSizedBox,
                            CustomTextContainer(
                              textKey: bankDetailsKey,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            DesignConfig.smallHeightSizedBox,
                            CustomTextFieldContainer(
                              hintTextKey: accountNumberKey,
                              textEditingController:
                                  controllers[accountNumberKey]!,
                              focusNode: focusNodes[accountNumberKey],
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textInputAction: TextInputAction.next,
                              validator: (val) =>
                                  Validator.emptyValueValidation(context, val),
                              onFieldSubmitted: (v) {
                                FocusScope.of(context)
                                    .requestFocus(focusNodes[ifscCodeKey]);
                              },
                            ),
                            CustomTextFieldContainer(
                              hintTextKey: ifscCodeKey,
                              textEditingController: controllers[ifscCodeKey]!,
                              focusNode: focusNodes[ifscCodeKey],
                              textInputAction: TextInputAction.next,
                              validator: (val) =>
                                  Validator.emptyValueValidation(context, val),
                              onFieldSubmitted: (v) {
                                FocusScope.of(context)
                                    .requestFocus(focusNodes[nameKey]);
                              },
                            ),
                            CustomTextFieldContainer(
                              hintTextKey: nameKey,
                              textEditingController: controllers[nameKey]!,
                              focusNode: focusNodes[nameKey],
                              textInputAction: TextInputAction.done,
                              validator: (val) =>
                                  Validator.emptyValueValidation(context, val),
                              onFieldSubmitted: (v) {
                                focusNodes[nameKey]!.unfocus();
                              },
                            ),
                          ],
                        ),
                      ));
                },
              ),
            ),
            isScrollControlled: false,
            staticContent: true)
        .then((value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controllers.forEach((key, controller) {
          controller.dispose();
        });
        focusNodes.forEach((key, focusNode) {
          focusNode.dispose();
        });
      });
    });
  }
}
