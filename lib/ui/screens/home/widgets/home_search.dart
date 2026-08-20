import 'dart:convert';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/item/item_list.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/hive_keys.dart' show HiveKeys;
import 'package:eClassify/utils/json_helper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomeSearchField extends StatelessWidget {
  const HomeSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final history = Hive.box(HiveKeys.historyBox).values.map((jsonString) {
          // TODO(I): jsonDecode should not be happening on main thread
          // Better way is to use HiveAdapter to store only the required information
          // of the item such as id, slug and name. Other parameters should be
          // dropped from local storage.
          // Consider this as part of ItemModel refactor
          final json = (jsonDecode(jsonString) as Map).cast<String, dynamic>();
          return JsonHelper.parseObject(json, ItemModel.fromJson);
        }).toList();

        Navigator.pushNamed(
          context,
          Routes.itemsList,
          arguments: SearchMetaData(
            title: 'search'.translate(context),
            searchHistory: history,
          ),
        );
      },
      child: Container(
        margin: Constant.appContentPadding.copyWith(bottom: 5, top: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colorScheme.secondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colorScheme.surfaceContainerHigh),
        ),
        constraints: BoxConstraints(maxHeight: 48),
        child: Row(
          spacing: 10,
          children: [
            Icon(AppIcons.magnifyingGlass, color: context.colorScheme.primary),
            Expanded(
              child: Text(
                'searchHintLbl'.translate(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodyLarge.withColor(context.mutedColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
