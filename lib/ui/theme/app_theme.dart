import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:flutter/material.dart';

sealed class AppTheme {
  static ThemeData light = _build(ThemeMode.light);
  static ThemeData dark = _build(ThemeMode.dark);

  static ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: ThemeColors.primaryColor,
    primary: ThemeColors.primaryColor,
    onPrimary: ThemeColors.onPrimaryColor,
    secondary: ThemeColors.cardBackgroundColor,
    onSecondary: ThemeColors.lightTextColor,
    surface: ThemeColors.lightBackgroundColor,
    onSurface: ThemeColors.lightTextColor,
    tertiary: ThemeColors.accentColor,
    onTertiary: ThemeColors.onAccentColor,
    brightness: Brightness.light,
  );

  static ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: ThemeColors.darkPrimaryColor,
    primary: ThemeColors.darkPrimaryColor,
    onPrimary: ThemeColors.onDarkPrimaryColor,
    secondary: ThemeColors.darkCardBackgroundColor,
    onSecondary: ThemeColors.darkTextColor,
    surface: ThemeColors.darkBackgroundColor,
    onSurface: ThemeColors.darkTextColor,
    tertiary: ThemeColors.darkAccentColor,
    onTertiary: ThemeColors.onDarkAccentColor,
    brightness: Brightness.dark,
  );

  static ThemeData _build(ThemeMode mode) {
    final config = switch (mode) {
      ThemeMode.light => (
        scheme: _lightColorScheme,
        brightness: Brightness.light,
      ),
      ThemeMode.dark => (scheme: _darkColorScheme, brightness: Brightness.dark),
      ThemeMode.system => throw UnimplementedError(),
    };

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Manrope',
      colorScheme: config.scheme,
      brightness: config.brightness,
      dividerColor: config.brightness == Brightness.light
          ? ThemeColors.borderColor
          : ThemeColors.darkBorderColor,
      splashFactory: NoSplash.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: config.scheme.secondary,
        foregroundColor: config.scheme.onSurface,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: config.scheme.onSurface,
        ),
        actionsPadding: const EdgeInsetsDirectional.only(end: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: Size(double.maxFinite, 48),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          overlayColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: config.scheme.primary),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shadowColor: config.scheme.onSurface,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
      ),
      cardTheme: CardThemeData(
        color: config.scheme.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      tabBarTheme: TabBarThemeData(
        dividerHeight: 0,
        indicatorSize: TabBarIndicatorSize.tab,
        unselectedLabelColor: config.scheme.onSurface.withValues(alpha: .5),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: config.scheme.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: TextStyle(fontSize: 14, color: config.scheme.onSurface),
        subtitleTextStyle: TextStyle(
          fontSize: 12,
          color: config.scheme.onSurface.withValues(alpha: .5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: config.scheme.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: config.scheme.secondary,
        focusColor: config.scheme.primary,
        hintStyle: TextStyle(
          fontSize: 14,
          color: config.scheme.onSurface.withValues(alpha: .5),
        ),
        errorStyle: TextStyle(fontSize: 12, color: config.scheme.error),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: config.scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: config.scheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: config.scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: config.scheme.error),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: config.scheme.outlineVariant),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: config.scheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: config.scheme.primary,
        foregroundColor: config.scheme.onPrimary,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: config.scheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: config.scheme.outlineVariant),
        ),
        collapsedBackgroundColor: config.scheme.secondary,
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: config.scheme.outlineVariant),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: config.scheme.secondary,
        menuPadding: EdgeInsets.zero,
      ),
    );
  }
}
