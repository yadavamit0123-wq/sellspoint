import 'package:eClassify/utils/json_helper.dart';

class SeoDetails {
  SeoDetails.fromJson(Json json)
    : metaTitle = json['meta_title'] as String?,
      metaDescription = json['meta_description'] as String?,
      metaKeywords = json['meta_keywords'] as String?,
      schema = json['schema'] as String?,
      translations = (json['translations'] as List?)?.cast<Json>();

  final String? metaTitle;
  final String? metaDescription;
  final String? metaKeywords;
  final String? schema;
  final List<Json>? translations;
}
