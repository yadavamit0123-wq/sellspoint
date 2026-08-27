import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/subscription/fetch_user_package_limit_cubit.dart';
import 'package:eClassify/data/model/subscription/subscription_package.dart';
import 'package:eClassify/ui/screens/widgets/hexagon_shape_border.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/dialogs/no_package_available_dialog.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

enum FabType { diamond, round, ellipse, svg, material }

class AppFab extends StatelessWidget {
  const AppFab({
    this.type = FabType.diamond,
    this.borderRadius = 20,
    this.svgAsset,
    this.svgSize = 80,
    super.key,
  }) : assert(
         type != FabType.svg || svgAsset != null,
         'svgAsset must not be null when type is FabType.svg',
       );
  final FabType type;
  final double borderRadius;
  final String? svgAsset;
  final double? svgSize;

  ShapeBorder? get _shapeBorder {
    return switch (type) {
      FabType.diamond => HexagonBorderShape(cornerRadius: 5),
      FabType.round => CircleBorder(),
      FabType.ellipse => RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      FabType.svg => null,
      FabType.material => null,
    };
  }

  static void navigateToAdPosting(BuildContext context) {
    Navigator.pushNamed(context, Routes.adPostingScreen);
  }

  void _onPressed(BuildContext context) {
    UiUtils.checkUser(
      onNotGuest: () {
        // Instead of calling the api everytime the button is pressed we can optimize
        // it to check whether the state is already success so we can directly navigate
        // but doing so will remove the correctness if the user's plan expired while the app
        // was open, then this will allow the item to be added or maybe not if the api
        // has such checks. Need to confirm.
        //
        // In either case, calling api on every button click is not ideal solution for this
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
    Widget child;

    if (type == FabType.svg) {
      if (svgAsset == null) {
        throw Exception('svgAsset must not be null when type is FabType.svg');
      }
      child = GestureDetector(
        onTap: () => _onPressed(context),
        child: SvgPicture.asset(svgAsset!, height: svgSize, width: svgSize),
      );
    } else {
      child = FloatingActionButton(
        onPressed: () => _onPressed(context),
        shape: _shapeBorder,
        child: Icon(AppIcons.plus),
      );
    }

    return BlocListener<FetchUserPackageLimitCubit, FetchUserPackageLimitState>(
      listener: (context, state) {
        if (state is FetchUserPackageLimitFailure) {
          NoPackageAvailableDialog.show(
            context,
            type: SubscriptionPackageType.itemListing,
          );
        }
        if (state is FetchUserPackageLimitInSuccess) {
          navigateToAdPosting(context);
        }
      },
      child: child,
    );
  }
}
