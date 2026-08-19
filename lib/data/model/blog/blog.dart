import 'package:eClassify/data/model/blog/blog_category.dart';
import 'package:eClassify/data/model/localized_string.dart';
import 'package:eClassify/utils/json_helper.dart';

enum BlogFeedback {
  useful(1),
  notUseful(0);

  const BlogFeedback(this.value);

  final int value;

  static BlogFeedback? fromValue(int? value) {
    return switch (value) {
      1 => BlogFeedback.useful,
      0 => BlogFeedback.notUseful,
      _ => null,
    };
  }
}

class Blog {
  Blog.fromJson(Json json)
    : id = json['id'] as int,
      slug = json['slug'] as String,
      title = LocalizedString(
        canonical: json['title'] as String,
        translated: json['translated_title'] as String?,
      ),
      description = LocalizedString(
        canonical: json['description'] as String,
        translated: json['translated_description'] as String?,
      ),
      category = BlogCategory.fromJson(json['category'] as Json),
      image = json['image'] as String,
      createdAt = DateTime.parse(json['created_at'] as String),
      views = json['views'] as int? ?? 0,
      usefulCount = json['useful_count'] as int? ?? 0,
      notUsefulCount = json['not_useful_count'] as int? ?? 0,
      userFeedback = BlogFeedback.fromValue(json['user_feedback'] as int?);

  final int id;
  final String slug;
  final LocalizedString title;
  final LocalizedString description;
  final BlogCategory category;
  final String image;
  final DateTime createdAt;
  final int views;
  final int usefulCount;
  final int notUsefulCount;
  final BlogFeedback? userFeedback;
}
