import 'package:eshop_pro/cubits/cart/manageCartCubit.dart';
import 'package:eshop_pro/cubits/storesCubit.dart';
import 'package:eshop_pro/data/models/cart.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuantitySelector extends StatefulWidget {
  final int initialQuantity;
  final int minimumOrderQuantity;
  final int maximumAllowedQuantity;
  final String stockType;
  final String stock;
  final int quantityStepSize;
  final CartProduct product;
  final bool primaryTheme;

  const QuantitySelector({
    Key? key,
    required this.initialQuantity,
    required this.minimumOrderQuantity,
    required this.maximumAllowedQuantity,
    required this.quantityStepSize,
    required this.stockType,
    required this.stock,
    required this.product,
    required this.primaryTheme,
  }) : super(key: key);

  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int _currentQuantity;

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.initialQuantity;
  }

  void _increaseQuantity() {
    if (widget.stockType != "" &&
        int.parse(widget.stock) < _currentQuantity + widget.quantityStepSize) {
      Utils.showSnackBar(context: context, message: stockLimitReachedKey);
      return;
    }
    if (widget.maximumAllowedQuantity == 0 ||
        _currentQuantity + widget.quantityStepSize <=
            widget.maximumAllowedQuantity) {
      setState(() {
        _currentQuantity += widget.quantityStepSize;
      });
      onQuantityChanged(_currentQuantity);
    } else {
      Utils.showSnackBar(context: context, message: maxQuantityReachedKey);
      return;
    }
  }

  void _decreaseQuantity() {
    if (_currentQuantity - widget.quantityStepSize >=
        widget.minimumOrderQuantity) {
      setState(() {
        _currentQuantity -= widget.quantityStepSize;
      });
      onQuantityChanged(_currentQuantity);
    } else {
      Utils.showSnackBar(context: context, message: minQuantityReachedKey);
      return;
    }
  }

  onQuantityChanged(int newQty) {
    context.read<ManageCartCubit>().manageUserCart(
        widget.product.cartProductType == 'combo'
            ? widget.product.id
            : widget.product.productVariantId,
        reloadCart: false,
        changeQuantity: true,
        params: {
          Api.storeIdApiKey: context.read<StoresCubit>().getDefaultStore().id,
          Api.productVariantIdApiKey: widget.product.cartProductType == 'combo'
              ? widget.product.id
              : widget.product.productVariantId,
          Api.productTypeApiKey:
              widget.product.cartProductType == 'combo' ? 'combo' : 'regular',
          Api.isSavedForLaterApiKey: 0,
          Api.qtyApiKey: newQty
        });
  }

  @override
  Widget build(BuildContext context) {
    Color fontColor = widget.primaryTheme
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.secondary;
    return Container(
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.primaryTheme
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(
            width: 0.5,
            color: widget.primaryTheme
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).inputDecorationTheme.iconColor!),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTapDown: (_) {
              _decreaseQuantity();
            },
            child: IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.remove,
                  color: _currentQuantity - widget.quantityStepSize >=
                          widget.minimumOrderQuantity
                      ? fontColor
                      : Colors.grey,
                ),
                onPressed: _decreaseQuantity),
          ),
          Text('$_currentQuantity',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: fontColor)),
          GestureDetector(
            onTapDown: (_) {
              _increaseQuantity();
            },
            child: IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.add,
                  color: widget.maximumAllowedQuantity == 0 ||
                          _currentQuantity + widget.quantityStepSize <=
                              widget.maximumAllowedQuantity
                      ? fontColor
                      : Colors.grey,
                ),
                onPressed: _increaseQuantity),
          ),
        ],
      ),
    );
  }
}
