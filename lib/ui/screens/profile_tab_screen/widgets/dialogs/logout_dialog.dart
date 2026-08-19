import 'package:eClassify/ui/screens/widgets/app_dialog.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_assets.dart';
import 'package:eClassify/utils/color_mappers/primary_color_mapper.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:flutter/material.dart';

class LogoutDialog {
  static Future<bool?> show(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AppDialog(
          icon: CustomImage(
            src: AppAssets.illustrators.logout,
            svgColorMapper: PrimaryColorMapper(context.colorScheme.primary),
          ),
          title: Text(
            "confirmLogoutTitle".translate(context),
            style: context.titleLarge,
          ),
          content: Text(
            "confirmLogOutDescription".translate(context),
            style: context.titleMedium,
            textAlign: TextAlign.center,
          ),
          negativeButtonLabel: 'cancel'.translate(context),
          positiveButtonLabel: 'confirm'.translate(context),
        );
      },
    );
  }
}
