import 'package:eClassify/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoogleBannerAd extends StatefulWidget {
  GoogleBannerAd({super.key});

  @override
  _GoogleBannerAdState createState() => _GoogleBannerAdState();
}

class _GoogleBannerAdState extends State<GoogleBannerAd> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAd());
  }

  @override
  void dispose() {
    if (_bannerAd != null) _bannerAd!.dispose();
    super.dispose();
  }

  void _loadAd() async {
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
      MediaQuery.sizeOf(context).width.toInt() -
          (Constant.horizontalPadding.toInt() * 2),
    );

    if (size == null) {
      // Unable to get width of anchored banner.
      return;
    }

    BannerAd(
      adUnitId: Constant.systemSettings.bannerAdId!,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          // Called when an ad is successfully received.
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          // Called when an ad request failed.
          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  Widget build(BuildContext context) {
    return _bannerAd == null
        ? SizedBox.shrink()
        : SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          );
  }
}
