import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/company_page.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LegalInformationScreen extends StatelessWidget {
  const LegalInformationScreen({super.key});

  static Route route(RouteSettings settings) {
    return BlurredRouter(builder: (_) => const LegalInformationScreen());
  }

  @override
  Widget build(BuildContext context) {
    final entries = <({String icon, CompanyPage page})>[
      (icon: AppIcons.aboutUs, page: CompanyPage.aboutUs),
      (icon: AppIcons.terms, page: CompanyPage.termsAndConditions),
      (icon: AppIcons.privacy, page: CompanyPage.privacyPolicy),
      (icon: AppIcons.privacy, page: CompanyPage.refundPolicy),
    ];

    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: 'legalInformation'.translate(context),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _menuTile(
              context,
              title: entries[i].page.titleKey.translate(context),
              iconPath: entries[i].icon,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  Routes.companyPage,
                  arguments: entries[i].page,
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required String title,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return Material(
      color: context.color.secondaryColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              SvgPicture.asset(
                iconPath,
                height: 22,
                width: 22,
                colorFilter: ColorFilter.mode(
                  context.color.territoryColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: CustomText(title)),
              Icon(Icons.chevron_right, color: context.color.textDefaultColor),
            ],
          ),
        ),
      ),
    );
  }
}
