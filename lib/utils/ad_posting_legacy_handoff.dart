import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/category_model.dart';
import 'package:flutter/material.dart';

/// Continues post-ad on legacy details → location → submit screens.
abstract final class AdPostingLegacyHandoff {
  static void openDetails(
    BuildContext context, {
    required List<CategoryModel> categoryPath,
    Map<String, dynamic>? wizardDraft,
    bool inAppWizardHandoff = false,
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
        if (wizardDraft != null && wizardDraft.isNotEmpty)
          'wizardDraft': wizardDraft,
      },
    );
  }
}
