import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/ui/widgets/customDefaultContainer.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';

class OfferContainer extends StatelessWidget {
  final String title;
  final bool isFromCartScreen;
  const OfferContainer(
      {Key? key, required this.title, this.isFromCartScreen = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Utils.navigateToScreen(context, Routes.promoCodeScreen,
          arguments: {
            'fromProductScreen': !isFromCartScreen,
            'fromCartScreen': isFromCartScreen
          }),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: CustomDefaultContainer(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: CustomTextContainer(
              textKey: title,
              style: Theme.of(context).textTheme.titleMedium,
            )),
            const Icon(Icons.arrow_forward_ios, size: 24)
          ],
        )),
      ),
    );
  }
}
