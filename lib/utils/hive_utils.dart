import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/model/core/language.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/data/model/user/user_model.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/hive_keys.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HiveUtils {
  ///private constructor
  HiveUtils._();

  static String getJWT() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.jwtToken);
  }

  static void setJWT(String token) async {
    await Hive.box(HiveKeys.userDetailsBox).put(HiveKeys.jwtToken, token);
  }

  static bool isUserAuthenticated() {
    return Hive.box(HiveKeys.authBox).get(HiveKeys.isAuthenticated) ?? false;
  }

  static void setUserIsAuthenticated(bool value) {
    Hive.box(HiveKeys.authBox).put(HiveKeys.isAuthenticated, value);
  }

  static Future<void> setUserIsNotNew() {
    return Hive.box(HiveKeys.authBox).put(HiveKeys.isUserFirstTime, false);
  }

  static bool isUserFirstTime() {
    return Hive.box(HiveKeys.authBox).get(HiveKeys.isUserFirstTime) ?? true;
  }

  static bool isUserSkip() {
    return Hive.box(HiveKeys.authBox).get(HiveKeys.isUserSkip) ?? false;
  }

  static Future<void> setUserSkip() {
    return Hive.box(HiveKeys.authBox).put(HiveKeys.isUserSkip, true);
  }

  static String? getUserId() {
    return Hive.box(HiveKeys.userDetailsBox).get("id").toString();
  }

  static UserModel getUserDetails() {
    return UserModel.fromJson(
      Map.from(Hive.box(HiveKeys.userDetailsBox).toMap()),
    );
  }

  static void setUserData(Map data) async {
    await Hive.box(HiveKeys.userDetailsBox).putAll(data);
  }

  static void setProfileNotCompleted() async {
    await Hive.box(
      HiveKeys.userDetailsBox,
    ).put(HiveKeys.isProfileCompleted, false);
  }

  static ThemeMode getCurrentTheme() {
    var current = Hive.box(HiveKeys.themeBox).get(HiveKeys.currentTheme);

    return current == "dark" ? ThemeMode.dark : ThemeMode.light;
  }

  static void setCurrentTheme(ThemeMode theme) {
    String newTheme = theme == ThemeMode.light ? "light" : "dark";

    Hive.box(HiveKeys.themeBox).put(HiveKeys.currentTheme, newTheme);
  }

  static LeafLocation? getLocation() {
    final json =
        (Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.locationKey) as Map?)
            ?.cast<String, dynamic>();

    return json != null ? LeafLocation.fromJson(json) : null;
  }

  static void setLocation({required LeafLocation location}) {
    final effectiveLocation = Constant.isDemoModeOn
        ? AppConfig.defaultLocation
        : location;
    Hive.box(
      HiveKeys.userDetailsBox,
    ).put(HiveKeys.locationKey, effectiveLocation.toJson());
  }

  static Language? getLanguage() {
    try {
      final stored = Hive.box(HiveKeys.languageBox).get(HiveKeys.currentLanguageKey);
      if (stored == null) return null;
      return Language.fromJson(Map<String, dynamic>.from(stored));
    } catch (e) {
      return null;
    }
  }

  static Future<void> storeLanguage(Language language) async {
    await Hive.box(HiveKeys.languageBox).put(HiveKeys.currentLanguageKey, language.toJson());
  }

  static Future<void> logoutUser(context, {VoidCallback? onLogout}) async {
    await Hive.box(HiveKeys.userDetailsBox).clear();
    HiveUtils.setUserIsAuthenticated(false);
    onLogout?.call();
  }

  static Future<void> clear() async {
    await Hive.box(HiveKeys.userDetailsBox).clear();
    await Hive.box(HiveKeys.historyBox).clear();
    HiveUtils.setUserIsAuthenticated(false);
  }

  static String? getPendingReferralCode() {
    return Hive.box(HiveKeys.authBox).get(HiveKeys.pendingReferralCode)
        as String?;
  }

  static Future<void> setPendingReferralCode(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      await clearPendingReferralCode();
      return;
    }
    await Hive.box(HiveKeys.authBox).put(
      HiveKeys.pendingReferralCode,
      trimmed,
    );
  }

  static Future<void> clearPendingReferralCode() async {
    await Hive.box(HiveKeys.authBox).delete(HiveKeys.pendingReferralCode);
  }
}
