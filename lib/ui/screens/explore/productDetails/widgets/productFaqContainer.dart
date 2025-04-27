import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/faq/faqCubit.dart';
import 'package:eshop_pro/data/models/product.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/widgets/productFaqWidget.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductFaqContainer extends StatefulWidget {
  final Product product;

  const ProductFaqContainer({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductFaqContainer> createState() => _ProductFaqContainerState();
}

class _ProductFaqContainerState extends State<ProductFaqContainer> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      getProductFaqs();
    });
  }

  getProductFaqs() {
    context.read<FAQCubit>().getFAQ(params: {
      Api.productIdApiKey: widget.product.id,
      Api.productTypeApiKey:
          widget.product.type == comboProductType ? "combo" : "regular",
      Api.limitApiKey: 3
    }, api: Api.getProductFaqs);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FAQCubit, FAQState>(builder: (context, state) {
      return Column(
        children: [
          state is FAQFetchSuccess
              ? Column(
                  children: [
                    DesignConfig.smallHeightSizedBox,
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                          vertical: appContentHorizontalPadding),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: appContentHorizontalPadding),
                              child: CustomTextContainer(
                                textKey: questionsAndAnswersKey,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            DesignConfig.defaultHeightSizedBox,
                            ListView.separated(
                                separatorBuilder: (context, index) => Container(
                                    margin:
                                        const EdgeInsetsDirectional.symmetric(
                                            vertical:
                                                appContentHorizontalPadding),
                                    height: 1,
                                    color: Theme.of(context)
                                        .inputDecorationTheme
                                        .iconColor),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.faqs.length,
                                itemBuilder: (context, index) {
                                  return ProductFaqWidget(
                                      faq: state.faqs[index]);
                                })
                          ]),
                    ),
                  ],
                )
              : const SizedBox(
                  height: 4,
                ),
          Column(
            children: [
              Container(
                height: 4,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                ),
              ),
              GestureDetector(
                onTap: () => Utils.navigateToScreen(
                    context, Routes.allFaqListScreen,
                    arguments: {'product': widget.product}),
                child: Container(
                  padding: const EdgeInsetsDirectional.all(
                      appContentHorizontalPadding),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4)),
                      color: Theme.of(context).colorScheme.primaryContainer),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextContainer(
                        textKey: state is FAQFetchFailure
                            ? postYourQuestionKey
                            : seeAllQuestionsKey,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: 20,
                          color: Theme.of(context).colorScheme.secondary)
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      );
    });
  }
}
