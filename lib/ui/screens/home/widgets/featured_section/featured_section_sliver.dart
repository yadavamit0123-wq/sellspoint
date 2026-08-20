import 'dart:math';

import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/screens/home/widgets/featured_section/featured_section_style.dart';
import 'package:eClassify/ui/screens/home/widgets/item_card_widget.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:flutter/material.dart';

class FeaturedSectionSliver extends StatelessWidget {
  const FeaturedSectionSliver({required this.style, required this.items});

  final FeaturedSectionStyleData style;
  final List<ItemModel> items;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    if (style.type == SectionType.list) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: HelperUtils.lerpHeight(
            screenHeight: screenHeight,
            minHeight: 245,
            maxHeight: 285,
            minScreen: 600,
            maxScreen: 850,
          ),
          child: ListView.separated(
            itemCount: items.length,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: Constant.horizontalPadding,
            ),
            itemBuilder: (context, index) {
              return ItemCard(
                item: items[index],
                aspectRatio: style.childAspectRatio,
              );
            },
            separatorBuilder: (context, index) => 10.hGap,
          ),
        ),
      );
    } else {
      final itemCount = min(6, items.length);
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: Constant.horizontalPadding),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate((context, index) {
            return ItemCard(
              key: ValueKey(items[index].id ?? index),
              item: items[index],
            );
          }, childCount: itemCount),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: style.childAspectRatio,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
        ),
      );
    }
  }
}
