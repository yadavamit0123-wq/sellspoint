import 'package:eClassify/utils/json_helper.dart';

class BlogTag {
  BlogTag({required this.label, required this.value});

  BlogTag.fromJson(Json json)
    : label = json['label'].toString(),
      value = json['value'].toString();

  final String label;
  final String? value;

  @override
  bool operator ==(Object other) => other is BlogTag && other.value == value;

  @override
  int get hashCode => Object.hash(label, value);
}
