import 'package:eClassify/utils/json_helper.dart';

enum CompanyPage {
  aboutUs,
  contactUs,
  termsAndConditions,
  privacyPolicy,
  refundPolicy,
}

class _CompanyPages {
  _CompanyPages.fromJson(Map<String, dynamic> json)
    : aboutUs = json['about_us'] as String?,
      contactUs = json['contact_us'] as String?,
      termsAndConditions = json['terms_conditions'] as String?,
      privacyPolicy = json['privacy_policy'] as String?,
      refundPolicy = json['refund_policy'] as String?;

  final String? aboutUs;
  final String? contactUs;
  final String? termsAndConditions;
  final String? privacyPolicy;
  final String? refundPolicy;

  String? getPageFromType(CompanyPage type) {
    return switch (type) {
      CompanyPage.aboutUs => aboutUs,
      CompanyPage.contactUs => contactUs,
      CompanyPage.termsAndConditions => termsAndConditions,
      CompanyPage.privacyPolicy => privacyPolicy,
      CompanyPage.refundPolicy => refundPolicy,
    };
  }
}

class CompanyDetails {
  CompanyDetails.fromJson(Json json)
    : pages = _CompanyPages.fromJson(json),
      companyName = json['company_name'] as String,
      companyContactNumbers = [
        ?json['company_tel1'] as String?,
        ?json['company_tel2'] as String?,
      ],
      companyEmail = json['company_email'] as String,
      address = json['address'] as String?;

  final _CompanyPages pages;
  final String companyName;
  final List<String> companyContactNumbers;
  final String companyEmail;
  final String? address;
}
