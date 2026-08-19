import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:flutter/material.dart';

class DeleteMessagesDialog {
  static Future<bool?> show(BuildContext context, {required int count}) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              Text(
                "${"delete".translate(context)} $count ${"messages".translate(context)}?",
                style: context.titleLarge,
                textAlign: TextAlign.center,
              ),
              Text(
                "deleteAdsDescription".translate(context),
                style: context.labelLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("cancel".translate(context)),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("delete".translate(context)),
            ),
          ],
        );
      },
    );
  }
}
