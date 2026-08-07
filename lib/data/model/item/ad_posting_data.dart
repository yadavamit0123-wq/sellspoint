import 'package:eClassify/data/model/category_model.dart';
import 'package:eClassify/data/model/item/ad_item_type.dart';

/// Mutable post-ad payload for the in-app wizard (expanded in later phases).
class AdPostingData {
  const AdPostingData({
    this.adType,
    this.categoryPath = const [],
    this.title,
    this.description,
    this.price,
    this.phone,
    this.slug,
    this.customFieldsJson,
    this.customFieldFiles = const {},
  });

  final AdItemType? adType;
  final List<CategoryModel> categoryPath;
  final String? title;
  final String? description;
  final String? price;
  final String? phone;
  final String? slug;
  final String? customFieldsJson;
  final Map<String, dynamic> customFieldFiles;

  CategoryModel? get leafCategory =>
      categoryPath.isEmpty ? null : categoryPath.last;

  Map<String, dynamic> get wizardDraft => {
        if (title != null && title!.trim().isNotEmpty) 'title': title!.trim(),
        if (description != null && description!.trim().isNotEmpty)
          'description': description!.trim(),
        if (price != null && price!.trim().isNotEmpty) 'price': price!.trim(),
        if (phone != null && phone!.trim().isNotEmpty) 'phone': phone!.trim(),
        if (slug != null && slug!.trim().isNotEmpty) 'slug': slug!.trim(),
        if (customFieldsJson != null && customFieldsJson!.isNotEmpty)
          'custom_fields': customFieldsJson,
        ...customFieldFiles,
      };

  AdPostingData copyWith({
    AdItemType? adType,
    List<CategoryModel>? categoryPath,
    String? title,
    String? description,
    String? price,
    String? phone,
    String? slug,
    String? customFieldsJson,
    Map<String, dynamic>? customFieldFiles,
  }) {
    return AdPostingData(
      adType: adType ?? this.adType,
      categoryPath: categoryPath ?? this.categoryPath,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      phone: phone ?? this.phone,
      slug: slug ?? this.slug,
      customFieldsJson: customFieldsJson ?? this.customFieldsJson,
      customFieldFiles: customFieldFiles ?? this.customFieldFiles,
    );
  }
}
