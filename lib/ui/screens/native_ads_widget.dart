
import 'package:eClassify/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({super.key, required this.type});
  final TemplateType type;

  @override
  _NativeAdWidgetState createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  void _loadNativeAd() {
    if (!Constant.systemSettings.isNativeAdEnabled) {
      return;
    }
    _nativeAd = NativeAd(
      adUnitId: Constant.systemSettings.nativeAdId!,
      request: const AdManagerAdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        // Required: Choose a template.
        templateType: widget.type,
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          setState(() {
            _isAdLoaded = false;
            ad.dispose();
          });
        },
      ),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded) {
      return ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 320, // minimum recommended width
          minHeight: 320, // minimum recommended height
          maxWidth: 400,
          maxHeight: 400,
        ),
        child: AdWidget(ad: _nativeAd!),
      );
    }

    return const SizedBox.shrink();
  }
}
