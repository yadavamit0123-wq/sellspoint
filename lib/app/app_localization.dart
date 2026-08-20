import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalization {
  AppLocalization(this.locale);

  final Locale locale;

  static Map<String, String> _localizedValues = {};
  static Map<String, String> _bundledValues = {};

  static AppLocalization? of(BuildContext context) {
    return Localizations.of(context, AppLocalization);
  }

  /// API translations override bundled keys; bundled fills any keys missing
  /// from admin language files (e.g. jobApplications, myWallet).
  static Future<void> setTranslations(Map<String, dynamic> json) async {
    await ensureBundledLoaded();
    final apiValues = json.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    _localizedValues = {..._bundledValues, ...apiValues};
  }

  static Future<void> ensureBundledLoaded() async {
    if (_bundledValues.isNotEmpty) return;
    await AppLocalization(const Locale('en')).loadJson();
  }

  Future<void> loadJson() async {
    if (_bundledValues.isNotEmpty) return;

    final jsonStringValues = await rootBundle.loadString(
      'assets/languages/language.json',
    );
    final mappedJson = json.decode(jsonStringValues) as Map<String, dynamic>;
    _bundledValues = mappedJson.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    if (_localizedValues.isEmpty) {
      _localizedValues = Map<String, String>.from(_bundledValues);
    }
  }

  String? getTranslatedValues(String? key) {
    return _localizedValues[key!];
  }

  static const LocalizationsDelegate<AppLocalization> delegate =
      _AppLocalizationDelegate();
}

class _AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const _AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return true;
  }

  @override
  Future<AppLocalization> load(Locale locale) async {
    final localization = AppLocalization(locale);
    await localization.loadJson();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalization> old) {
    return true;
  }
}
