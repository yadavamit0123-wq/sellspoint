import 'package:eClassify/data/enums.dart';
import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/utils/json_helper.dart';

class ItemFilter {
  final int? maxPrice;
  final int? minPrice;
  final Category? category;
  final PostedSince? postedSince;
  final LeafLocation? location;
  final Map<String, dynamic>? customFields;

  ItemFilter({
    this.maxPrice,
    this.minPrice,
    this.category,
    this.postedSince,
    this.location,
    this.customFields = const {},
  });

  ItemFilter copyWith({
    int? maxPrice,
    int? minPrice,
    Category? category,
    PostedSince? postedSince,
    LeafLocation? location,
    Map<String, dynamic>? customFields,
  }) {
    return ItemFilter(
      maxPrice: maxPrice ?? this.maxPrice,
      minPrice: minPrice ?? this.minPrice,
      category: category ?? this.category,
      postedSince: postedSince ?? this.postedSince,
      location: location ?? this.location,
      customFields: customFields ?? this.customFields,
    );
  }

  Json get toJson => <String, dynamic>{
    'max_price': ?maxPrice,
    'min_price': ?minPrice,
    'category_id': ?category?.id,
    'posted_since': ?postedSince?.value,
    ...?customFields,
    ...?location?.toApiJson(),
  };
}
