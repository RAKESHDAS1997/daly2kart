import 'package:eshop_pro/cubits/transaction/getPaymentMethodCubit.dart';
import 'package:eshop_pro/data/models/paymentMethod.dart';
import 'package:eshop_pro/ui/widgets/customDefaultContainer.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';

class PaymentMethodList extends StatefulWidget {
  final List<PaymentModel> paymentMethods;
  final PaymentMethodCubit paymentMethodCubit;
  const PaymentMethodList(
      {super.key,
      required this.paymentMethods,
      required this.paymentMethodCubit});

  @override
  _PaymentMethodListState createState() => _PaymentMethodListState();
}

class _PaymentMethodListState extends State<PaymentMethodList> {
  late PaymentModel _selectedPaymentMethod;
  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = widget.paymentMethods
        .firstWhere((element) => element.isSelected == true);
  }

  @override
  Widget build(BuildContext context) {
    return CustomDefaultContainer(
        borderRadius: 8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CustomTextContainer(
              textKey: paymentMethodsKey,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            DesignConfig.defaultHeightSizedBox,
            ListView.separated(
              separatorBuilder: (context, index) =>
                  DesignConfig.smallHeightSizedBox,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.paymentMethods.length,
              itemBuilder: (context, index) {
                final paymentMethod = widget.paymentMethods[index];
                return buildPaymentMethodItem(
                  paymentMethod: paymentMethod,
                );
              },
            ),
          ],
        ));
  }

  Widget buildPaymentMethodItem({required PaymentModel paymentMethod}) {
    return Material(
      child: ListTile(
        visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
        tileColor: Theme.of(context).colorScheme.primaryContainer,
        contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(
                color: Theme.of(context).inputDecorationTheme.iconColor!)),
        title: CustomTextContainer(textKey: paymentMethod.name!),
        leading: Radio(
          groupValue: _selectedPaymentMethod.name,
          value: paymentMethod.name,
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = paymentMethod;
            });

            widget.paymentMethodCubit.setPaymentMethod(paymentMethod);
          },
        ),
        trailing: Utils.setSvgImage(
          paymentMethod.image!,
        ),
        onTap: () {
          setState(() {
            _selectedPaymentMethod = paymentMethod;
          });
          widget.paymentMethodCubit.setPaymentMethod(paymentMethod);
        },
      ),
    );
  }
}
