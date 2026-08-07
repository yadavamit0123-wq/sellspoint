import 'package:eClassify/data/cubits/subscription/fetch_user_package_limit_cubit.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/ad_posting_launcher.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Center FAB for 2.14 shell — post ad after package limit check.
class MainFabV214 extends StatelessWidget {
  const MainFabV214({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FetchUserPackageLimitCubit, FetchUserPackageLimitState>(
      listener: (context, state) {
        if (state is FetchUserPackageLimitFailure) {
          UiUtils.noPackageAvailableDialog(context);
        }
        if (state is FetchUserPackageLimitInSuccess) {
          AdPostingLauncher.openCategoryStep(context);
        }
      },
      child: FloatingActionButton(
        onPressed: () {
          UiUtils.checkUser(
            onNotGuest: () {
              context.read<FetchUserPackageLimitCubit>().fetchUserPackageLimit(
                    packageType: 'item_listing',
                  );
            },
            context: context,
          );
        },
        backgroundColor: context.color.territoryColor,
        elevation: 4,
        child: Icon(Icons.add, color: context.color.secondaryColor, size: 32),
      ),
    );
  }
}
