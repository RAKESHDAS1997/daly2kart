import 'package:eshop_pro/cubits/settingsAndLanguagesCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomTextContainer extends StatelessWidget {
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final String textKey;
  final TextOverflow? overflow;

  const CustomTextContainer(
      {super.key,
      required this.textKey,
      this.maxLines,
      this.style,
      this.textAlign,
      this.overflow});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsAndLanguagesCubit, SettingsAndLanguagesState>(
      builder: (context, state) {
        return Text(
          context
              .read<SettingsAndLanguagesCubit>()
              .getTranslatedValue(labelKey: textKey),
          style: style,
          maxLines: maxLines,
          overflow: overflow,
          textAlign: textAlign,
          textDirection: Directionality.of(context),
          softWrap: true,
        );
      },
    );
  }
}
