import 'package:flutter/material.dart';

/// NOTE:
/// This extension is deprecated and will be removed in a future release.
/// Prefer using `context.colorScheme.*` directly instead of `context.color.*`.
//
// This extension now acts as a compatibility layer and simply delegates to
// `Theme.of(context).colorScheme`, replacing the previous brightness-based
// conditional color getters.
@Deprecated('Use Material\'s ColorScheme instead')
extension ColorPrefs on ColorScheme {
  Color get primaryColor => this.surface;

  Color get secondaryColor => this.secondary;

  Color get secondaryDetailsColor => secondaryColor;

  Color get territoryColor => this.primary;

  Color get deactivateColor => this.surface.withValues(alpha: .5);

  Color get forthColor => this.tertiary;

  Color get backgroundColor => this.surface;

  Color get buttonColor => this.onPrimary;

  Color get textColorDark => this.onSurface;

  Color get textDefaultColor => this.onSurface;

  Color get textLightColor => this.onSurface.withValues(alpha: .5);

  Color get borderColor => this.onSurface.withValues(alpha: .05);

  Color get inverseThemeColor => this.onSurface;

  Color get shimmerBaseColor => brightness == Brightness.light
      ? const Color.fromARGB(255, 225, 225, 225)
      : const Color.fromARGB(255, 150, 150, 150);

  Color get shimmerHighlightColor => brightness == Brightness.light
      ? Colors.grey.shade100
      : Colors.grey.shade300;

  Color get shimmerContentColor => brightness == Brightness.light
      ? Colors.white.withValues(alpha: 0.85)
      : Colors.white.withValues(alpha: 0.7);
}

extension TextThemeForFont on TextTheme {
  Font get font => Font();
}

class Font {
  ///10
  double get smaller => 10;

  ///12
  double get small => 12;

  ///14
  double get normal => 14;

  ///16
  double get large => 16;

  ///18
  double get larger => 18;

  ///24
  double get extraLarge => 24;

  ///28
  double get xxLarge => 28;
}
