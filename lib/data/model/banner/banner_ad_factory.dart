import 'package:eClassify/data/model/banner/banner.dart';
import 'package:eClassify/data/model/banner/banner_ad.dart';
import 'package:eClassify/utils/json_helper.dart';

final class BannerAdFactory {
  static BannerAd createBannerAd(Object data) {
    final (map, banners) = _extract(data);

    final page = map['page'] as String;

    return switch (page) {
      'home' => HomeBannerAd(
        banners: banners,
        layout: map['layout'] as String,
        placement: map['placement'] as String,
        homeSectionId: map['home_screen_section_id'] as int,
        featuredSectionId: map['feature_section_id'] as int?,
      ),

      'detail' => DetailBannerAd(
        banners: banners,
        layout: map['layout'] as String,
        placement: map['placement'] as String,
        section: map['detail_page_section'] as String,
      ),

      _ => throw UnsupportedError('Unsupported page type: $page'),
    };
  }

  static (Json, List<Banner>) _extract(Object data) {
    return switch (data) {
      final Json json => (json, [Banner.fromJson(json)]),

      final List list when list.isNotEmpty => (
        (list.first as Json),
        list.cast<Json>().map(Banner.fromJson).toList(),
      ),

      _ => throw ArgumentError('Invalid banner payload'),
    };
  }
}
