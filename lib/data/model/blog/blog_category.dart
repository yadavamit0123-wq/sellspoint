import 'package:eClassify/data/model/localized_string.dart';
import 'package:eClassify/utils/json_helper.dart';

class BlogCategory {
  BlogCategory({required this.id, required this.name});

  BlogCategory.fromJson(Json json)
    : id = json['id'] as int,
      name = LocalizedString(
        canonical: json['name'] as String,
        translated: json['translated_name'] as String?,
      );
  final int? id;
  final LocalizedString name;
}
