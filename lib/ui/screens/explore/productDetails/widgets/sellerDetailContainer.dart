import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/settingsAndLanguagesCubit.dart';
import 'package:eshop_pro/data/models/product.dart';
import 'package:eshop_pro/ui/widgets/customDefaultContainer.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/utils.dart';

class SellerDetailContainer extends StatelessWidget {
  final Product product;
  const SellerDetailContainer({Key? key, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Utils.navigateToScreen(
        context,
        Routes.sellerDetailScreen,
        arguments: {
          'sellerId': product.sellerId,
        },
      ),
      child: CustomDefaultContainer(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text.rich(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
              TextSpan(
                children: [
                  TextSpan(
                    text: context
                        .read<SettingsAndLanguagesCubit>()
                        .getTranslatedValue(labelKey: sellerDetailsKey),
                  ),
                  const TextSpan(text: ' : '),
                  TextSpan(
                    text: product.storeName != null &&
                            product.storeName!.isNotEmpty
                        ? product.storeName.toString().capitalizeFirst
                        : product.sellerName.toString().capitalizeFirst,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                  )
                ],
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 24)
        ],
      )),
    );
  }
}
