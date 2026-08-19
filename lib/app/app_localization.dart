

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalization {
  final Locale locale;
  static Map<String, String> _localizedValues = {};

  AppLocalization(this.locale);

  static AppLocalization? of(BuildContext context) {
    return Localizations.of(context, AppLocalization);
  }

  static void setTranslations(Map<String, dynamic> json) {
    _localizedValues = json.map((key, value) => MapEntry(key, value.toString()));
  }

  Future loadJson() async {
    if (_localizedValues.isEmpty) {
      String jsonStringValues =
          await rootBundle.loadString('assets/languages/language.json');
      Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
      _localizedValues =
          mappedJson.map((key, value) => MapEntry(key, value.toString()));
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
    AppLocalization localization = AppLocalization(locale);
    await localization.loadJson();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalization> old) {
    return true;
  }
}
