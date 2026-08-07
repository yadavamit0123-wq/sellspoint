import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

/// 2.14 bottom tabs — used when [AppConfig.enableFiveTabNavV214] is on.
enum BottomTab { home, chat, videoAds, myAds, profile }

extension BottomTabIndex on BottomTab {
  int get tabIndex => index;
}

class BottomNavCubit extends Cubit<BottomTab> {
  BottomNavCubit() : super(BottomTab.home);

  final StreamController<BottomTab> _repeatTapController =
      StreamController<BottomTab>.broadcast();

  /// Fired when the user selects the tab that is already active.
  Stream<BottomTab> get repeatTaps => _repeatTapController.stream;

  void changeTab(BottomTab tab) {
    if (state == tab) {
      _repeatTapController.add(tab);
    }
    emit(tab);
  }

  void changeTabByIndex(int index) {
    if (index < 0 || index >= BottomTab.values.length) return;
    changeTab(BottomTab.values[index]);
  }

  @override
  Future<void> close() {
    _repeatTapController.close();
    return super.close();
  }
}
