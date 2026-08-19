import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:flutter/material.dart';

class ChatDeleteConfirmationDialog {
  static Future<bool?> show(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'deleteChatTitle'.translate(context),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'deleteChatContent'.translate(context),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('cancel'.translate(context)),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('confirm'.translate(context)),
            ),
          ],
        );
      },
    );
  }
}
