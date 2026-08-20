import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/company_details.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/models/menu_item.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/models/menu_item_action.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/menu_item_widget.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:flutter/material.dart';

class LegalInformationScreen extends StatelessWidget {
  const LegalInformationScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const LegalInformationScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      MenuItem(
        icon: AppIcons.question,
        title: 'aboutUs',
        showTrailing: true,
        action: ScreenPushAction(
          route: Routes.companyPage,
          args: CompanyPage.aboutUs,
        ),
      ),
      MenuItem(
        icon: AppIcons.shieldCheck,
        title: 'termsAndConditions',
        showTrailing: true,
        action: ScreenPushAction(
          route: Routes.companyPage,
          args: CompanyPage.termsAndConditions,
        ),
      ),
      MenuItem(
        icon: AppIcons.note,
        title: 'privacyPolicy',
        showTrailing: true,
        action: ScreenPushAction(
          route: Routes.companyPage,
          args: CompanyPage.privacyPolicy,
        ),
      ),
      MenuItem(
        icon: AppIcons.receipt,
        title: 'refundPolicy',
        showTrailing: true,
        action: ScreenPushAction(
          route: Routes.companyPage,
          args: CompanyPage.refundPolicy,
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('legalInformation'.translate(context))),
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
