import 'package:eClassify/ui/screens/widgets/intertitial_ads_screen.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:flutter/material.dart';

mixin InterstitialAdOnExitMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    if (Constant.systemSettings.isInterstitialAdEnabled) {
      InterstitialAdHelper.loadInterstitialAd(
        Constant.systemSettings.interstitialAdId!,
      );
    }
  }

  @override
  void dispose() {
    InterstitialAdHelper.showInterstitialAd();
    super.dispose();
  }
}
