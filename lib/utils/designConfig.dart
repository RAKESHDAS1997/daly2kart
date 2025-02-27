import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DesignConfig {
  static get appShadow => const [
        BoxShadow(
          color: Color(0x1E000000),
          blurRadius: 4,
          offset: Offset(0, 1),
          spreadRadius: 0,
        )
      ];
  static get defaultHeightSizedBox => const SizedBox(
        height: 16,
      );
  static get defaultWidthSizedBox => const SizedBox(
        width: 16,
      );
  static get smallHeightSizedBox => const SizedBox(
        height: 8,
      );
  static get smallWidthSizedBox => const SizedBox(
        width: 8,
      );
  static shimmerEffect(double height, double width) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
}
