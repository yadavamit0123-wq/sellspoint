import 'package:eClassify/data/cubits/subscription/fetch_user_package_limit_cubit.dart';
import 'package:eClassify/data/model/subscription/subscription_package.dart';
import 'package:eClassify/ui/screens/widgets/bottom_navigation_bar/app_fab.dart';
import 'package:eClassify/ui/screens/widgets/tricolor_add_listing_button.dart';
import 'package:eClassify/utils/dialogs/no_package_available_dialog.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Sells Point: tricolor-ring add listing entry (matches old live home).
class HomeAddListingButton extends StatelessWidget {
  const HomeAddListingButton({super.key});

  void _onTap(BuildContext context) {
    UiUtils.checkUser(
      onNotGuest: () {
        if (context.read<FetchUserPackageLimitCubit>().state
            is FetchUserPackageLimitInProgress) {
          return;
        }
        context.read<FetchUserPackageLimitCubit>().fetchUserPackageLimit(
          packageType: SubscriptionPackageType.itemListing,
        );
      },
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FetchUserPackageLimitCubit, FetchUserPackageLimitState>(
      listener: (context, state) {
        if (state is FetchUserPackageLimitFailure) {
          NoPackageAvailableDialog.show(
            context,
            type: SubscriptionPackageType.itemListing,
          );
        }
        if (state is FetchUserPackageLimitInSuccess) {
          AppFab.navigateToAdPosting(context);
        }
      },
      child: TricolorAddListingButton(
        onTap: () => _onTap(context),
        layout: TricolorAddListingLayout.statusStrip,
      ),
    );
  }
}
