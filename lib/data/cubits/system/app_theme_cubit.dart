// ignore_for_file: depend_on_referenced_packages

import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppThemeCubit extends Cubit<ThemeMode> {
  AppThemeCubit() : super(ThemeMode.light) {
    final currentTheme = HiveUtils.getCurrentTheme();
    if (state != currentTheme) {
      emit(currentTheme);
    }
  }

  void toggleTheme() {
    final toggledTheme = state == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    HiveUtils.setCurrentTheme(toggledTheme);
    AppSession.setCurrentTheme(toggledTheme);
    emit(toggledTheme);
  }

  bool isDarkMode() {
    return state == ThemeMode.dark;
  }
}
