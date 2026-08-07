import 'dart:io';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/category_model.dart';
import 'package:flutter/material.dart';

/// Continues post-ad on legacy video-link screen or location after wizard media.
abstract final class AdPostingLegacyHandoff {
  static void openDetails(
    BuildContext context, {
    required List<CategoryModel> categoryPath,
    Map<String, dynamic>? wizardDraft,
    bool inAppWizardHandoff = false,
    bool inAppWizardPhotosDone = false,
    File? wizardMainImage,
    List<File>? wizardGalleryImages,
    Map<String, dynamic>? extraArguments,
  }) {
    Navigator.pushReplacementNamed(
      context,
      Routes.addItemDetails,
      arguments: {
        ...?extraArguments,
        'breadCrumbItems': categoryPath,
        'isEdit': false,
        if (inAppWizardHandoff) 'inAppWizardHandoff': true,
        if (inAppWizardPhotosDone) 'inAppWizardPhotosDone': true,
        if (wizardMainImage != null) 'wizardMainImage': wizardMainImage,
        if (wizardGalleryImages != null && wizardGalleryImages.isNotEmpty)
          'wizardGalleryImages': wizardGalleryImages,
        if (wizardDraft != null && wizardDraft.isNotEmpty)
          'wizardDraft': wizardDraft,
      },
    );
  }
}
