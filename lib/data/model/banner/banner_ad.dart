import 'package:eClassify/data/model/banner/banner.dart';

abstract class BannerAd {
  BannerAd({
    required this.banners,
    required String layout,
    required String placement,
  }) : layout = BannerLayout.fromName(layout),
       placement = BannerPlacement.fromName(placement);

  final List<Banner> banners;
  final BannerLayout layout;
  final BannerPlacement placement;
}

enum BannerLayout {
  single(3.0),
  large(1.2),
  dual(4.29);

  const BannerLayout(this.aspectRatio);

  final double aspectRatio;

  static BannerLayout fromName(String layout) {
    return BannerLayout.values.firstWhere(
      (l) => l.name == layout,
      orElse: () => BannerLayout.single,
    );
  }
}

enum BannerPlacement {
  above,
  below;

  static BannerPlacement fromName(String value) {
    return BannerPlacement.values.firstWhere(
      (l) => l.name == value,
      orElse: () => BannerPlacement.above,
    );
  }
}

enum DetailSection {
  image('image'),
  adInfo('ad_info'),
  customFields('custom_fields'),
  aboutAd('about_ad'),
  location('location'),
  similarAds('similar_ads');

  const DetailSection(this.key);

  final String key;

  static DetailSection fromName(String value) {
    return DetailSection.values.firstWhere(
      (e) => e.key == value,
      orElse: () => DetailSection.image,
    );
  }
}

final class HomeBannerAd extends BannerAd {
  HomeBannerAd({
    required super.banners,
    required super.layout,
    required super.placement,
    required this.homeSectionId,
    this.featuredSectionId,
  });

  final int homeSectionId;
  final int? featuredSectionId;
}

final class DetailBannerAd extends BannerAd {
  DetailBannerAd({
    required super.banners,
    required super.layout,
    required super.placement,
    required String section,
  }) : section = DetailSection.fromName(section);

  final DetailSection section;
}
