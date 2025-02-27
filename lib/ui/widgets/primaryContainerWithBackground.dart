import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class PrimaryContainerWithBackground extends StatelessWidget {
  final Widget child;
  const PrimaryContainerWithBackground({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(appContentHorizontalPadding),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Container(

        decoration: ShapeDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Stack(
            clipBehavior: Clip.none,
            textDirection: Directionality.of(context),
            children: [
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 67,
                  height: 62,
                  decoration: ShapeDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomLeft: Radius.circular(250),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 67,
                  height: 62,
                  decoration: ShapeDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(250),
                        bottomLeft: Radius.circular(borderRadius),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                      vertical: appContentHorizontalPadding),
                  child: child)
            ]),
      ),
    );
  }
}
