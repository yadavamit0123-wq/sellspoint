import 'package:eClassify/app/routes.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const SubscriptionScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('subscription'.translate(context))),
      body: Theme(
        data: Theme.of(context).copyWith(
          iconButtonTheme: IconButtonThemeData(
            style: IconButton.styleFrom(
              backgroundColor: context.colorScheme.surface,
              disabledBackgroundColor: context.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              iconSize: 20,
            ),
          ),
        ),
        child: Padding(
          padding: Constant.appContentPadding.copyWith(top: 20),
          child: Column(
            spacing: 10,
            // Consider creating a DTO and defining static list of instances
            // instead of continuing this way
            children: [
              if (!Constant.systemSettings.isFreeAdListingEnabled)
                ListTile(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.subscriptionCategorySelectionScreen,
                    );
                  },
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: context.colorScheme.primary.withValues(
                      alpha: .2,
                    ),
                    foregroundColor: context.colorScheme.primary,
                    child: PhosphorIcon(AppIcons.gridFour),
                  ),
                  title: Text('adListingPlan'.translate(context), maxLines: 1),
                  subtitle: Text(
                    'adListingPlanDescription'.translate(context),
                    maxLines: 2,
                  ),
                  trailing: IconButton.filled(
                    onPressed: null,
                    icon: Icon(AppIcons.caretRight),
                  ),
                ),
              ListTile(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.subscriptionPackageScreen,
                  );
                },
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: context.colorScheme.primary.withValues(
                    alpha: .2,
                  ),
                  foregroundColor: context.colorScheme.primary,
                  child: Icon(AppIcons.trendUp),
                ),
                title: Text('featuredAdsPlan'.translate(context), maxLines: 1),
                subtitle: Text(
                  'featuredAdsPlanDescription'.translate(context),
                  maxLines: 2,
                ),
                trailing: IconButton.filled(
                  onPressed: null,
                  icon: Icon(AppIcons.caretRight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
