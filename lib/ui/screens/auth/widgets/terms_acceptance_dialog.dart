import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/company_details.dart';
import 'package:eClassify/ui/screens/widgets/app_dialog.dart';
import 'package:eClassify/ui/screens/widgets/auto_size_text.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

/// A dialog that asks a new social login user to accept the Terms of Service
/// and Privacy Policy before completing registration.
///
/// Returns `true` if the user accepts, `false` if they cancel.
class TermsAcceptanceDialog {
  /// Convenience helper to show the dialog and await the result.
  static Future<bool?> show(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isAccepted = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AppDialog(
              title: Text(
                "termsAndPrivacy".translate(context),
                style: context.titleLarge,
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "pleaseAcceptTermsSocial".translate(context),
                    style: context.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: isAccepted,
                        activeColor: context.color.territoryColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        onChanged: (val) {
                          setState(() {
                            isAccepted = val ?? false;
                          });
                        },
                      ),
                      const SizedBox(width: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              Routes.companyPage,
                              arguments: CompanyPage.termsAndConditions,
                            ),
                            child: CustomText(
                              "termsOfService".translate(context),
                              showUnderline: true,
                              color: context.color.territoryColor,
                              fontSize: context.font.small,
                            ),
                          ),
                          CustomText(
                            " ${"andTxt".translate(context)} ",
                            color: context.color.textLightColor,
                            fontSize: context.font.small,
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              Routes.companyPage,
                              arguments: CompanyPage.privacyPolicy,
                            ),
                            child: CustomText(
                              "privacyPolicy".translate(context),
                              showUnderline: true,
                              color: context.color.territoryColor,
                              fontSize: context.font.small,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                // Cancel button
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colorScheme.surface,
                      foregroundColor: context.colorScheme.onSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      fixedSize: const Size.fromHeight(40),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: AutoSizeText(
                      text: "cancel".translate(context),
                      style: context.titleMedium,
                      maxLines: 1,
                      minimumFontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Continue button – enabled only when accepted
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: isAccepted
                          ? context.colorScheme.primary
                          : context.colorScheme.surface.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      fixedSize: const Size.fromHeight(40),
                    ),
                    onPressed: isAccepted
                        ? () => Navigator.of(context).pop(true)
                        : null,
                    child: AutoSizeText(
                      text: "continueTxt".translate(context),
                      style: context.titleMedium.withColor(
                        isAccepted
                            ? context.colorScheme.onPrimary
                            : context.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                      ),
                      maxLines: 1,
                      minimumFontSize: 14,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
