import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/data/model/currency.dart';
import 'package:eClassify/data/model/custom_field/file_resource.dart';
import 'package:eClassify/data/model/item/ad_item_type.dart';
import 'package:eClassify/data/model/item/product_video.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/json_helper.dart';

typedef CustomFieldData = Map<String, dynamic>;

class AdPostingData {
  // Available during editing
  final int? id;
  final AdItemType? adType;
  final Category? category;
  final BasicDetails? basicDetails;
  final Map<int, LocalizedContent>? localizedContent;
  final Map<int, SeoData>? seoData;
  final Map<String, CustomFieldData>? customFields;
  final List<FileResource>? images;
  final List<int>? deletedImages;
  final ProductVideo? productVideo;
  final bool?
  deleteProductVideo; // Set to true if the video is of type RemoteFileResource and should be deleted,
  final FileResource? videoAd; // Reel
  final FileResource? thumbnail; // Reel
  final LeafLocation? location;

  const AdPostingData({
    this.id,
    this.adType,
    this.category,
    this.basicDetails,
    this.localizedContent,
    this.seoData,
    this.customFields,
    this.images,
    this.deletedImages,
    this.productVideo,
    this.deleteProductVideo,
    this.videoAd,
    this.thumbnail,
    this.location,
  });

  AdPostingData copyWith({
    AdItemType? itemType,
    Category? category,
    BasicDetails? basicDetails,
    MapEntry<int, LocalizedContent>? localizedContentEntry,
    Map<int, SeoData>? seoData,
    MapEntry<int, CustomFieldData>? customFieldsEntry,
    List<FileResource>? images,
    List<int>? deletedImages,
    ProductVideo? video,
    bool? deleteProductVideo,
    FileResource? videoAd,
    FileResource? thumbnail,
    LeafLocation? location,
  }) {
    var localizedContent = this.localizedContent ?? {};
    if (localizedContentEntry != null) {
      localizedContent[localizedContentEntry.key] = localizedContentEntry.value;
    }

    var customFields = this.customFields ?? {};
    if (customFieldsEntry != null) {
      customFields[customFieldsEntry.key.toString()] = customFieldsEntry.value;
    }

    return AdPostingData(
      id: this.id,
      adType: itemType ?? this.adType,
      category: category ?? this.category,
      basicDetails: basicDetails ?? this.basicDetails,
      seoData: seoData ?? this.seoData,
      localizedContent: localizedContent,
      customFields: customFields,
      images: images ?? this.images,
      deletedImages: deletedImages ?? this.deletedImages,
      productVideo: video ?? this.productVideo,
      deleteProductVideo: deleteProductVideo ?? this.deleteProductVideo,
      videoAd: videoAd ?? this.videoAd,
      thumbnail: thumbnail ?? this.thumbnail,
      location: location ?? this.location,
    );
  }

  Json get toJson => {
    'id': ?id,
    'item_type': ?adType?.value,
    'category_id': ?category?.id,
    ...?basicDetails?.toJson,
    if (seoData.isNotNullAndNotEmpty)
      'seo_details': {
        ...?seoData?.map((l, data) => MapEntry(l.toString(), data.toJson)),
      },
    if (localizedContent.isNotNullAndNotEmpty)
      'translations': {
        ...localizedContent!.map(
          (l, data) => MapEntry(l.toString(), data.toJson),
        ),
      },
    if (customFields.isNotNullAndNotEmpty)
      'custom_field_translations': {
        ...customFields!.map((l, data) => MapEntry(l, data)),
      },
    if (deletedImages.isNotNullAndNotEmpty)
      'delete_item_image_id': deletedImages,
    if (deleteProductVideo ?? false) 'delete_product_video': 1,
    'address': ?location?.canonicalPath,
    'latitude': ?location?.latitude,
    'longitude': ?location?.longitude,
    'country': ?location?.country?.canonical,
    'city': ?location?.city?.canonical,
    'state': ?location?.state?.canonical,
    'area': ?location?.area?.canonical,
  };

  @override
  String toString() {
    return 'AdPostingData{id: $id, adType: $adType, category: $category, basicDetails: $basicDetails, localizedContent: $localizedContent, seoData: $seoData, customFields: $customFields, images: $images, deletedImages: $deletedImages, productVideo: $productVideo, videoAd: $videoAd, thumbnail: $thumbnail, location: $location}';
  }
}

class BasicDetails {
  BasicDetails({
    required this.title,
    required this.description,
    this.slug,
    this.price,
    this.contact,
  });

  final String title;
  final String? slug;
  final String description;
  final ListingValue? price;
  final ContactDetails? contact;

  Json get toJson => {
    'name': title,
    'description': description,
    'slug': ?(slug.isNullOrEmpty) ? null : slug,
    ...?(price?.toJson.isEmpty ?? true) ? null : price?.toJson,
    ...?(contact?.toJson.isEmpty ?? true) ? null : contact?.toJson,
  };
}

class LocalizedContent {
  LocalizedContent({this.title, this.description});

  final String? title;
  final String? description;

  Json get toJson => {
    'name': ?(title.isNullOrEmpty) ? null : title,
    'description': ?(description.isNullOrEmpty) ? null : description,
  };
}

class SeoData {
  SeoData({
    this.metaTitle,
    this.metaDescription,
    this.metaKeywords,
    this.schema,
  });

  String? metaTitle;
  String? metaDescription;
  String? metaKeywords;
  String? schema;

  bool get isEmpty =>
      metaTitle == null ||
      metaDescription == null ||
      metaKeywords == null ||
      schema == null;

  Json get toJson => {
    'meta_title': ?(metaTitle.isNullOrEmpty) ? null : metaTitle,
    'meta_description': ?(metaDescription.isNullOrEmpty)
        ? null
        : metaDescription,
    'meta_keywords': ?(metaKeywords.isNullOrEmpty) ? null : metaKeywords,
    'schema': ?(schema.isNullOrEmpty) ? null : schema,
  };
}

abstract class ListingValue {
  const ListingValue({required this.currency});

  final Currency currency;

  Json get toJson => {'currency_id': ?currency.id};
}

class Price extends ListingValue {
  Price({required this.price, required super.currency});

  final String price;

  @override
  Json get toJson => {
    'price': ?(price.isNullOrEmpty) ? null : price,
    if (price.isNotNullAndNotEmpty) ...super.toJson,
  };
}

class Salary extends ListingValue {
  Salary({
    required this.minSalary,
    required this.maxSalary,
    required super.currency,
  });

  final String minSalary;
  final String maxSalary;

  @override
  Json get toJson => {
    'min_salary': ?(minSalary.isNullOrEmpty) ? null : minSalary,
    'max_salary': ?(maxSalary.isNullOrEmpty) ? null : maxSalary,
    if (minSalary.isNotNullAndNotEmpty || maxSalary.isNotNullAndNotEmpty)
      ...super.toJson,
  };
}

class ContactDetails {
  ContactDetails({
    required this.number,
    required this.phoneCode,
    required this.regionCode,
  });

  final String number;
  final String phoneCode;
  final String regionCode;

  // Since the phoneCode and regionCode are set to defaults in PhoneInputController,
  // ad posting data will always contain both the codes. Hence, we explicitly check for
  // empty number here to discard the phoneCode and regionCode fields.
  bool get isEmpty => number.isNullOrEmpty;

  Json get toJson {
    if (isEmpty) {
      // Return empty map if number is empty
      return {};
    }

    return {
      'contact': number,
      'country_code': phoneCode,
      'region_code': regionCode,
    };
  }
}
