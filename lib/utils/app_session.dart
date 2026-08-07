import 'package:eClassify/app/app_theme.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';

/// Session-scoped state for the 2.14 merge (live Hive/language compatible).
abstract class AppSession {
  static void create() {
    _language = HiveUtils.getLanguage();
    _theme = HiveUtils.getCurrentTheme();
  }

  static void clear() {
    activeChatId = null;
    _language = HiveUtils.getLanguage();
    _currentLocation = null;
  }

  static LeafLocation? _currentLocation;

  static LeafLocation? get currentLocation => _currentLocation;

  static void setCurrentLocation(LeafLocation location) {
    _currentLocation = location;
  }

  static int? activeChatId;

  static dynamic _language;

  static String get currentLanguageCode {
    final lang = _language ?? HiveUtils.getLanguage();
    if (lang is Map && lang['code'] != null) {
      return lang['code'].toString();
    }
    return 'en';
  }

  static void refreshLanguage() {
    _language = HiveUtils.getLanguage();
  }

  static AppTheme _theme = AppTheme.light;

  static AppTheme get currentAppTheme => _theme;

  static bool get isDarkMode => _theme == AppTheme.dark;

  static void setCurrentTheme(AppTheme theme) {
    _theme = theme;
  }
}
