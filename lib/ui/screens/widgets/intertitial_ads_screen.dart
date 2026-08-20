import 'package:eClassify/utils/constant.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdHelper {
  static final InterstitialAdHelper _instance =
      InterstitialAdHelper._internal();

  InterstitialAdHelper._internal();

  static InterstitialAdHelper get instance => _instance;

  static InterstitialAd? _interstitialAd;
  static DateTime? _lastAdShowedTime;
  static int _adShowedCount = 0;

  static bool get _canShowAd {
    if (Constant.interstitialAdMaxCountPerSession != -1 &&
        _adShowedCount >= Constant.interstitialAdMaxCountPerSession) {
      return false;
    }
    if (_lastAdShowedTime != null &&
        DateTime.now().difference(_lastAdShowedTime!).inSeconds <
            Constant.interstitialAdTimeDelaySeconds) {
      return false;
    }
    return true;
  }

  static void loadInterstitialAd(String adUnitId) {
    if (!_canShowAd) {
      return;
    }
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: AdRequest(nonPersonalizedAds: true),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  static void showInterstitialAd() {
    if (_interstitialAd == null) {
      return;
    }
    if (!_canShowAd) {
      _interstitialAd!.dispose();
      _interstitialAd = null;
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        _lastAdShowedTime = DateTime.now();
        _adShowedCount++;
        print('ad onAdShowedFullScreenContent.');
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }
}
