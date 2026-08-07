import 'package:eClassify/utils/api.dart';
import 'package:flutter/widgets.dart';

/// CMS page types from admin system settings (2.14-compatible).
enum CompanyPage {
  aboutUs,
  termsAndConditions,
  privacyPolicy,
  refundPolicy,
}

extension CompanyPageApi on CompanyPage {
  String get apiType {
    return switch (this) {
      CompanyPage.aboutUs => Api.aboutUs,
      CompanyPage.termsAndConditions => Api.termsAndConditions,
      CompanyPage.privacyPolicy => Api.privacyPolicy,
      CompanyPage.refundPolicy => Api.refundPolicy,
    };
  }

  String titleKey {
    return switch (this) {
      CompanyPage.aboutUs => 'aboutUs',
      CompanyPage.termsAndConditions => 'termsConditions',
      CompanyPage.privacyPolicy => 'privacyPolicy',
      CompanyPage.refundPolicy => 'refundPolicy',
    };
  }
}
