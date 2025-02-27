import 'package:flutter/material.dart';

class CustomBottomButtonContainer extends StatelessWidget {
  final Widget child;
  const CustomBottomButtonContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding:
            const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 4,
              offset: const Offset(0, -2),
              spreadRadius: 0,
            )
          ],
        ),
        child: child);
  }
}
