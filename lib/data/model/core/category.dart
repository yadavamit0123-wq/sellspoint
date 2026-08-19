import 'package:eClassify/data/model/localized_string.dart';
import 'package:eClassify/utils/json_helper.dart';

class Category {
  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.isJobCategory,
    required this.isPriceOptional,
    required this.hasSubCategories,
    this.packagesCount,
    this.canPostRegularAds = false,
    this.canPostVideoAds = false,
  });

  Category.fromJson(Json json)
    : id = json['id'] as int,
      name = LocalizedString(
        canonical: json['name'] as String,
        translated: json['translated_name'] as String,
      ),
      image = json['image'] as String? ?? '',
      isJobCategory = (json['is_job_category'] as int?) == 1,
      isPriceOptional = (json['price_optional'] as int?) == 1,
      packagesCount = json['packages_count'] as int?,
      hasSubCategories =
          // To handle the case where the item is retrieved from hive storage in
          // search history. This has no real use-case in that screen but adding this
          // for backwards compatibility
          json['has_sub_categories'] ??
          (json['subcategories'] as List?)?.isNotEmpty ??
          false,
      canPostRegularAds = json['is_listing_available'] as bool? ?? false,
      canPostVideoAds = json['is_reel_allowed_in_listing'] as bool? ?? false;

  factory Category.global() => Category(
    id: -1,
    name: LocalizedString(canonical: ''),
    image: '',
    isJobCategory: false,
    isPriceOptional: false,
    hasSubCategories: false,
  );

  final int id;
  final LocalizedString name;
  final String image;
  final bool isJobCategory;
  final bool isPriceOptional;
  final bool hasSubCategories;
  final int? packagesCount;
  final bool canPostRegularAds;
  final bool canPostVideoAds;

  Json get toJson => {
    'id': id,
    'name': name.canonical,
    'translated_name': name.localized,
    'image': image,
    'is_job_category': isJobCategory ? 1 : 0,
    'price_optional': isPriceOptional ? 1 : 0,
    'has_sub_categories': hasSubCategories,
    'packages_count': packagesCount,
  };

  @override
  bool operator ==(Object other) => other is Category && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
