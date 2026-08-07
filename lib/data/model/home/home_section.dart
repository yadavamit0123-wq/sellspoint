import 'package:collection/collection.dart';

/// Section types from admin `get-home-screen` (eClassify 2.14).
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
  const HomeSection({required this.id, required this.type});

  final int id;
  final HomeSectionType type;

  factory HomeSection.fromJson(Map<String, dynamic> json) {
    final typeRaw = json['section_type']?.toString() ?? '';
    final type = HomeSectionType.parse(typeRaw);
    if (type == null) {
      throw ArgumentError('Unknown section type: $typeRaw');
    }
    return HomeSection(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      type: type,
    );
  }
}
