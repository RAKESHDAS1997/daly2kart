import 'package:eshop_pro/cubits/settingsAndLanguagesCubit.dart';
import 'package:eshop_pro/data/models/promoCode.dart';
import 'package:eshop_pro/ui/styles/colors.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShowPromocodeDialog extends StatelessWidget {
  final PromoCode promoCode;

  const ShowPromocodeDialog({Key? key, required this.promoCode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width *
            0.95, // Set dialog width to 80% of the screen width
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
  
            Positioned(
              top: -120,
              child: Image.asset(
                Utils.getImagePath(
                  'valid_promocode.png',
                ),
                width: 180,
                height: 180,
              ),
            ),
            Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              const SizedBox(
                height: 60,
              ),
              // Promo Code Text
              CustomTextContainer(
                  textKey:
                      '${promoCode.promoCode} ${context.read<SettingsAndLanguagesCubit>().getTranslatedValue(labelKey: appliedKey)}',
                  style: Theme.of(context).textTheme.titleMedium!),
              DesignConfig.smallHeightSizedBox,
              // Discount Amount
              CustomTextContainer(
                  textKey:
                      '${context.read<SettingsAndLanguagesCubit>().getTranslatedValue(labelKey: youSavedKey)} \$${promoCode.finalDiscount}',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      )),
              const SizedBox(
                height: 12,
              ),
     
              CustomTextContainer(
                  textKey: withThisCouponCodeKey,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.8),
                      )),
              if (promoCode.isCashback == 1) ...[
                const SizedBox(
                  height: 12,
                ),
       
                CustomTextContainer(
                    textKey: cashbackWarningKey,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: successStatusColor)),
              ],
            ])
          ],
        ),
      ),
    );
  }
}
