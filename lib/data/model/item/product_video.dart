import 'package:eClassify/data/model/custom_field/file_resource.dart';
import 'package:eClassify/utils/json_helper.dart';

enum ProductVideoType {
  youtube('youtube_link'),
  vimeo('vimeo_link'),
  otherLink('other_link'),
  custom('file');

  const ProductVideoType(this.key);

  final String key;

  static ProductVideoType fromName(String name) =>
      ProductVideoType.values.firstWhere((e) => e.key == name);
}

class ProductVideo {
  ProductVideo({required this.type, required this.videoSource});

  ProductVideo.fromJson(Json json)
    : type = ProductVideoType.fromName(json['video_type']),
      videoSource = FileResource.fromPath(
        (json['video_link'] ?? json['video_file']) as String,
      );

  final ProductVideoType type;
  final FileResource videoSource;
}
