import 'package:eClassify/ui/screens/home/category_browsing_screen.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/subscription_navigation.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

/// 2.14-style subscription entry: global packages or category-scoped browse.
class SubscriptionCategorySelectionScreen extends StatelessWidget {
  const SubscriptionCategorySelectionScreen({super.key});

  static Route route(RouteSettings routeSettings) {
    return BlurredRouter(
      builder: (_) => const SubscriptionCategorySelectionScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: 'subscription'.translate(context),
        actions: [
          TextButton(
            onPressed: () => SubscriptionNavigation.openActivePlans(context),
            child: CustomText(
              'activePlanLbl'.translate(context),
              color: context.color.territoryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SelectionTile(
            icon: AppIcons.subscription,
            title: 'allPackages'.translate(context),
            subtitle: 'subsctiptionPlane'.translate(context),
            onTap: () => SubscriptionNavigation.openPackagesForCategory(context),
          ),
          const SizedBox(height: 12),
          _SelectionTile(
            icon: AppIcons.categoryIcon,
            title: 'selectCategory'.translate(context),
            subtitle: 'categoriesLbl'.translate(context),
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.categoryBrowsing,
                arguments: {
                  'leafDestination':
                      CategoryBrowsingLeafDestination.subscription,
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  const _SelectionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.color.secondaryColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            children: [
              UiUtils.getSvg(icon, color: context.color.territoryColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      title,
                      fontWeight: FontWeight.w600,
                      color: context.color.textDefaultColor,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      subtitle,
                      fontSize: context.font.small,
                      color: context.color.textLightColor,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.color.textLightColor),
            ],
          ),
        ),
      ),
    );
  }
}
