import 'package:eClassify/app/routes.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/models/menu_item.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/models/menu_item_action.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/menu_item_widget.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:flutter/material.dart';
import 'package:eClassify/utils/app_icons.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const HelpAndSupportScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      MenuItem(
        icon: AppIcons.question,
        title: 'faqs',
        showTrailing: true,
        action: ScreenPushAction(route: Routes.faqsScreen),
      ),
      MenuItem(
        icon: AppIcons.phone,
        title: 'contactUs',
        showTrailing: true,
        action: ScreenPushAction(route: Routes.contactUs),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('helpAndSupport'.translate(context))),
      body: Padding(
        padding: Constant.appContentPadding,
        child: Column(
          spacing: 12,
          children: items.map((item) {
            return MenuItemWidget(
              item: item,
              tileColor: context.colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(12),
              ),
              contentPadding: EdgeInsets.all(12),
            );
          }).toList(),
        ),
      ),
    );
  }
}
