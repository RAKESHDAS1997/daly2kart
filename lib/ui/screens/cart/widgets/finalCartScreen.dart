import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/cart/getUserCart.dart';
import 'package:eshop_pro/cubits/cart/manageCartCubit.dart';
import 'package:eshop_pro/cubits/cart/placeOrderCubit.dart';
import 'package:eshop_pro/cubits/cart/removeProductFromCartCubit.dart';
import 'package:eshop_pro/cubits/settingsAndLanguagesCubit.dart';
import 'package:eshop_pro/data/models/address.dart';
import 'package:eshop_pro/data/models/product.dart';
import 'package:eshop_pro/data/models/promoCode.dart';
import 'package:eshop_pro/ui/screens/cart/widgets/cartProductList.dart';
import 'package:eshop_pro/ui/screens/cart/widgets/priceDetailContainer.dart';
import 'package:eshop_pro/ui/widgets/customDefaultContainer.dart';
import 'package:eshop_pro/ui/widgets/customTextButton.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FinalCartScreen extends StatefulWidget {
  final Function(int)? onInstAdded;
  final PlaceOrderState placeOrderState;
  const FinalCartScreen(
      {Key? key, this.onInstAdded, required this.placeOrderState})
      : super(key: key);

  @override
  _FinalCartScreenState createState() => _FinalCartScreenState();
}

class _FinalCartScreenState extends State<FinalCartScreen> {
  late TextStyle bodyMedtextStyle;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bodyMedtextStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.8));
    return BlocProvider(
      create: (context) => RemoveFromCartCubit(),
      child: BlocListener<ManageCartCubit, ManageCartState>(
        listener: (context, state) {},
        child: BlocConsumer<GetUserCartCubit, GetUserCartState>(
          listener: (context, state) {
            //here we are checking if place order is  success or not, bcoz if its success we will move to order confirmed screen
            if (state is GetUserCartFetchSuccess &&
                widget.placeOrderState is! PlaceOrderSuccess) {
              if ((state.cart.cartProducts == null ||
                  state.cart.cartProducts!.isEmpty)) {
                Utils.showSnackBar(
                    message: emptyCartErrorMessageKey, context: context);
                Navigator.of(context).pop();
              }
            }
          },
          builder: (context, state) {
            if (state is GetUserCartFetchSuccess &&
                state.cart.cartProducts != null &&
                state.cart.cartProducts!.isNotEmpty) {
          
              return SingleChildScrollView(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
                child: Column(
                  children: <Widget>[
                    CartProductList(
                      cart: context.read<GetUserCartCubit>().getCartDetail(),
                      isFinalCartScreen: true,
                      removeFromCartCubit: context.read<RemoveFromCartCubit>(),
                    ),
                    DesignConfig.smallHeightSizedBox,
                    if (state.cart.cartProducts != null &&
                        state.cart.cartProducts!.isNotEmpty)
                      offerContainer(state.cart.promoCode),
                    if (state.cart.cartProducts![0].type != digitalProductType)
                      deliveryAddressContainer(),
                    // deliveryEstimateContainer(),
                    paymentModeContainer(),
                    PriceDetailContainer(
                        cart: context.read<GetUserCartCubit>().getCartDetail())
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  deliveryAddressContainer() {
    Address address =
        context.read<GetUserCartCubit>().getCartDetail().selectedAddress ??
            Address();
    return commonContainer(
        context,
        deliveryAddressKey,
        Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: appContentHorizontalPadding),
            child: Utils.getAddressWidget(context, address)),
        prefixIcon: const Icon(
          Icons.location_on_outlined,
        ),
        suffixIcon: CustomTextButton(
          onTapButton: () {
            widget.onInstAdded?.call(1);
          },
          buttonTextKey: changekey,
          textStyle: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: Theme.of(context).colorScheme.primary),
        ));
  }

  commonContainer(BuildContext context, String title, Widget content,
      {Widget? prefixIcon, Widget? suffixIcon}) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
            vertical: appContentVerticalSpace),
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: appContentHorizontalPadding),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon,
                    DesignConfig.smallWidthSizedBox
                  ],
                  Expanded(
                    child: CustomTextContainer(
                      textKey: title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (suffixIcon != null) suffixIcon,
                ],
              ),
            ),
            const Divider(
              height: 12,
              thickness: 0.5,
            ),
            content
          ],
        ),
      ),
    );
  }

  paymentModeContainer() {
    if (context
            .read<GetUserCartCubit>()
            .getCartDetail()
            .selectedPaymentMethod !=
        null) {
      return commonContainer(
          context,
          paymentModeKey,
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: appContentHorizontalPadding),
            child: GestureDetector(
              onTap: () => widget.onInstAdded?.call(2),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: CustomTextContainer(
                          textKey: context
                              .read<GetUserCartCubit>()
                              .getCartDetail()
                              .selectedPaymentMethod!
                              .name
                              .toString())),
                  const Icon(Icons.arrow_forward_ios)
                ],
              ),
            ),
          ));
    } else {
      return const SizedBox.shrink();
    }
  }

  deliveryEstimateContainer() {
    return commonContainer(
        context,
        deliveryEstimatesKey,
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: appContentHorizontalPadding),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: context
                      .read<SettingsAndLanguagesCubit>()
                      .getTranslatedValue(labelKey: estimatedDeliveryByKey),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.8)),
                ),
                const TextSpan(text: " "),
                TextSpan(
                    text: '2024',
                    style: Theme.of(context).textTheme.titleMedium!),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        prefixIcon: const Icon(
          Icons.delivery_dining_outlined,
        ));
  }

  offerContainer(PromoCode? promoCode) {
    return GestureDetector(
      onTap: () => Utils.navigateToScreen(context, Routes.promoCodeScreen,
          arguments: {'fromProductScreen': false, 'fromCartScreen': true}),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: CustomDefaultContainer(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: CustomTextContainer(
              textKey:
                  promoCode != null ? promoCode.promoCode! : addCouponCodeKey,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
            if (promoCode != null)
              IconButton(
                  visualDensity:
                      const VisualDensity(vertical: -4, horizontal: -4),
                  onPressed: () {
                    context.read<GetUserCartCubit>().removePromoCode();
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 24,
                  ))
            else
              const Icon(Icons.arrow_forward_ios, size: 24)
          ],
        )),
      ),
    );
  }
}
