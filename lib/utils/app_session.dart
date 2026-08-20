import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/model/core/language.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';

/// Holds mutable, session-scoped data used throughout the app.
///
/// This class represents the current app session and should only contain
/// data that is expected to change during a single run of the app.
///
/// For non-session data, see constants.dart.
///
/// Initialized with default values and expected to change during the app's lifecycle.
abstract class AppSession {
  /// To initialize session based values during the app booting time and ensure
  /// we have valid data to be used before accessing any of the data
  static void create() {
    _currentLocation = HiveUtils.getLocation();
    _currentTheme = HiveUtils.getCurrentTheme();
    _currentLanguage = HiveUtils.getLanguage();
  }

  static void clear() {
    _currentLocation = AppConfig.defaultLocation;
    activeChatId = null;
  }

  /// Current open chat session ID
  static int? activeChatId;

  /// Current selected location
  static LeafLocation? _currentLocation;

  static LeafLocation? get currentLocation => _currentLocation;

  static void setCurrentLocation(LeafLocation? location) {
    _currentLocation = location;
  }

  /// Current active language.
  static Language? _currentLanguage;

  static Language? get currentLanguage => _currentLanguage;

  static String get currentLanguageCode =>
      _currentLanguage?.languageCode ?? 'en';

  static String get currentLocale =>
      _currentLanguage != null ? _currentLanguage!.locale : 'en_US';

  static void setCurrentLanguage(Language? language) {
    _currentLanguage = language;
  }

  /// Current theme of app
  static ThemeMode _currentTheme = ThemeMode.light;

  static bool get isDarkMode => _currentTheme == ThemeMode.dark;

  static void setCurrentTheme(ThemeMode theme) {
    _currentTheme = theme;
  }
}
