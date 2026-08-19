import 'package:flutter/material.dart';

class ThemeColors {
  // Light Mode Colors
  static const primaryColor = Color(0xff00B2CA);
  static const onPrimaryColor = Color(0xffFFFFFF);
  static const lightBackgroundColor = Color(0xffF6F5FA);
  static const lightTextColor = Color(0xff000000);
  static const accentColor = Color(0xffFA6353);
  static const onAccentColor = Color(0xffFFFFFF);
  static const cardBackgroundColor = Color(0xffFFFFFF);
  static const borderColor = Color(0xffDAD9D9);

  // Dark Mode Colors
  static const darkPrimaryColor = Color(0xff00B2CA);
  static const onDarkPrimaryColor = Color(0xffFFFFFF);
  static const darkBackgroundColor = Color(0xff121212);
  static const darkTextColor = Color(0xffFDFDFD);
  static const darkAccentColor = Color(0xffFA6353);
  static const onDarkAccentColor = Color(0xffFFFFFF);
  static const darkCardBackgroundColor = Color(0xff1C1C1C);
  static const darkBorderColor = Color(0xff444444);
}

class StatusColors {
  // Messages Color
  static const Color errorMessageColor = Color(0xffEA0707);
  static const Color successMessageColor = Color(0xff00B45F);
  static const Color warningMessageColor = Color(0xFFFB9D22);

  // Status Colors
  static const Color pendingButtonColor = Color(0xff0C5D9C);
  static const Color soldOutButtonColor = Color(0xffFFBB33);
  static const Color deactivateButtonColor = Color(0xffFE0000);
  static const Color activateButtonColor = Color(0xFF02AD11);
}

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  Color get mutedColor => theme.colorScheme.onSurface.withValues(alpha: .5);
}
