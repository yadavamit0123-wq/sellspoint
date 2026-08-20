import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

enum BottomTab { home, chat, videoAds, myAds, profile }

class BottomNavCubit extends Cubit<BottomTab> {
  BottomNavCubit() : super(BottomTab.home);

  final StreamController<BottomTab> _streamController =
      StreamController<BottomTab>.broadcast();

  Stream<BottomTab> get taps => _streamController.stream;

  void changeTab(BottomTab tab) {
    if (state == tab) {
      _streamController.add(tab);
    }
    emit(tab);
  }

  @override
  Future<void> close() {
    _streamController.close();
    return super.close();
  }
}
