import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/category/category_browsing_cubit.dart';
import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/ui/screens/widgets/category/category_config_scope.dart';
import 'package:eClassify/ui/screens/widgets/category/category_picker.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubscriptionCategorySelection extends StatelessWidget {
  const SubscriptionCategorySelection({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) {
        return BlocProvider(
          create: (_) => CategoryBrowsingCubit(),
          child: const SubscriptionCategorySelection(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('categories'.translate(context))),
      body: Padding(
        padding: Constant.appContentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GlobalPackageListTile(),
            20.vGap,
            Text(
              'selectCategory'.translate(context),
              style: context.labelLarge,
            ),
            10.vGap,
            Expanded(
              child: CategoryConfigScope(
                subtitleBuilder: (context, category) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // DottedBorder(
                      //   options: CustomPathDottedBorderOptions(
                      //     customPath: (size) {
                      //       return Path()..lineTo(size.width, 0);
                      //     },
                      //     dashPattern: [2, 2],
                      //     strokeCap: StrokeCap.round,
                      //     color: context.colorScheme.outlineVariant,
                      //   ),
                      //   child: SizedBox(width: double.maxFinite, height: 1),
                      // ),
                      Text(
                        '${category.packagesCount ?? 0} ${'packages'.translate(context)}',
                        style: context.labelSmall.withColor(context.mutedColor),
                      ),
                      // 10.vGap,
                    ],
                  );
                },
                child: CategoryPicker(
                  padding: EdgeInsets.only(bottom: Constant.bottomPadding),
                  onSelect: (category, tree) {
                    Navigator.of(context).pushNamed(
                      Routes.subscriptionPackageScreen,
                      arguments: {'category': category},
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlobalPackageListTile extends StatelessWidget {
  const _GlobalPackageListTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(
          Routes.subscriptionPackageScreen,
          arguments: {'category': Category.global()},
        );
      },
      leading: CircleAvatar(
        backgroundColor: context.colorScheme.primary.withValues(alpha: .2),
        radius: 20,
        child: Icon(AppIcons.globe, color: context.colorScheme.primary),
      ),
      title: Text('globalPackage'.translate(context)),
      subtitle: Text('globalPackageDescription'.translate(context)),
      trailing: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(AppIcons.caretRight),
        ),
      ),
    );
  }
}
