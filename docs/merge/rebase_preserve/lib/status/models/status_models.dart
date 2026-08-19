import 'package:eClassify/data/model/item/item_model.dart';

class StatusModel {
  final String name;
  final String avatarUrl;
  final List<String> mediaUrls;
  final String description;
  final ItemModel item;

  StatusModel({
    required this.item,
    required this.name,
    required this.avatarUrl,
    required this.mediaUrls,
    this.description = '',
  });
}
