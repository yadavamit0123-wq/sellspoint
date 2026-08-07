import 'package:eClassify/utils/hive_utils.dart';

/// Shared helpers for the in-app post-ad wizard.
abstract final class AdPostingWizardUtils {
  static String generateSlug(String title) {
    var slug = title.toLowerCase();
    slug = slug.replaceAll(' ', '-');
    slug = slug.replaceAll(RegExp(r'[^a-z0-9\-]'), '');
    return slug;
  }

  static bool get autoSlugFromTitle {
    final lang = HiveUtils.getLanguage();
    if (lang is Map) {
      return lang['code']?.toString().toLowerCase() == 'en';
    }
    return false;
  }
}
