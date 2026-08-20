enum AdItemType {
  regularAd,
  videoAd;

  String get value => this == AdItemType.regularAd ? 'normal' : 'reel';
}
