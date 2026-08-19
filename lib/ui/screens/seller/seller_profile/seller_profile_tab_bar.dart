import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class SellerProfileTabBar extends StatelessWidget {
  const SellerProfileTabBar({required this.controller, super.key});
  final TabController controller;
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colorScheme.secondary,
      child: TabBar(
        controller: controller,
        dividerHeight: 0,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 2,
        labelStyle: context.titleMedium,
        labelColor: context.colorScheme.primary,
        unselectedLabelColor: context.mutedColor,
        tabs: [
          Tab(text: 'liveAds'.translate(context)),
          Tab(text: 'ratings'.translate(context)),
        ],
      ),
    );
  }
}
