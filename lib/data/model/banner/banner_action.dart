import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/utils/json_helper.dart';

sealed class BannerAction {
  const BannerAction();

  factory BannerAction.parse(Json json) {
    final type = json['ad_type'] as String;
    return switch (type) {
      'only_banner' => NoAction(),
      'external_link' => OpenExternalLink(json['link'] as String),
      'category' => OpenCategory(Category.fromJson(json['category'] as Json)),
      'advertisement' => OpenAdvertisement(json['advertisement_id'] as int),
      _ => throw Exception('Invalid Banner Ad Type'),
    };
  }
}

class NoAction extends BannerAction {}

class OpenExternalLink extends BannerAction {
  OpenExternalLink(String url) : url = Uri.parse(url);
  final Uri url;
}

class OpenCategory extends BannerAction {
  OpenCategory(this.category);

  final Category category;
}

class OpenAdvertisement extends BannerAction {
  OpenAdvertisement(this.itemId);

  final int itemId;
}
