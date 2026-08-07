/// Listing kinds supported by the 2.14 post-ad wizard (video ad later).
enum AdItemType {
  regularAd('regular'),
  videoAd('video');

  const AdItemType(this.value);

  final String value;

  static AdItemType? fromValue(String? raw) {
    if (raw == null) return null;
    for (final type in AdItemType.values) {
      if (type.value == raw) return type;
    }
    return null;
  }
}
