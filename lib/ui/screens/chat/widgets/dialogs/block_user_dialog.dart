import 'package:eClassify/data/model/chat/chat.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:flutter/material.dart';

class BlockUserDialog {
  static Future<bool?> show(
    BuildContext context, {
    required ChatUser user,
    required bool isUserBlocked,
  }) async {
    final contentLabel = isUserBlocked
        ? "${"unBlockLbl".translate(context)}\t${user.name}\t${"toSendMessage".translate(context)}"
              .translate(context)
        : "${"blockLbl".translate(context)}\t${user.name}?".translate(context);
    final buttonLabel = isUserBlocked
        ? "unBlockLbl".translate(context)
        : "blockLbl".translate(context);

    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              Text(
                contentLabel,
                style: context.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (!isUserBlocked)
                Text(
                  'blockWarning'.translate(context),
                  style: context.labelLarge,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: Size.fromHeight(40)),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(buttonLabel),
            ),
          ],
        );
      },
    );
  }
}
