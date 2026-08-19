import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/auth/authentication_cubit.dart';
import 'package:eClassify/data/cubits/auth/delete_user_cubit.dart';
import 'package:eClassify/data/cubits/auth/login_cubit.dart';
import 'package:eClassify/data/cubits/chat/chat_list_cubit.dart';
import 'package:eClassify/data/cubits/chat/seller_item_offers_cubit.dart';
import 'package:eClassify/data/cubits/favorite/favorite_cubit.dart';
import 'package:eClassify/data/cubits/item/job_application/fetch_job_application_cubit.dart';
import 'package:eClassify/data/cubits/location/leaf_location_cubit.dart';
import 'package:eClassify/data/cubits/report/item_report_list_cubit.dart';
import 'package:eClassify/data/cubits/subscription/active_subscription_package_cubit.dart';
import 'package:eClassify/data/cubits/system/bottom_nav_cubit.dart';
import 'package:eClassify/data/cubits/system/user_details.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/loading_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileListenersScope extends StatelessWidget {
  const ProfileListenersScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DeleteUserCubit, DeleteUserState>(
          listener: (context, state) async {
            if (state is DeleteUserInProgress) {
              LoadingOverlay.show(context);
            }
            if (state is DeleteUserSuccess) {
              HelperUtils.showSnackBarMessage(
                context,
                'userDeletedSuccessfully'.translate(context),
              );
              await _clearUserSession(context);
              LoadingOverlay.hide();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(Routes.login, (route) => false);
            }
            if (state is DeleteUserFailure) {
              LoadingOverlay.hide();
              HelperUtils.showSnackBarMessage(context, state.errorMessage);
            }
          },
        ),
        BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LogoutInProgress) {
              LoadingOverlay.show(context);
            }
            if (state is LogoutSuccess) {
              context.read<AuthenticationCubit>().signOut();
            }
          },
        ),
        BlocListener<AuthenticationCubit, AuthenticationState>(
          listener: (context, state) async {
            if (state is AuthenticationInitial) {
              await _clearUserSession(context);
              LoadingOverlay.hide();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(Routes.login, (route) => false);
            }
            if (state is AuthenticationUserDeletionFailure) {
              LoadingOverlay.hide();
              if (state.error case final FirebaseAuthException e
                  when e.code == 'requires-recent-login') {
                _handleRequiresRecentLoginEvent(context);
              } else {
                HelperUtils.showSnackBarMessage(
                  context,
                  state.error.toString(),
                );
              }
            }
            if (state is AuthenticationUserDeleted) {
              LoadingOverlay.hide();
              context.read<DeleteUserCubit>().deleteUser();
            }
          },
        ),
        BlocListener<
          ActiveSubscriptionPackageCubit,
          ActiveSubscriptionPackageState
        >(
          listener: (context, state) {
            if (state is ActiveSubscriptionPackageLoading) {
              LoadingOverlay.show(context);
            }
            if (state is ActiveSubscriptionPackageSuccess) {
              LoadingOverlay.hide();
              if (state.activePackages.isNotEmpty) {
                Navigator.of(context).pushNamed(
                  Routes.activePlanScreen,
                  arguments: context.read<ActiveSubscriptionPackageCubit>(),
                );
              } else {
                Navigator.of(context).pushNamed(Routes.subscriptionScreen);
              }
            }
            if (state is ActiveSubscriptionPackageFailure) {
              LoadingOverlay.hide();
              Navigator.of(context).pushNamed(Routes.subscriptionScreen);
            }
          },
        ),
      ],
      child: child,
    );
  }

  Future<void> _clearUserSession(BuildContext context) async {
    AppSession.clear();
    await HiveUtils.clear();
    await HiveUtils.logoutUser(context);
    context.read<UserDetailsCubit>().clear();
    context.read<FavoriteCubit>().resetState();
    context.read<ItemReportListCubit>().clear();
    context.read<FetchJobApplicationCubit>().resetState();
    context.read<LeafLocationCubit>().clear();
    context.read<BuyingChatListCubit>().clear();
    context.read<SellerItemOffersCubit>().clear();
    context.read<BottomNavCubit>().changeTab(BottomTab.home);
  }

  void _handleRequiresRecentLoginEvent(BuildContext context) async {
    final userDetails = HiveUtils.getUserDetails();
    if (userDetails.type == 'phone') {
      final result = await Navigator.pushNamed(
        context,
        Routes.deleteAccountVerification,
      );
      // If deletion was successful, result will be true
      if (result == true) {
        // Account deleted successfully, the verification screen already showed success message
        // Now cleanup and navigate to login
        _clearUserSession(context);
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(Routes.login, (route) => false);
      }
    } else {
      HelperUtils.showSnackBarMessage(
        context,
        'loginRequiredWarning'.translate(context),
      );
      context.read<LoginCubit>().logoutUser();
    }
  }
}
