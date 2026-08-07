import 'package:eClassify/app/routes.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  static Route route(RouteSettings settings) {
    return BlurredRouter(builder: (_) => const HelpAndSupportScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: 'helpAndSupport'.translate(context),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _menuTile(
            context,
            title: 'faqsLbl'.translate(context),
            iconPath: AppIcons.faqsIcon,
            onTap: () {
              UiUtils.checkUser(
                context: context,
                onNotGuest: () {
                  Navigator.pushNamed(context, Routes.faqsScreen);
                },
              );
            },
          ),
          const SizedBox(height: 12),
          _menuTile(
            context,
            title: 'contactUs'.translate(context),
            iconPath: AppIcons.contactUs,
            onTap: () => Navigator.pushNamed(context, Routes.contactUs),
          ),
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
