import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 2.14-style update prompt (force or optional).
abstract final class VersionUpdateDialog {
  static void show(
    BuildContext context, {
    required String availableVersionLabel,
    required bool isForceUpdate,
    required String storeUrl,
  }) {
    if (storeUrl.trim().isEmpty) return;

    showDialog<void>(
      context: context,
      barrierDismissible: !isForceUpdate,
      builder: (dialogContext) {
        return PopScope(
          canPop: !isForceUpdate,
          child: AlertDialog(
            backgroundColor: dialogContext.color.secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: CustomText(
              'updateAvailable'.translate(dialogContext),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: CustomText(
                    availableVersionLabel,
                    fontSize: dialogContext.font.larger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                CustomText(
                  isForceUpdate
                      ? 'newVersionAvailableForce'.translate(dialogContext)
                      : 'newVersionAvailable'.translate(dialogContext),
                  textAlign: TextAlign.center,
                  fontSize: dialogContext.font.small,
                  color: dialogContext.color.textLightColor,
                ),
                if (isForceUpdate) ...[
                  const SizedBox(height: 8),
                  CustomText(
                    'forceUpdateHint'.translate(dialogContext),
                    textAlign: TextAlign.center,
                    fontSize: dialogContext.font.smaller,
                    color: dialogContext.color.territoryColor,
                  ),
                ],
              ],
            ),
            actions: [
              if (!isForceUpdate)
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: CustomText('cancelLbl'.translate(dialogContext)),
                ),
              FilledButton(
                onPressed: () async {
                  final uri = Uri.tryParse(storeUrl);
                  if (uri != null) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text('update'.translate(dialogContext)),
              ),
            ],
          ),
        );
      },
    );
  }
}
