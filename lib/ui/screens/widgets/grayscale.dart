import 'package:flutter/material.dart';

class Grayscale extends StatelessWidget {
  const Grayscale({super.key, required this.child, this.applyGrayScale = true});

  final Widget child;
  final bool applyGrayScale;

  @override
  Widget build(BuildContext context) {
    if (!applyGrayScale) {
      return child;
    }
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: child,
    );
  }
}
