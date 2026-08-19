import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:flutter/material.dart';

class FreePackagePurchaseDialog {
  static Future<bool?> show(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'freePackagePurchase'.translate(context),
            style: context.titleMedium,
            textAlign: TextAlign.center,
          ),
          content: Text(
            'freePackagePurchaseMsg'.translate(context),
            style: context.bodyMedium,
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colorScheme.surface,
                      foregroundColor: context.colorScheme.onSurface,
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('cancel'.translate(context)),
                  ),
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('confirm'.translate(context)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
