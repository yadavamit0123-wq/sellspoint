import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/subscription/active_subscription_package_cubit.dart';
import 'package:eClassify/data/model/subscription/subscription_package.dart';
import 'package:eClassify/ui/screens/subscription/widgets/package_widget.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_data_found.dart';
import 'package:eClassify/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActivePlanScreen extends StatelessWidget {
  const ActivePlanScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments;
    final activePlanCubit = args as ActiveSubscriptionPackageCubit?;

    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => activePlanCubit == null
          ? BlocProvider(
              create: (_) => ActiveSubscriptionPackageCubit(),
              child: ActivePlanScreen(),
            )
          : BlocProvider.value(
              value: activePlanCubit,
              child: ActivePlanScreen(),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('activePlans'.translate(context))),
      bottomNavigationBar: SafeArea(
        minimum: Constant.safeAreaMinimumPadding,
        child: FilledButton(
          style: FilledButton.styleFrom(minimumSize: Size.fromHeight(48)),
          onPressed: () {
            Navigator.of(context).pushNamed(Routes.subscriptionScreen);
          },
          child: Text('browseAllPackages'.translate(context)),
        ),
      ),
      body:
          BlocBuilder<
            ActiveSubscriptionPackageCubit,
            ActiveSubscriptionPackageState
          >(
            builder: (context, state) {
              if (state is ActiveSubscriptionPackageInitial) {
                context.read<ActiveSubscriptionPackageCubit>().getPackages();
              }
              if (state is ActiveSubscriptionPackageFailure) {
                return SomethingWentWrong();
              }
              if (state is ActiveSubscriptionPackageSuccess) {
                if (state.activePackages.isEmpty) {
                  return NoDataFound();
                }
                final packages = state.activePackages;
                return ListView.separated(
                  padding: Constant.appContentPadding.copyWith(
                    top: 40,
                    bottom: 20,
                  ),
                  itemCount: packages.length,
                  itemBuilder: (context, index) => PackageWidget(
                    package: packages[index],
                    activePlanCapLabel: switch (packages[index].type) {
                      SubscriptionPackageType.featuredAds =>
                        'featuredAds'.translate(context),
                      SubscriptionPackageType.itemListing =>
                        'adsPackage'.translate(context),
                    },
                  ),
                  separatorBuilder: (context, index) => 30.vGap,
                );
              }
              return Center(child: UiUtils.progress());
            },
          ),
    );
  }
}
