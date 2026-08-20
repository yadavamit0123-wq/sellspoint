import 'package:eClassify/data/cubits/custom_field/custom_fields_cubit.dart';
import 'package:eClassify/data/cubits/item/ad_posting_cubit.dart';
import 'package:eClassify/data/model/item/ad_item_type.dart';
import 'package:eClassify/data/model/subscription/subscription_package.dart';
import 'package:eClassify/ui/screens/widgets/category/category_config_scope.dart';
import 'package:eClassify/ui/screens/widgets/category/category_picker.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/dialogs/no_package_available_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategorySelectionStep extends StatelessWidget {
  const CategorySelectionStep({super.key});

  @override
  Widget build(BuildContext context) {
    final adType = context.read<AdPostingCubit>().state.adPostingData.adType;
    return Padding(
      padding: Constant.appContentPadding,
      child: CategoryConfigScope(
        isDisabled: (category) {
          return adType == AdItemType.regularAd
              ? !category.canPostRegularAds
              : !category.canPostVideoAds;
        },
        onDisabledTap: (category) {
          NoPackageAvailableDialog.show(
            context,
            type: SubscriptionPackageType.itemListing,
            adType: adType ?? AdItemType.regularAd,
            category: category,
          );
        },
        child: CategoryPicker(
          showAllOption: false,
          showBreadcrumbs: false,
          resetSelection: false,
          onSelect: (category, hierarchy) {
            context.read<CustomFieldsCubit>().getCustomFields(
              categoryId: category.id,
            );
            context.read<AdPostingCubit>()
              ..updateData((current) => current.copyWith(category: category))
              ..nextStep();
          },
        ),
      ),
    );
  }
}
