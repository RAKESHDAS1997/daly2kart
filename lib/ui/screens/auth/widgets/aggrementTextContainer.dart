import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/routes.dart';
import '../../../../cubits/settingsAndLanguagesCubit.dart';
import '../../../../utils/labelKeys.dart';

class AggrementTextContainer extends StatelessWidget {
  final bool isChecked;
  final Function(bool?)? onChanged;
  const AggrementTextContainer(
      {Key? key, required this.isChecked, required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsAndLanguagesCubit>().getSettings();
    return Row(
      children: <Widget>[
        Checkbox(
            value: isChecked,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: onChanged),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                    text:
                        '${context.read<SettingsAndLanguagesCubit>().getTranslatedValue(labelKey: byContinuingYouAgreeToOurKey)} ',
                    style: Theme.of(context).textTheme.bodyMedium),
                TextSpan(
                    text: context
                        .read<SettingsAndLanguagesCubit>()
                        .getTranslatedValue(labelKey: termsOfServicesKey),
                    style: Theme.of(context).textTheme.titleSmall,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Utils.navigateToScreen(
                              context, Routes.policyScreen, arguments: {
                            'title': termsAndConditionKey,
                            'content': settings.termsAndConditions
                          })),
                TextSpan(
                    text:
                        ' ${context.read<SettingsAndLanguagesCubit>().getTranslatedValue(labelKey: andKey)} ',
                    style: Theme.of(context).textTheme.bodyMedium),
                TextSpan(
                    text: context
                        .read<SettingsAndLanguagesCubit>()
                        .getTranslatedValue(labelKey: privacyPolicyKey),
                    style: Theme.of(context).textTheme.titleSmall,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Utils.navigateToScreen(
                              context, Routes.policyScreen, arguments: {
                            'title': privacyPolicyKey,
                            'content': settings.privacyPolicy
                          }))
              ],
            ),
          ),
        ),
      ],
    );
  }
}
