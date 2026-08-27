import 'package:eClassify/data/cubits/subscription/fetch_user_package_limit_cubit.dart';
import 'package:eClassify/data/model/subscription/subscription_package.dart';
import 'package:eClassify/ui/screens/widgets/bottom_navigation_bar/app_fab.dart';
import 'package:eClassify/utils/dialogs/no_package_available_dialog.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Sells Point: tricolor-ring add listing entry (matches old live home).
class HomeAddListingButton extends StatelessWidget {
  const HomeAddListingButton({super.key});

  static const _plusBlue = Color(0xFF0D47A1);
  static const _saffron = Color(0xFFFF9933);
  static const _green = Color(0xFF138808);

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
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: GestureDetector(
          onTap: () => _onTap(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [_saffron, Colors.white, _green, _saffron],
                    stops: [0.0, 0.33, 0.66, 1.0],
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(Icons.add, color: _plusBlue, size: 28),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'adListing'.translate(context),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
