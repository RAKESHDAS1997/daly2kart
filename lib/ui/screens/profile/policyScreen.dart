import 'package:eshop_pro/ui/widgets/customAppbar.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

import '../../../utils/utils.dart';

class PolicyScreen extends StatelessWidget {
  final String title;
  final String content;

  static Widget getRouteInstance() {
    Map<String, dynamic> arguments = Get.arguments ?? {};
    return PolicyScreen(
      title: arguments['title'],
      content: arguments['content'],
    );
  }

  const PolicyScreen({Key? key, required this.title, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(titleKey: title),
      body: content.isNotEmpty
          ? SingleChildScrollView(
              padding:
                  const EdgeInsetsDirectional.all(appContentHorizontalPadding),
              child: HtmlWidget(
                content,
                onErrorBuilder: (context, element, error) =>
                    Text('$element error: $error'),
                onLoadingBuilder: (context, element, loadingProgress) =>
                    const Center(child: CircularProgressIndicator()),
                onTapUrl: (url) {
                  Utils.launchURL(url);
                  return true;
                },
              ),
            )
          : const Center(
              child: CustomTextContainer(textKey: dataNotAvailableKey)),
    );
  }
}
