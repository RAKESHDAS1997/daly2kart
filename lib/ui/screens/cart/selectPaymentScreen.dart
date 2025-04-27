import 'package:eshop_pro/cubits/cart/getUserCart.dart';
import 'package:eshop_pro/cubits/settingsAndLanguagesCubit.dart';
import 'package:eshop_pro/cubits/transaction/getPaymentMethodCubit.dart';
import 'package:eshop_pro/cubits/user_details_cubit.dart';
import 'package:eshop_pro/data/models/paymentMethod.dart';
import 'package:eshop_pro/ui/screens/profile/transaction/widgets/paymentMethodList.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/ui/widgets/error_screen.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class SelectPaymentScreen extends StatefulWidget {
  final PaymentModel selectedPaymentMethod;
  final PaymentMethodCubit paymentMethodCubit;
  const SelectPaymentScreen(
      {Key? key,
      required this.selectedPaymentMethod,
      required this.paymentMethodCubit})
      : super(key: key);

  @override
  _SelectPaymentScreenState createState() => _SelectPaymentScreenState();
}

class _SelectPaymentScreenState extends State<SelectPaymentScreen> {
  late Razorpay _razorpay;
  bool _isWalletPayment = false;
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      if (mounted) {
        context
            .read<UserDetailsCubit>()
            .fetchUserDetails(params: Utils.getParamsForVerifyUser(context));
        _isWalletPayment =
            context.read<GetUserCartCubit>().getCartDetail().useWalletBalance ??
                true;

        setState(() {});
      }
   
    });
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
  
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocConsumer<UserDetailsCubit, UserDetailsState>(
          listener: (context, state) {
       
      }, builder: (context, state) {
        if (state is UserDetailsFetchInProgress) {
          return Center(
              child: CustomCircularProgressIndicator(
                  indicatorColor: Theme.of(context).colorScheme.primary));
        }
        return Column(children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            margin: const EdgeInsetsDirectional.symmetric(
                vertical: 12, horizontal: appContentHorizontalPadding),
            padding: const EdgeInsetsDirectional.symmetric(
                vertical: appContentHorizontalPadding, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CustomTextContainer(
                  textKey: walletBalanceKey,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                DesignConfig.defaultHeightSizedBox,
                Material(
                  child: ListTile(
                      visualDensity:
                          const VisualDensity(horizontal: -4, vertical: -2),
                      tileColor: Theme.of(context).colorScheme.primaryContainer,
                      contentPadding:
                          const EdgeInsetsDirectional.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                          side: BorderSide(
                              color: Theme.of(context)
                                  .inputDecorationTheme
                                  .iconColor!)),
                      title: CustomTextContainer(
                          textKey:
                              '${context.read<SettingsAndLanguagesCubit>().getTranslatedValue(labelKey: availableBalanceKey)} : ${Utils.priceWithCurrencySymbol(price: context.read<UserDetailsCubit>().getuserDetails().balance ?? 0, context: context)}'),
                      leading: Radio(
                        groupValue: _isWalletPayment,
                        value: true,
                        onChanged: (value) => changeSelection(),
                      ),
                      onTap: changeSelection),
                )
              ],
            ),
          ),
          if (!(_isWalletPayment &&
              context.read<UserDetailsCubit>().getuserDetails().balance !=
                  null &&
              context.read<UserDetailsCubit>().getuserDetails().balance! >
                  (context
                          .read<GetUserCartCubit>()
                          .getCartDetail()
                          .originalOverallAmount ??
                      0.0)))
            BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
              builder: (context, state) {
                if (state is PaymentMethodFetchSuccess) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                        vertical: 8, horizontal: appContentHorizontalPadding),
                    child: PaymentMethodList(
                      paymentMethods: state.paymentMethods,
                      paymentMethodCubit: widget.paymentMethodCubit,
                    ),
                  );
                }
                if (state is PaymentMethodFetchFailure) {
                  return ErrorScreen(
                      text: state.errorMessage,
                      onPressed: () {
                        widget.paymentMethodCubit.fetchPaymentMethods();
                      });
                }
                if (state is PaymentMethodFetchInProgress) {
                  return CustomCircularProgressIndicator(
                      indicatorColor: Theme.of(context).colorScheme.primary);
                }
                return const SizedBox.shrink();
              },
            )
        ]);
      }),
    );
  }

  changeSelection() {
    if (context.read<UserDetailsCubit>().getuserDetails().balance! > 0) {
      setState(() {
        _isWalletPayment = !_isWalletPayment;

        context.read<GetUserCartCubit>().useWalletBalance(_isWalletPayment,
            context.read<UserDetailsCubit>().getuserDetails().balance ?? 0);
      });
   
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Utils.showSnackBar(message: 'Transaction Successful', context: context);
    Navigator.pop(context, response);
  
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Utils.showSnackBar(message: defaultErrorMessageKey, context: context);
    Navigator.pop(context, response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}
}
