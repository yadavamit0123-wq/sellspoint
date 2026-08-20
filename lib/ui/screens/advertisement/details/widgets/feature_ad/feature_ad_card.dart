import 'package:eClassify/data/cubits/item/create_featured_ad_cubit.dart';
import 'package:eClassify/data/cubits/item/fetch_item_cubit.dart';
import 'package:eClassify/data/cubits/subscription/fetch_user_package_limit_cubit.dart';
import 'package:eClassify/data/model/subscription/subscription_package.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_assets.dart';
import 'package:eClassify/utils/color_mappers/primary_color_mapper.dart';
import 'package:eClassify/utils/dialogs/no_package_available_dialog.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeatureAdCard extends StatelessWidget {
  const FeatureAdCard({required this.itemId, super.key});

  final int itemId;

  Future<bool?> _showConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'createFeaturedAd'.translate(context),
            style: context.titleMedium,
            textAlign: TextAlign.center,
          ),
          content: Text(
            'areYouSureToCreateThisItemAsAFeaturedAd'.translate(context),
            textAlign: TextAlign.center,
            style: context.bodyMedium,
          ),
          actions: [
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colorScheme.surface,
                      foregroundColor: context.colorScheme.onSurface,
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('cancel'.translate(context)),
                  ),
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('yes'.translate(context)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CreateFeaturedAdCubit, CreateFeaturedAdState>(
          listener: (context, state) {
            if (state is CreateFeaturedAdInSuccess) {
              HelperUtils.showSnackBarMessage(
                context,
                state.responseMessage.toString(),
                messageDuration: 3,
              );
              context.read<FetchItemCubit>().fetchItem(itemId: itemId);
            }
            if (state is CreateFeaturedAdFailure) {
              HelperUtils.showSnackBarMessage(
                context,
                state.error.toString(),
                messageDuration: 3,
              );
            }
          },
        ),
        BlocListener<FetchUserPackageLimitCubit, FetchUserPackageLimitState>(
          listener: (context, state) async {
            if (state is FetchUserPackageLimitFailure) {
              NoPackageAvailableDialog.show(
                context,
                type: SubscriptionPackageType.featuredAds,
              );
            }
            if (state is FetchUserPackageLimitInSuccess) {
              final shouldFeature =
                  await _showConfirmationDialog(context) ?? false;
              if (shouldFeature) {
                context.read<CreateFeaturedAdCubit>().createFeaturedAds(
                  itemId: itemId,
                );
              }
            }
          },
        ),
      ],
      child: Card.filled(
        color: context.colorScheme.primary.withValues(alpha: .1),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            spacing: 16,
            children: [
              CustomImage(
                src: AppAssets.illustrators.createAdd,
                size: Size(64, 76),
                svgColorMapper: PrimaryColorMapper(context.colorScheme.primary),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Text(
                      'featureAdDescription'.translate(context),
                      style: context.titleMedium,
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: Size.fromHeight(40),
                      ),
                      onPressed: () {
                        context
                            .read<FetchUserPackageLimitCubit>()
                            .fetchUserPackageLimit(
                              packageType: SubscriptionPackageType.featuredAds,
                            );
                      },
                      child: Text('createFeaturedAd'.translate(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
