import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/lottie_utility.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({this.size, this.color, super.key});

  final Size? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (Constant.useLottieProgress) {
      return Lottie.asset(
        LottieAssets.loading,
        width: size?.width ?? 70,
        height: size?.height ?? 70,
        delegates: LottieUtility.getLoadingIndicatorDelegates(
          color: color ?? context.colorScheme.primary,
        ),
      );
    } else {
      return CircularProgressIndicator(
        color: color ?? context.colorScheme.primary,
      );
    }
  }
}
