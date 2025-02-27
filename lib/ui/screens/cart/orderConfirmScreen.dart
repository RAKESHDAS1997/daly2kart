import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/settingsAndLanguagesCubit.dart';
import 'package:eshop_pro/data/models/order.dart';
import 'package:eshop_pro/ui/screens/mainScreen.dart';
import 'package:eshop_pro/ui/widgets/customRoundedButton.dart';
import 'package:eshop_pro/ui/widgets/customTextButton.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class OrderConfirmScreen extends StatelessWidget {
  final String orderId;
  const OrderConfirmScreen({Key? key, required this.orderId}) : super(key: key);
  static Widget getRouteInstance() => OrderConfirmScreen(
        orderId: Get.arguments.toString(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.all(appContentHorizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Lottie.asset(Utils.getImagePath('order_confirmed.json'),
                  width: 200, height: 200, repeat: false),
              const SizedBox(
                height: 24,
              ),
              CustomTextContainer(
                  textKey: orderConfirmedKey,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Theme.of(context).colorScheme.primary)),
              DesignConfig.smallHeightSizedBox,
              CustomTextContainer(
                  textKey: yourOrderWillDeliveredSoonKey,
                  style: Theme.of(context).textTheme.bodyLarge),
              CustomTextContainer(
                  textKey:
                      '${context.read<SettingsAndLanguagesCubit>().getTranslatedValue(labelKey: orderIDKey)} : $orderId',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(
                height: 24,
              ),
              CustomRoundedButton(
                  widthPercentage: 1.0,
                  buttonTitle: trackYourOrderKey,
                  showBorder: false,
                  onTap: () =>
                      Utils.navigateToScreen(context, Routes.orderDetailsScreen,
                          arguments: {
                            'order': Order(id: int.parse(orderId)),
                           
                            'orderId': int.parse(orderId),
                          },
                          replacePrevious: true)),
              CustomTextButton(
                  buttonTextKey: backToHomeKey,
                  textStyle: Theme.of(context).textTheme.bodyLarge,
                  onTapButton: () {
                    MainScreen.mainScreenKey.currentState
                        ?.changeCurrentIndex(0);
                    Get.until(
                      (route) => route.settings.name == Routes.mainScreen,
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
