import 'package:eClassify/app/routes.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:flutter/material.dart';

class LoginRequiredBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(context: context, builder: (_) => _SheetContent());
  }
}

class _SheetContent extends StatelessWidget {
  const _SheetContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'loginRequiredForFeature'.translate(context),
              style: context.titleMedium,
            ),
            5.vGap,
            Text(
              'loginToAuthorizePrompt'.translate(context),
              style: context.bodyMedium,
            ),
            10.vGap,
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton(
                onPressed: () {
                  Navigator.popAndPushNamed(context, Routes.login);
                },
                child: Text('loginNow'.translate(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
