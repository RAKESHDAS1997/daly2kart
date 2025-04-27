import 'package:eshop_pro/cubits/settingsAndLanguagesCubit.dart';
import 'package:eshop_pro/data/models/product.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/ui/widgets/customDefaultContainer.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailsContainer extends StatefulWidget {
  final Product product;
  const ProductDetailsContainer({Key? key, required this.product})
      : super(key: key);

  @override
  _ProductDetailsContainerState createState() =>
      _ProductDetailsContainerState();
}

class _ProductDetailsContainerState extends State<ProductDetailsContainer>
    with SingleTickerProviderStateMixin {
  bool _isExpand = false;
  late AnimationController _expandController;
  late Animation<double> _animation;
  late TextStyle textStyle;
  late Product product;
  void _toggleExpanded() {
    _isExpand = !_isExpand;
   
    if (_isExpand) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    product = widget.product;

    _expandController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animation = CurvedAnimation(
      parent: _expandController,
      curve: const Interval(
        0.0,
        0.4,
        curve: Curves.fastOutSlowIn,
      ),
    );
  }

  @override
  void dispose() {
    _expandController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    textStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
        overflow: TextOverflow.visible);
    return CustomDefaultContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextContainer(
                  textKey: productsDetailsKey,
                  style: Theme.of(context).textTheme.titleMedium),
   
              GestureDetector(
                onTap: _toggleExpanded,
                child: CustomTextContainer(
                    textKey: _isExpand ? "- Less" : "+ More",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.primary)),
              ),
            ],
          ),
          DesignConfig.defaultHeightSizedBox,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildListTile(nameKey, product.name ?? ''),
              buildDescritpion(product.description ?? '', textStyle),
              SizeTransition(
                axisAlignment: 1.0,
                sizeFactor: _animation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    buildDescritpion(product.shortDescription ?? '', textStyle),
                    if (product.productType == variableProductType)
                      ...product.attributes!
                          .map((variant) => buildListTile(
                              context
                                  .read<SettingsAndLanguagesCubit>()
                                  .getTranslatedValue(
                                      labelKey: variant.attrName ?? ''),
                              variant.value ?? ''))
                          .toList(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildListTile(
                            product.isCancelable == 1
                                ? cancellableTillKey
                                : cancellableKey,
                            product.isCancelable == 1
                                ? product.cancelableTill!
                                : noKey),
                        buildListTile(returnableKey,
                            product.isReturnable == 1 ? returnableKey : noKey),
                        buildListTile(
                            warrantyKey,
                            product.warrantyPeriod != null &&
                                    product.warrantyPeriod!.isNotEmpty
                                ? product.warrantyPeriod ?? ''
                                : '-'),
                        buildListTile(
                            guaranteeKey,
                            product.guaranteePeriod != null &&
                                    product.guaranteePeriod!.isNotEmpty
                                ? product.guaranteePeriod ?? ''
                                : '-'),
                        if (product.indicator != null &&
                            product.indicator != '0' &&
                            product.indicator != '')
                          buildListTile(ingredientTypeKey,
                              product.indicator == '1' ? vegKey : nonVegKey),
                        buildListTile(countryOfOriginKey, product.madeIn ?? '-')
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  buildListTile(String title, String value) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
      child: Text.rich(
        TextSpan(
          style: textStyle,
          children: [
            TextSpan(
              text:
                  context.read<SettingsAndLanguagesCubit>().getTranslatedValue(
                        labelKey: title,
                      ),
            ),
            const TextSpan(
              text: ' : ',
            ),
            TextSpan(
              text:
                  context.read<SettingsAndLanguagesCubit>().getTranslatedValue(
                        labelKey: value,
                      ),
            ),
          ],
        ),
      ),
    );
  }

  buildDescritpion(String description, TextStyle textStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: HtmlWidget(
          description,
          textStyle: textStyle,
          onTapUrl: (String? url) async {
            if (await canLaunchUrl(Uri.parse(url!))) {
              await launchUrl(Uri.parse(url));
              return true;
            } else {
              throw 'Could not launch $url';
            }
          },
          onErrorBuilder: (context, element, error) =>
              Text('$element error: $error'),
          onLoadingBuilder: (context, element, loadingProgress) =>
              CustomCircularProgressIndicator(
            indicatorColor: Theme.of(context).colorScheme.primary,
          ),
          renderMode: RenderMode.column,
        ),
      ),
    );
  }
}
