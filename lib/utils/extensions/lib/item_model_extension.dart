import 'package:collection/collection.dart';
import 'package:eClassify/data/model/custom_field/file_resource.dart';
import 'package:eClassify/data/model/item/ad_item_type.dart';
import 'package:eClassify/data/model/item/ad_posting_data.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/model/localized_string.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/hive_utils.dart';

extension ItemModelExtension on ItemModel {
  bool get isMyAd {
    final adUserId = this.user?.id;
    final myId = HiveUtils.getUserId();

    return adUserId.toString() == myId.toString();
  }

  AdPostingData toAdPostingData() {
    final itemType = this.itemType ?? AdItemType.regularAd;
    final category = this.category!;

    // Basic Details
    final name = this.name!;
    final description = this.description!;
    final slug = this.slug;
    final price = _extractPrice();
    final contact = _extractContactDetails();

    final basicDetails = BasicDetails(
      title: name,
      description: description,
      slug: slug,
      price: price,
      contact: contact,
    );

    // Localized Content
    final localizedContent = _extractLocalizedContent();

    // SEO Data
    final seoData = _extractSeoData();

    // Custom Fields
    final customFields = _extractCustomFields();

    // Images
    final images = this.galleryImages
        ?.map((e) => RemoteFileResource(Uri.parse(e.image!), id: e.id!))
        .nonNulls
        .toList();

    // Location
    final location = LeafLocation(
      latitude: this.latitude,
      longitude: this.longitude,
      country: this.country != null
          ? LocalizedString(canonical: this.country!)
          : null,
      city: this.city != null ? LocalizedString(canonical: this.city!) : null,
      state: this.state != null
          ? LocalizedString(canonical: this.state!)
          : null,
      area: this.area != null ? LocalizedString(canonical: this.area!) : null,
    );

    return AdPostingData(
      id: this.id,
      adType: itemType,
      category: category,
      basicDetails: basicDetails,
      localizedContent: localizedContent,
      seoData: seoData,
      customFields: customFields,
      images: images,
      location: location,
      productVideo: this.video,
    );
  }

  ListingValue? _extractPrice() {
    if (this.category!.isJobCategory) {
      return Salary(
        minSalary: this.minSalary != null ? this.minSalary.toString() : '',
        maxSalary: this.maxSalary != null ? this.maxSalary.toString() : '',
        currency: this.currency ?? Constant.systemSettings.defaultCurrency,
      );
    } else {
      return Price(
        price: this.price != null ? this.price.toString() : '',
        currency: this.currency ?? Constant.systemSettings.defaultCurrency,
      );
    }
  }

  ContactDetails? _extractContactDetails() {
    final contact = this.contact;
    final phoneCode = this.phoneCode;
    final regionCode = this.regionCode;
    if (contact == null || phoneCode == null || regionCode == null) {
      return null;
    }
    return ContactDetails(
      number: contact,
      phoneCode: phoneCode,
      regionCode: regionCode,
    );
  }

  Map<int, LocalizedContent>? _extractLocalizedContent() {
    if (this.translations.isNullOrEmpty) return null;
    final localizedContent = <int, LocalizedContent>{};
    final translationsByLanguage = groupBy(this.translations!, (element) {
      if (element is Map) {
        final languageId =
            int.tryParse(element['language_id'].toString()) ?? -1;
        return languageId;
      }
      return -1;
    });

    for (final field in translationsByLanguage.entries) {
      final languageId = field.key;
      final translations = field.value;
      final translationsByKey = groupBy(
        translations,
        (element) => element['key'],
      );
      final content = LocalizedContent(
        title: translationsByKey['name']?.firstOrNull['value'] as String?,
        description:
            translationsByKey['description']?.firstOrNull['value'] as String?,
      );
      localizedContent[languageId] = content;
    }

    return localizedContent;
  }

  Map<int, SeoData>? _extractSeoData() {
    if (this.seoDetails == null) return null;
    final seoData = <int, SeoData>{};
    final defaultLanguageId = Constant.systemSettings.defaultLanguage.id;

    final defaultLanguageSeo = SeoData(
      metaTitle: this.seoDetails!.metaTitle,
      metaDescription: this.seoDetails!.metaDescription,
      metaKeywords: this.seoDetails!.metaKeywords,
      schema: this.seoDetails!.schema,
    );

    seoData[defaultLanguageId] = defaultLanguageSeo;
    if (this.translations.isNullOrEmpty) return seoData;

    for (final fields in this.translations!) {
      final languageId = int.tryParse(fields['language_id'].toString()) ?? -1;
      final metaTitle = fields['meta_title'] as String?;
      final metaDescription = fields['meta_description'] as String?;
      final metaKeywords = fields['meta_keywords'] as String?;
      final schema = fields['schema'] as String?;
      final seo = SeoData(
        metaTitle: metaTitle,
        metaDescription: metaDescription,
        metaKeywords: metaKeywords,
        schema: schema,
      );
      seoData[languageId] = seo;
    }
    return seoData;
  }

  Map<String, CustomFieldData>? _extractCustomFields() {
    if (this.allTranslatedCustomFields.isNullOrEmpty) return null;
    final defaultLanguageId = Constant.systemSettings.defaultLanguage.id
        .toString();
    final customFields = <String, CustomFieldData>{};

    for (final field in this.allTranslatedCustomFields!) {
      final languageId = field['language_id'] == null
          ? defaultLanguageId
          : field['language_id'].toString();
      final fieldId = field['id'].toString();
      final fieldType = field['type'].toString();

      final fieldValue = switch (fieldType) {
        'radio' ||
        'dropdown' ||
        'textbox' ||
        'number' => (field['value'] as List?)?.firstOrNull,
        'checkbox' => (field['value'] as List?)?.cast<String>(),
        'fileinput' when (field['value'] is String) => FileResource.fromPath(
          field['value'] as String? ?? '',
        ),
        _ => null,
      };
      if (fieldValue == null) continue;

      customFields.putIfAbsent(languageId, () => <String, dynamic>{});
      customFields[languageId]![fieldId] = fieldValue!;
    }

    return customFields;
  }
}
