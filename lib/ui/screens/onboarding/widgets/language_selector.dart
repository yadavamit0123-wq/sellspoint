import 'package:eClassify/app/routes.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_keys.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// TODO(rio): Refactor this into a cleaner widget
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final languages = Constant.systemSettings.languages;
    if (languages.length <= 1) {
      return const SizedBox.shrink();
    }
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: context.colorScheme.onSurface,
        iconColor: context.colorScheme.primary,
        iconSize: 30,
        padding: EdgeInsets.symmetric(horizontal: Constant.horizontalPadding),
      ),
      onPressed: () {
        Navigator.pushNamed(context, Routes.languageListScreenRoute);
      },
      child: StreamBuilder(
        stream: Hive.box(
          HiveKeys.languageBox,
        ).watch(key: HiveKeys.currentLanguageKey),
        builder: (context, AsyncSnapshot<BoxEvent> value) {
          final defaultLanguage = Constant.systemSettings.defaultLanguageCode
              .toUpperCase();

          final languageCode =
              value.data?.value?['code'] ?? defaultLanguage ?? "En";

          return Row(
            children: [
              Text((languageCode as String).toCapitalized()),
              Icon(AppIcons.caretDown, size: 16),
            ],
          );
        },
      ),
    );
  }
}
