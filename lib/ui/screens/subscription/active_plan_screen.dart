import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/subscription/active_subscription_package_cubit.dart';
import 'package:eClassify/data/model/subscription_pacakage_model.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_data_found.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/reel_subscription_refresh.dart';
import 'package:eClassify/utils/subscription_navigation.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActivePlanScreen extends StatefulWidget {
  const ActivePlanScreen({super.key});

  static Route route(RouteSettings routeSettings) {
    return BlurredRouter(
      builder: (_) => BlocProvider(
        create: (_) => ActiveSubscriptionPackageCubit()..fetchActivePackages(),
        child: const ActivePlanScreen(),
      ),
    );
  }

  @override
  State<ActivePlanScreen> createState() => _ActivePlanScreenState();
}

class _ActivePlanScreenState extends State<ActivePlanScreen> {
  @override
  void initState() {
    super.initState();
    ReelSubscriptionRefresh.activePlansRevision.addListener(_refetchActivePlans);
  }

  @override
  void dispose() {
    ReelSubscriptionRefresh.activePlansRevision
        .removeListener(_refetchActivePlans);
    super.dispose();
  }

  void _refetchActivePlans() {
    if (!mounted) return;
    context.read<ActiveSubscriptionPackageCubit>().fetchActivePackages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: 'activePlans'.translate(context),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: UiUtils.buildButton(
          context,
          onPressed: () => SubscriptionNavigation.openPackageCatalog(context),
          buttonTitle: 'browseAllPackages'.translate(context),
        ),
      ),
      body: BlocBuilder<ActiveSubscriptionPackageCubit,
          ActiveSubscriptionPackageState>(
        builder: (context, state) {
          if (state is ActiveSubscriptionPackageInProgress ||
              state is ActiveSubscriptionPackageInitial) {
            return UiUtils.progress();
          }
          if (state is ActiveSubscriptionPackageFailure) {
            return Center(child: CustomText(state.message));
          }
          if (state is ActiveSubscriptionPackageSuccess) {
            if (state.activePackages.isEmpty) {
              return NoDataFound(onTap: () {
                context
                    .read<ActiveSubscriptionPackageCubit>()
                    .fetchActivePackages();
              });
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.activePackages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _ActivePackageCard(
                  package: state.activePackages[index],
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ActivePackageCard extends StatelessWidget {
  const _ActivePackageCard({required this.package});

  final SubscriptionPackageModel package;

  bool get _showReelBadge =>
      AppConfig.enableActivePlanReelBadgeV214 &&
      package.type == 'item_listing' &&
      package.isReelAllowed == true;

  bool get _showGetReelsCta =>
      AppConfig.enableActivePlanGetReelsCtaV214 &&
      package.type == 'item_listing' &&
      package.isReelAllowed != true;

  String _typeLabel(BuildContext context) {
    if (package.type == 'advertisement') {
      return 'featuredAdsLbl'.translate(context);
    }
    return 'adsListing'.translate(context);
  }

  @override
  Widget build(BuildContext context) {
    final purchase = package.userPurchasedPackages?.isNotEmpty == true
        ? package.userPurchasedPackages!.first
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.color.territoryColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            package.name ?? '',
            fontWeight: FontWeight.w700,
            fontSize: context.font.larger,
            color: context.color.textDefaultColor,
          ),
          const SizedBox(height: 6),
          CustomText(
            _typeLabel(context),
            color: context.color.territoryColor,
            fontWeight: FontWeight.w500,
          ),
          if (_showReelBadge) ...[
            const SizedBox(height: 8),
            const _ReelIncludedChip(),
          ],
          if (_showGetReelsCta) ...[
            const SizedBox(height: 12),
            UiUtils.buildButton(
              context,
              height: 40,
              radius: 10,
              buttonTitle: 'activePlanGetReelsCta'.translate(context),
              buttonColor: context.color.territoryColor,
              textColor: context.color.secondaryColor,
              onPressed: () {
                SubscriptionNavigation.openItemListingPackagesForReels(context);
              },
            ),
          ],
          if (purchase != null) ...[
            const SizedBox(height: 12),
            if (purchase.startDate != null && purchase.startDate!.isNotEmpty)
              CustomText(
                '${'packageStartedOn'.translate(context)} ${purchase.startDate}',
                fontSize: context.font.small,
                color: context.color.textLightColor,
              ),
            if (purchase.endDate != null && purchase.endDate!.isNotEmpty)
              CustomText(
                '${'andPackageWillEndOn'.translate(context)} ${purchase.endDate}',
                fontSize: context.font.small,
                color: context.color.textLightColor,
              ),
            if (purchase.remainingItemLimit != null &&
                purchase.remainingItemLimit!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: CustomText(
                  purchase.remainingItemLimit!,
                  fontWeight: FontWeight.w600,
                  color: context.color.textDefaultColor,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ReelIncludedChip extends StatelessWidget {
  const _ReelIncludedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.color.territoryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.color.territoryColor.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.videocam_outlined,
            size: 16,
            color: context.color.territoryColor,
          ),
          const SizedBox(width: 6),
          CustomText(
            'subscriptionReelIncluded'.translate(context),
            fontSize: context.font.small,
            fontWeight: FontWeight.w600,
            color: context.color.territoryColor,
          ),
        ],
      ),
    );
  }
}
