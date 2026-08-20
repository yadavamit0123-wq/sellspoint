import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/utils/json_helper.dart';

base class HomeSlider {
  factory HomeSlider.parse(Json json) {
    final type = json['model_type'] as String?;
    return switch(type){
      'App\\Models\\Item' => ItemSlider.fromJson(json),
      'App\\Models\\Category' => CategorySlider.fromJson(json),
      _ => ExternalLinkSlider.fromJson(json),
    };
  }

  HomeSlider._fromJson(Json json):
      id = json['id'] as int,
      image = json['image'] as String;

  final int id;
  final String image;
}

final class ExternalLinkSlider extends HomeSlider{
  ExternalLinkSlider.fromJson(Json json):
      url = Uri.parse(json['third_party_link'] as String),
      super._fromJson(json);
  final Uri url;
}

final class ItemSlider extends HomeSlider{
  ItemSlider.fromJson(Json json):
      itemId = json['model_id'] as int,
      super._fromJson(json);
  final int itemId;
}

final class CategorySlider extends HomeSlider{
  CategorySlider.fromJson(Json json):
      category = Category.fromJson(json['model']),
      super._fromJson(json);
  final Category category;
}