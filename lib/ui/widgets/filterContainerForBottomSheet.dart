import 'package:eshop_pro/ui/widgets/customRoundedButton.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../utils/designConfig.dart';
import 'customBottomButtonContainer.dart';
import 'customTextContainer.dart';

class FilterContainerForBottomSheet extends StatelessWidget {
  final String title;

  final String borderedButtonTitle;
  final String primaryButtonTitle;
  final Widget? primaryChild;
  final VoidCallback borderedButtonOnTap;
  final VoidCallback primaryButtonOnTap;
  final Widget content;
  const FilterContainerForBottomSheet({
    super.key,
    required this.title,
    required this.borderedButtonTitle,
    required this.primaryButtonTitle,
    this.primaryChild,
    required this.borderedButtonOnTap,
    required this.primaryButtonOnTap,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext buildcontext, StateSetter setState) {
      return SingleChildScrollView(
        padding: EdgeInsetsDirectional.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: appContentVerticalSpace,
                  vertical: appContentVerticalSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DesignConfig.defaultHeightSizedBox,
                  if (title.isNotEmpty)
                    CustomTextContainer(
                      textKey: title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  DesignConfig.defaultHeightSizedBox,
                  content,
                  DesignConfig.defaultHeightSizedBox,
                ],
              ),
            ),
            buildFilterButtons(context),
          ],
        ),
      );
    });
  }

  Widget buildFilterButtons(BuildContext context) {
    return CustomBottomButtonContainer(
      child: borderedButtonTitle != ''
          ? Row(
              children: [
                Expanded(
                  child: CustomRoundedButton(
                      widthPercentage: 0.4,
                      buttonTitle: borderedButtonTitle,
                      showBorder: true,
                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                      borderColor: Theme.of(context).hintColor,
                      style: const TextStyle().copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onTap: borderedButtonOnTap),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: CustomRoundedButton(
                    widthPercentage: 0.4,
                    buttonTitle: primaryButtonTitle,
                    showBorder: false,
                    onTap: primaryButtonOnTap,
                    child: primaryChild,
                  ),
                )
              ],
            )
          : primaryChild ??
              CustomRoundedButton(
                widthPercentage: 1,
                buttonTitle: primaryButtonTitle,
                showBorder: false,
                onTap: primaryButtonOnTap,
                child: primaryChild,
              ),
    );
  }
}
