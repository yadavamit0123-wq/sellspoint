import 'dart:ui';

import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:flutter/material.dart';

/// Shows the full image inside a fixed box with a blurred background fill.
class ContainedBlurImage extends StatelessWidget {
  const ContainedBlurImage({
    required this.src,
    this.size,
    this.radius = 0,
    this.adaptive = false,
    this.blurSigma = 18,
    super.key,
  });

  final String? src;
  final Size? size;
  final double radius;
  final bool adaptive;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    if (src == null || src!.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CustomImage(src: src, size: size, radius: radius, adaptive: adaptive),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size?.width,
        height: size?.height,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: blurSigma,
                sigmaY: blurSigma,
              ),
              child: CustomImage(
                src: src,
                size: size,
                fit: BoxFit.cover,
                adaptive: adaptive,
              ),
            ),
            CustomImage(
              src: src,
              size: size,
              fit: BoxFit.contain,
              adaptive: adaptive,
            ),
          ],
        ),
      ),
    );
  }
}
