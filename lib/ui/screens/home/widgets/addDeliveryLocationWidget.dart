import 'package:eshop_pro/cubits/product/mostSellingProductCubit.dart';
import 'package:eshop_pro/cubits/user_details_cubit.dart';
import 'package:eshop_pro/ui/screens/mainScreen.dart';
import 'package:eshop_pro/utils/validator.dart';
import 'package:flutter/material.dart';

import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/ui/widgets/customTextFieldContainer.dart';
import 'package:eshop_pro/ui/widgets/filterContainerForBottomSheet.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/sectionCubit.dart';
import '../../../../cubits/storesCubit.dart';
import '../../../../utils/utils.dart';

class AddDeliveryLocationWidget extends StatefulWidget {
  const AddDeliveryLocationWidget({Key? key}) : super(key: key);

  @override
  _AddDeliveryLocationWidgetState createState() =>
      _AddDeliveryLocationWidgetState();
}

class _AddDeliveryLocationWidgetState extends State<AddDeliveryLocationWidget> {
  TextEditingController _zipcodeController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _zipcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
    
        Utils.openModalBottomSheet(
            context,
            FilterContainerForBottomSheet(
                title: selectDeliveryLocKey,
                borderedButtonTitle: '',
                primaryButtonTitle: submitKey,
                borderedButtonOnTap: () {},
                primaryButtonOnTap: () {
                  if (_formKey.currentState!.validate()) {
                    zipcode = _zipcodeController.text.trim();
                    setState(() {});
                    updateProducts();
                    Future.delayed(const Duration(milliseconds: 500), () {
                      Navigator.of(context).pop();
                    });
                  } else {
                    Utils.showSnackBar(
                        message: emptyValueErrorMessageKey, context: context);
                  }
                },
                content: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CustomTextContainer(
                          textKey: selectDeliveryLocDescKey,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.67)),
                        ),
                        DesignConfig.defaultHeightSizedBox,
                        Form(
                          key: _formKey,
                          child: CustomTextFieldContainer(
                            hintTextKey: typeDeliveryPincodeKey,
                            focusNode: _focusNode,
                            autofocus: true,
                            textEditingController: _zipcodeController,
                            validator: (value) =>
                                Validator.emptyValueValidation(context, value),
                            prefixWidget:
                                const Icon(Icons.location_on_outlined),
                            suffixWidget: IconButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  _zipcodeController.clear();
                                  zipcode = null;
                                  setState(() {});
                                  updateProducts();
                                  Future.delayed(
                                      const Duration(milliseconds: 500), () {
                                    Navigator.of(context).pop();
                                  });
                                },
                                icon: Icon(
                                  Icons.close,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                )),
                          ),
                        )
                      ],
                    ),
                  ),
                )),
            isScrollControlled: true,
            staticContent: true);
      },
      child: Container(
        padding: const EdgeInsetsDirectional.all(appContentHorizontalPadding),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.location_on_outlined),
            const SizedBox(
              width: 8,
            ),
            CustomTextContainer(
              textKey:
                  zipcode != null ? 'Deliver to $zipcode' : addDeliveryLocKey,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const Spacer(),
            const Icon(Icons.keyboard_double_arrow_right)
          ],
        ),
      ),
    );
  }

  updateProducts() {
    MainScreen.mainScreenKey.currentState!.refreshProducts(onlyExplore: true);
    context.read<FeaturedSectionCubit>().getSections(
        storeId: context.read<StoresCubit>().getDefaultStore().id!,
        zipcode: _zipcodeController.text.trim());
    context.read<MostSellingProductsCubit>().getMostSellingProducts(
        storeId: context.read<StoresCubit>().getDefaultStore().id!,
        userId: context.read<UserDetailsCubit>().getUserId(),
        zipcode: _zipcodeController.text.trim());
  }
}
