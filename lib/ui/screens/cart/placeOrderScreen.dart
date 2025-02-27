// ignore_for_file: use_build_context_synchronously

import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/address/deleteAddressCubit.dart';
import 'package:eshop_pro/cubits/address/getAddressCubit.dart';
import 'package:eshop_pro/cubits/cart/checkCartProductDelCubit.dart';
import 'package:eshop_pro/cubits/cart/clearCartCubit.dart';
import 'package:eshop_pro/cubits/cart/getUserCart.dart';
import 'package:eshop_pro/cubits/cart/placeOrderCubit.dart';
import 'package:eshop_pro/cubits/order/deleteOrderCubit.dart';
import 'package:eshop_pro/cubits/order/updateOrderCubit.dart';
import 'package:eshop_pro/cubits/settingsAndLanguagesCubit.dart';
import 'package:eshop_pro/cubits/storesCubit.dart';
import 'package:eshop_pro/cubits/transaction/addTransactionCubit.dart';
import 'package:eshop_pro/cubits/transaction/getPaymentMethodCubit.dart';
import 'package:eshop_pro/cubits/user_details_cubit.dart';
import 'package:eshop_pro/data/models/cart.dart';
import 'package:eshop_pro/data/models/paymentMethod.dart';
import 'package:eshop_pro/data/models/product.dart';
import 'package:eshop_pro/data/repositories/cartRepository.dart';
import 'package:eshop_pro/data/repositories/transactionRepository.dart';
import 'package:eshop_pro/ui/screens/cart/selectPaymentScreen.dart';
import 'package:eshop_pro/ui/screens/cart/widgets/customStepper.dart';
import 'package:eshop_pro/ui/screens/cart/widgets/finalCartScreen.dart';
import 'package:eshop_pro/ui/screens/mainScreen.dart';
import 'package:eshop_pro/ui/screens/profile/address/myAddressScreen.dart';
import 'package:eshop_pro/ui/widgets/customAppbar.dart';
import 'package:eshop_pro/ui/widgets/customBottomButtonContainer.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/ui/widgets/customDefaultContainer.dart';
import 'package:eshop_pro/ui/widgets/customRoundedButton.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/ui/widgets/customTextFieldContainer.dart';
import 'package:eshop_pro/ui/widgets/error_screen.dart';
import 'package:eshop_pro/ui/widgets/filterContainerForBottomSheet.dart';
import 'package:eshop_pro/utils/Stripe_Service.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:eshop_pro/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PlaceOrderScreen extends StatefulWidget {
  const PlaceOrderScreen({Key? key}) : super(key: key);
  static Widget getRouteInstance() => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => CheckCartProductDeliverabilityCubit(),
          ),
          BlocProvider(
            create: (context) => PaymentMethodCubit(),
          ),
          BlocProvider(
            create: (context) => PlaceOrderCubit(),
          ),
          BlocProvider(
            create: (context) => ClearCartCubit(),
          ),
          BlocProvider(
            create: (context) => UpdateOrderCubit(),
          ),
          BlocProvider(
            create: (context) => AddTransactionCubit(),
          ),
          BlocProvider(
            create: (context) => DeleteOrderCubit(),
          ),
        ],
        child: const PlaceOrderScreen(),
      );
  @override
  _PlaceOrderScreenState createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  int _currentStep = 1;
  int _stepLength = 3;
  bool _isLoading = false;
  String currentOrderID = '';
  PaymentModel? _selectedPaymentMethod;
  Razorpay? _razorpay;

  @override
  initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<PaymentMethodCubit>().fetchPaymentMethods();
      if (context
              .read<GetUserCartCubit>()
              .getCartDetail()
              .cartProducts![0]
              .type ==
          digitalProductType) {
        setState(() {
          _currentStep = 2;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
       
        BlocListener<DeleteOrderCubit, DeleteOrderState>(
          listener: (context, state) async {
            if (state is DeleteOrderFailure) {
              Utils.showSnackBar(message: state.errorMessage, context: context);
            }
            if (state is DeleteOrderSuccess) {
       
            }
          },
        ),

        BlocListener<AddTransactionCubit, AddTransactionState>(
          listener: (context, state) {
            if (state is AddTransactionSuccess) {
              context.read<ClearCartCubit>().clearCart(context);

              Utils.navigateToScreen(context, Routes.orderConfirmedScreen,
                  arguments: state.orderId, replacePrevious: true);
            }
            if (state is AddTransactionFailure) {
              Utils.showSnackBar(message: state.errorMessage, context: context);
            }
          },
        ),
        BlocListener<PaymentMethodCubit, PaymentMethodState>(
          listener: (context, state) {
            if (state is PaymentMethodFetchSuccess) {
              if (context
                      .read<GetUserCartCubit>()
                      .getCartDetail()
                      .cartProducts![0]
                      .type ==
                  digitalProductType) {
                state.paymentMethods.removeWhere(
                    (element) => element.name == cashOnDeliveryKey);
              }

              //we will remove COD option if at least one product is not COD allowed
              if (context
                      .read<GetUserCartCubit>()
                      .getCartDetail()
                      .cartProducts !=
                  null) {
                if (context
                        .read<GetUserCartCubit>()
                        .getCartDetail()
                        .cartProducts!
                        .indexWhere((element) =>
                            element.productDetails!.first.codAllowed == 0) !=
                    -1) {
                  state.paymentMethods.removeWhere(
                      (element) => element.name == cashOnDeliveryKey);
                }
              }

              _selectedPaymentMethod = state.paymentMethods
                  .firstWhere((element) => element.isSelected == true);

              context
                  .read<GetUserCartCubit>()
                  .changePaymantMethod(_selectedPaymentMethod!);
            }
          },
        ),
      ],
      child: BlocConsumer<PlaceOrderCubit, PlaceOrderState>(
        listener: (context, state) {
          // if payable amount is 0 then not necessary to redirect to payment screen
          if (state is PlaceOrderSuccess) {
            setState(() {
              _isLoading = false;
            });
            if (context
                    .read<GetUserCartCubit>()
                    .getCartDetail()
                    .useWalletBalance ==
                true) {
         
            }
            MainScreen.mainScreenKey.currentState!.refreshProducts();
            currentOrderID = state.orderId.toString();
            if (context
                    .read<GetUserCartCubit>()
                    .getCartDetail()
                    .overallAmount ==
                0) {
              doOnSuccess();
            } else {
              initiatePaymentMethod(state.orderId, state.finalTotal);
            }
          }
          if (state is PlaceOrderFailure) {
            Utils.showSnackBar(
                context: context,
                message: state.errorMessage,
                duration: const Duration(seconds: 5),
                backgroundColor: Theme.of(context).colorScheme.error);
          }
        },
        builder: (context, state) {
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              PopScope(
                canPop: _currentStep > 1
                    ? context
                                    .read<GetUserCartCubit>()
                                    .getCartDetail()
                                    .cartProducts![0]
                                    .type ==
                                digitalProductType &&
                            _currentStep == 2
                        ? true
                        : false
                    : false,
            
                onPopInvokedWithResult: (didPop, result) async {
                  if (didPop) return;

                  if (_currentStep > 1) {
                    if (context
                                .read<GetUserCartCubit>()
                                .getCartDetail()
                                .cartProducts![0]
                                .type ==
                            digitalProductType &&
                        _currentStep == 2) {
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        _currentStep--;
                      });
                    }
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: BlocBuilder<GetUserCartCubit, GetUserCartState>(
                  builder: (context, state) {
                    return Scaffold(
                      appBar: CustomAppbar(
                          titleKey: _currentStep == 1
                              ? selectAddressKey
                              : _currentStep == 2
                                  ? selectPaymentKey
                                  : cartKey,
                          onBackButtonTap: () {
                            if (_currentStep > 1) {
                              if (context
                                          .read<GetUserCartCubit>()
                                          .getCartDetail()
                                          .cartProducts![0]
                                          .type ==
                                      digitalProductType &&
                                  _currentStep == 2) {
                                Navigator.of(context).pop();
                              } else {
                                setState(() {
                                  _currentStep--;
                                });
                              }
                            } else {
                              Navigator.of(context).pop();
                            }
                          }),
                      body: buildBody(),
                      bottomNavigationBar: buildNavigationButtons(),
                    );
                  },
                ),
              ),
              if (state is PlaceOrderInProgress)
                Container(
                  color: Colors.black.withOpacity(0.4),
                  child: CustomCircularProgressIndicator(
                    strokeWidth: 3,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget buildNavigationButtons() {
    return BlocBuilder<GetAddressCubit, GetAddressState>(
        builder: (context, state) {
      return BlocListener<CheckCartProductDeliverabilityCubit,
          CheckCartProductDeliverabilityState>(
        listener: (context, state) {
          if (state is CheckCartProductDeliverabilitySuccess) {
            setState(() {
              _currentStep = 2;
            });
          }
          if (state is CheckCartProductDeliverabilityFailure) {
            if (state.errorData != null) {
              for (var item in state.errorData!) {
                if (item['is_deliverable'] == false) {
                  int productId = item['product_id'];
                  String errorMessage =
                      '${item['name']} ${context.read<SettingsAndLanguagesCubit>().getTranslatedValue(labelKey: notDelierableErrorMessageKey)}';

                  // Find the corresponding CartProduct and assign the error message
                  context
                      .read<GetUserCartCubit>()
                      .setErrorMessage(productId, errorMessage);
                }
              }
            }

            Utils.showSnackBar(
                context: context,
                duration: const Duration(seconds: 7),
                backgroundColor: Theme.of(context).colorScheme.error,
                message: state.errorMessage);
            Navigator.of(context).pop(true);
          }
        },
        child: BlocBuilder<PlaceOrderCubit, PlaceOrderState>(
            builder: (context, state) {
          if (_currentStep == 1 &&
              context.read<GetAddressCubit>().getAddressList().isEmpty) {
            return const SizedBox.shrink();
          }
          return CustomBottomButtonContainer(
            child: CustomRoundedButton(
              widthPercentage: 0.5,
              buttonTitle: _currentStep == 1
                  ? deliverToThisAddressKey
                  : _currentStep == 2
                      ? continueKey
                      : placeOrderKey,
              showBorder: false,
              onTap: () {
                if (_currentStep == 1) {
                  if (context
                          .read<GetUserCartCubit>()
                          .getCartDetail()
                          .selectedAddress ==
                      null) {
                    Utils.showSnackBar(
                        context: context, message: selectAddressWarningKey);
                    return;
                  }
                  context
                      .read<CheckCartProductDeliverabilityCubit>()
                      .checkDeliverability(
                          storeId:
                              context.read<StoresCubit>().getDefaultStore().id!,
                          addressId: context
                              .read<GetUserCartCubit>()
                              .getCartDetail()
                              .selectedAddress!
                              .id!);
                } else if (_currentStep == 2) {
                  if (context.read<PaymentMethodCubit>().state
                          is PaymentMethodFetchSuccess ||
                      context
                              .read<GetUserCartCubit>()
                              .getCartDetail()
                              .selectedPaymentMethod ==
                          null) {
                    setState(() {
                      _currentStep = 3;
                    });
                  }
                } else {
                  Cart cart = context.read<GetUserCartCubit>().getCartDetail();
                  if (cart.cartProducts![0].type == digitalProductType) {
                    if (cart.emailAddress == null) {
                      openBottomShhetForDigitalProduct();

                      Utils.showSnackBar(
                          message: enterEmailForCheckoutKey, context: context);
                      return;
                    }
                  }

                  Map<String, dynamic> params = {
                    Api.storeIdApiKey:
                        context.read<StoresCubit>().getDefaultStore().id,
                    Api.deliveryChargeApiKey: cart.deliveryCharge,
                    if (cart.promoCode != null)
                      Api.promoCodeIdApiKey: cart.promoCode!.id,
                    Api.paymentMethodApiKey: cart.selectedPaymentMethod == null
                        ? ''
                        : cart.selectedPaymentMethod!.name == cashOnDeliveryKey
                            ? 'cod'
                            : cart.selectedPaymentMethod!.name!.toLowerCase(),
                    Api.isWalletUsedApiKey:
                        cart.useWalletBalance == true ? 1 : 0,
                    Api.walletBalanceUsedApiKey:
                        cart.useWalletBalance == true ? cart.walletAmount : 0,
                    Api.orderNoteApiKey: cart.deliveryInstruction,
                    Api.orderPaymentCurrencyCodeApiKey: context
                        .read<SettingsAndLanguagesCubit>()
                        .getSettings()
                        .systemSettings!
                        .currencySetting!
                        .code
                  };
           
                  if (cart.cartProducts![0].type == digitalProductType) {
                    params.addAll({Api.emailApiKey: cart.emailAddress});
                  } else {
                    params.addAll(
                        {Api.addressIdApiKey: cart.selectedAddress!.id});
                  }
                  context.read<PlaceOrderCubit>().placeOrder(params: params);
                }
              },
            ),
          );
        }),
      );
    });
  }

  buildBody() {
    if (context.read<GetUserCartCubit>().getCartDetail().cartProducts != null &&
        context
            .read<GetUserCartCubit>()
            .getCartDetail()
            .cartProducts!
            .isNotEmpty) {
      return Column(
        children: [
          CustomDefaultContainer(
            child: CustomStepper(
              totalSteps: _stepLength,
              width: MediaQuery.of(context).size.width,
              curStep: _currentStep,
              startIndex: context
                          .read<GetUserCartCubit>()
                          .getCartDetail()
                          .cartProducts![0]
                          .type ==
                      digitalProductType
                  ? 2
                  : 1,
              stepCompleteColor: Theme.of(context).colorScheme.primary,
              currentStepColor: Theme.of(context).colorScheme.primary,
              inactiveColor: Theme.of(context).colorScheme.secondary,
              lineWidth: 2.0,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Expanded(
              child: _currentStep == 1
                  ? BlocProvider(
                      create: (context) => DeleteAddressCubit(),
                      child: MyAddressScreen(
                        isFromCartScreen: true,
                        onInstAdded: onInstructionAdded,
                      ),
                    )
                  : _currentStep == 2
                      ? BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
                          builder: (context, state) {
                            if (state is PaymentMethodFetchSuccess) {
                              return BlocProvider(
                                create: (context) => UserDetailsCubit(),
                                child: SelectPaymentScreen(
                                  selectedPaymentMethod:
                                      _selectedPaymentMethod!,
                                  paymentMethodCubit:
                                      context.read<PaymentMethodCubit>(),
                                ),
                              );
                            }
                            if (state is PaymentMethodFetchFailure) {
                              return ErrorScreen(
                                  text: state.errorMessage,
                                  onPressed: () {
                                    context
                                        .read<PaymentMethodCubit>()
                                        .fetchPaymentMethods();
                                  });
                            }
                            if (state is PaymentMethodFetchInProgress) {
                              return CustomCircularProgressIndicator(
                                  indicatorColor:
                                      Theme.of(context).colorScheme.primary);
                            }
                            return const SizedBox.shrink();
                          },
                        )
                      : FinalCartScreen(
                          onInstAdded: onInstructionAdded,
                          placeOrderState:
                              context.read<PlaceOrderCubit>().state))
        ],
      );
    }
    return const SizedBox.shrink();
  }

  onInstructionAdded(int index) {
    setState(() {
      _currentStep = index;
    });
  }

  initiatePaymentMethod(int orderID, double finalTotal) async {
    var response;

    currentOrderID = orderID.toString();
    if (_selectedPaymentMethod != null) {
      if (_isLoading) return;
      setState(() {
        _isLoading = true;
      });
      if (_selectedPaymentMethod!.name == cashOnDeliveryKey) {
        doOnSuccess();
      } else {
        if (_selectedPaymentMethod!.name == razorpayKey) {
          doPaymentWithRazorpay(orderID, finalTotal);
          return;
        }
        if (_selectedPaymentMethod!.name == stripeKey) {
          doPaymentWithStripe(orderID, finalTotal);
          return;
        }
        if (_selectedPaymentMethod!.name == paystackKey) {
          response = await TransactionRepository().doPaymentWithPayStack(
              price: finalTotal,
              orderID: orderID.toString(),
              context: context,
              paystackId: _selectedPaymentMethod!.paystackKeyId!);
          if (response['transactionId'] != null) {
         
          }
        }
        if (_selectedPaymentMethod!.name == paypalKey) {
          response = await TransactionRepository().doPaymentWithPaypal(
              price: finalTotal,
              orderID: orderID.toString(),
              type: 'order',
              context: context);
        }
        if (_selectedPaymentMethod!.name == phonepeKey) {
          response = await TransactionRepository().doPaymentWithPhonePe(
              context: context,
              price: finalTotal,
              environment: _selectedPaymentMethod!.phonepeMode!.toUpperCase(),
              appId: _selectedPaymentMethod!.phonepeSaltKey,
              merchantId: _selectedPaymentMethod!.phonepeMarchantId!,
              transactionType: defaultTransactionType,
              orderID: orderID.toString(),
              type: 'cart');
        }
        Utils.showSnackBar(message: response['message'], context: context);
        if (response['error'] == false) {
          doOnSuccess();

         
        } else if (response['error'] == true) {
          deleteOrder();
        }
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      Utils.showSnackBar(message: selectPaymentMethodKey, context: context);
    }
  }

  doPaymentWithRazorpay(int orderId, double finalTotal) async {
    String userContactNumber = context.read<UserDetailsCubit>().getUserMobile();
    String userEmail = context.read<UserDetailsCubit>().getUserEmail();

    try {
      var response = await TransactionRepository()
          .createRazorpayOrder(orderID: orderId.toString(), amount: finalTotal);
      if (response['error'] == false) {
        var razorpayOptions = {
          'key': _selectedPaymentMethod!.razorpayKeyId!,
          'amount': finalTotal.toString(),
          'name': context.read<UserDetailsCubit>().getUserName(),
          'order_id': response['data']['id'],
          'notes': {'order_id': orderId},
          'prefill': {
            'contact': userContactNumber,
            'email': userEmail,
          },
        };
        _razorpay = Razorpay();
        _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
        _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
        _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
        _razorpay!.open(razorpayOptions);
      }
    } catch (e) {
      Utils.showSnackBar(message: e.toString(), context: context);
    }
  }

  doPaymentWithStripe(int orderID, double finalTotal) async {
    var response = await StripeService.payWithPaymentSheet(
        amount: (finalTotal.round() * 100).toString(),
        currency: _selectedPaymentMethod!.stripeCurrencyCode!,
        from: 'order',
        awaitedOrderId: orderID.toString(),
        context: context);

    if (response.message == successTxnStatus) {
      doOnSuccess();
  
    } else if (response.status == pendingStatus ||
        response.status == capturedStatus) {
      doOnSuccess();
    } else {
      deleteOrder();
    }
  }

  updateOrder(String orderID, String status) async {
  
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    doOnSuccess();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isLoading = false;
    });
    Utils.showSnackBar(message: response.error.toString(), context: context);
    deleteOrder();

  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  void addTransaction(
      {String? transactionId,
      required int orderID,
      required double price,
      required String status}) {
    context.read<AddTransactionCubit>().addTransaction(
      params: {
        Api.userIdApiKey: context.read<UserDetailsCubit>().getUserId(),
        Api.orderIdApiKey: orderID,
        Api.transactionTypeApiKey: defaultTransactionType,
        Api.typeApiKey: _selectedPaymentMethod!.name == cashOnDeliveryKey
            ? 'cod'
            : _selectedPaymentMethod!.name!.toLowerCase(),
        Api.txnIdApiKey: transactionId,
        Api.amountApiKey: price.toString(),
        Api.statusApiKey: status,
        Api.messageApiKey: 'waiting for payment',
      },
    );
  }

  doOnSuccess() async {
    await CartRepository()
        .clearCart()
        .then((value) => context.read<GetUserCartCubit>().resetCart());

    Utils.navigateToScreen(context, Routes.orderConfirmedScreen,
        arguments: currentOrderID, replacePrevious: true);
  }

  void deleteOrder() {
    context
        .read<DeleteOrderCubit>()
        .deleteOrder(orderId: currentOrderID.toString(), context: context);
    currentOrderID = '';
  }

  void openBottomShhetForDigitalProduct() {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    TextEditingController _emailAddressController = TextEditingController();
    Utils.openModalBottomSheet(
        context,
        FilterContainerForBottomSheet(
            title: enterEmailKey,
            borderedButtonTitle: '',
            primaryButtonTitle: submitKey,
            borderedButtonOnTap: () {},
            primaryButtonOnTap: () {
              if (_formKey.currentState!.validate()) {
                context
                    .read<GetUserCartCubit>()
                    .addEmailAddress(_emailAddressController.text.trim());
                Future.delayed(const Duration(milliseconds: 500), () {
                  Navigator.of(context).pop();
                });
              } else {
                Utils.showSnackBar(
                    message: emptyValueErrorMessageKey, context: context);
              }
            },
            content: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomTextContainer(
                      textKey: enterEmailDescKey,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.67)),
                    ),
                    DesignConfig.defaultHeightSizedBox,
                    Form(
                      key: _formKey,
                      child: CustomTextFieldContainer(
                        hintTextKey: enterEmailKey,
                        textEditingController: _emailAddressController,
                        validator: (value) =>
                            Validator.validateEmail(context, value),
                      ),
                    )
                  ],
                ),
              ),
            )),
        isScrollControlled: true,
        staticContent: true);
  }
}
