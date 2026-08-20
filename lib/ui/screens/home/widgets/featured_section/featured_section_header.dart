import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/item/item_list.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:flutter/material.dart';

class FeaturedSectionHeader extends StatelessWidget {
  const FeaturedSectionHeader({
    super.key,
    required this.id,
    required this.title,
  });

  final int id;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: context.titleMedium, maxLines: 1)),
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            textStyle: context.labelMedium,
          ),
          onPressed: () {
            Navigator.of(context).pushNamed(
              Routes.itemsList,
              arguments: SectionMetaData(sectionId: id, title: title),
            );
          },
          child: Text('seeAll'.translate(context)),
        ),
      ],
    );
  }
}
