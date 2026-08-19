import 'package:collection/collection.dart';

enum HomeSectionType {
  categoryList('all_categories'),
  slider('slider'),
  popularCategories('popular_categories'),
  featuredSection('featured_section'),
  allAds('all_ads');

  const HomeSectionType(this.value);

  final String value;

  static HomeSectionType? parse(String value) {
    return HomeSectionType.values.firstWhereOrNull(
      (element) => element.value == value,
    );
  }
}

class HomeSection {
  final int id;
  final HomeSectionType type;

  HomeSection({required this.id, required this.type});

  factory HomeSection.fromJson(Map<String, dynamic> json) {
    final type = HomeSectionType.parse(json['section_type'] as String);
    if (type == null) {
      throw ArgumentError('Unknown section type: ${json['section_type']}');
    }
    return HomeSection(id: json['id'] as int, type: type);
  }
}
