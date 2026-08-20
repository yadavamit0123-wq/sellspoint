import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/model/localized_string.dart';
import 'package:eClassify/utils/json_helper.dart';

class FeaturedSection {
  FeaturedSection.fromJson(Json json)
    : id = json['id'] as int,
      title = LocalizedString(
        canonical: json['title'] as String,
        translated: json['translated_name'] as String,
      ),
      style = json['style'] as String,
      items = JsonHelper.parseList(
        json['section_data'] as List?,
        ItemModel.fromJson,
      );

  final int id;
  final LocalizedString title;
  final String style;
  final List<ItemModel> items;
}
