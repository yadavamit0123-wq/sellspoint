import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:flutter/material.dart';

extension CustomContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  double get screenHeight => MediaQuery.sizeOf(this).height;

  //This one for colorScheme shortcut
  ColorScheme get color => Theme.of(this).colorScheme;

  //This one for fontSize
  ///I created different Font class to limit textTheme values, let's assume if some one is using context.font and he is getting too may options related to text theme so how will he know which one is for use??
  ///So in theme.dart file i have created Font class which will give limited numbers of getters
  Font get font => Theme.of(this).textTheme.font;

  Size sizeFromAspectRatio(double aspectRatio, {bool considerPadding = true}) {
    final width =
        screenWidth - (considerPadding ? Constant.horizontalPadding * 2 : 0);

    final height = width / aspectRatio;

    return Size(width, height);
  }
}
