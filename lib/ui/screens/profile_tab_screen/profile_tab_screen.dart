import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app/sells_point_modules.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/auth/authentication_cubit.dart';
import 'package:eClassify/data/cubits/auth/login_cubit.dart';
import 'package:eClassify/data/cubits/auth/user_profile_cubit.dart';
import 'package:eClassify/data/cubits/followers/follow_user_list_cubit.dart';
import 'package:eClassify/data/cubits/seller/fetch_verification_request_cubit.dart';
import 'package:eClassify/data/cubits/subscription/active_subscription_package_cubit.dart';
import 'package:eClassify/data/cubits/system/app_theme_cubit.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/models/menu_item.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/models/menu_item_action.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/models/menu_section.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/dialogs/delete_account_dialog.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/dialogs/logout_dialog.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/menu_section_widget.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/profile_header.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/profile_listeners_scope.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/user_verification_card.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen>
    with AutomaticKeepAliveClientMixin<ProfileTabScreen> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isAuthenticated = HiveUtils.isUserAuthenticated();
    final showLanguageMenu = Constant.systemSettings.languages.length > 1;

    final menuSections = [
      MenuSection(
        items: [
          MenuItem(
            icon: AppIcons.trendUp,
            title: 'myFeaturedAds',
            action: ScreenPushAction(
              route: Routes.myAdvertisment,
              guarded: true,
            ),
          ),
          MenuItem(
            icon: AppIcons.heart,
            title: 'favorites',
            action: ScreenPushAction(
              route: Routes.favoritesScreen,
              guarded: true,
            ),
          ),
          MenuItem(
            icon: AppIcons.userGear,
            title: 'myReview',
            action: ScreenPushAction(
              route: Routes.myReviewsScreen,
              guarded: true,
            ),
          ),
          MenuItem(
            icon: AppIcons.notepad,
            title: 'jobApplications',
            action: ScreenPushAction(
              route: Routes.jobApplicationList,
              guarded: true,
            ),
          ),
        ],
      ),
      MenuSection(
        items: [
          MenuItem(
            icon: AppIcons.sketchLogo,
            title: 'subscription',
            action: CustomAction(
              onTap: () async {
                if (isAuthenticated) {
                  context.read<ActiveSubscriptionPackageCubit>().getPackages();
                } else {
                  Navigator.pushNamed(context, Routes.subscriptionScreen);
                }
              },
            ),
          ),
          MenuItem(
            icon: AppIcons.clockCounterClockwise,
            title: 'transactionHistory',
            action: ScreenPushAction(
              route: Routes.transactionHistory,
              guarded: true,
            ),
          ),
          if (SellsPointModules.wallet)
            MenuItem(
              icon: AppIcons.wallet,
              title: 'myWallet',
              action: ScreenPushAction(
                route: Routes.myWalletScreen,
                guarded: true,
              ),
            ),
          if (SellsPointModules.referralProgram)
            MenuItem(
              icon: AppIcons.gift,
              title: 'referralProgram',
              action: ScreenPushAction(
                route: Routes.referralProgramScreen,
                guarded: true,
              ),
            ),
        ],
      ),
      MenuSection(
        items: [
          if (showLanguageMenu)
            MenuItem(
              icon: AppIcons.translate,
              title: 'language',
              action: ScreenPushAction(route: Routes.languageListScreenRoute),
            ),
          MenuItem(
            icon: AppIcons.moon,
            title: 'darkTheme',
            showTrailing: true,
            action: CustomAction(
              onTap: () async {
                context.read<AppThemeCubit>().toggleTheme();
              },
            ),
            trailing: BlocBuilder<AppThemeCubit, ThemeMode>(
              builder: (context, theme) {
                return Switch(
                  trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                  activeTrackColor: context.colorScheme.primary,
                  inactiveTrackColor: context.colorScheme.surface,
                  value: theme == ThemeMode.dark,
                  onChanged: (value) {
                    context.read<AppThemeCubit>().toggleTheme();
                  },
                );
              },
            ),
          ),
          MenuItem(
            icon: AppIcons.bell,
            title: 'notifications',
            action: ScreenPushAction(
              route: Routes.notificationPage,
              guarded: true,
            ),
          ),
        ],
      ),
      MenuSection(
        items: [
          MenuItem(
            icon: AppIcons.star,
            title: 'rateUs',
            action: CustomAction(onTap: () async => rateUs()),
          ),
          MenuItem(
            icon: AppIcons.shareNetwork,
            title: 'shareApp',
            action: CustomAction(
              onTap: () async {
                await shareApp(context);
              },
            ),
          ),
        ],
      ),
      MenuSection(
        items: [
          MenuItem(
            icon: AppIcons.article,
            title: 'blogs',
            action: ScreenPushAction(route: Routes.blogsScreen),
          ),
          MenuItem(
            icon: AppIcons.headset,
            title: 'helpAndSupport',
            showTrailing: true,
            action: ScreenPushAction(route: Routes.helpAndSupportScreen),
          ),
        ],
      ),
      MenuSection(
        items: [
          MenuItem(
            icon: AppIcons.question,
            title: 'legalInformation',
            showTrailing: true,
            action: ScreenPushAction(route: Routes.legalInformationScreen),
          ),
        ],
      ),
      if (Constant.isUpdateAvailable)
        MenuSection(
          items: [
            MenuItem(
              icon: AppIcons.arrowsClockwise,
              title: 'update'.translate(context),
              trailing: Text('v2.14.0${Constant.newVersionNumber}'),
              showTrailing: true,
              action: CustomAction(
                onTap: () async {
                  final appUrl = Constant.systemSettings.storeLink;
                  final uri = Uri.tryParse(appUrl ?? '');
                  if (uri != null) {
                    launchUrl(uri);
                  }
                },
              ),
            ),
          ],
        ),
      if (isAuthenticated)
        MenuSection(
          items: [
            MenuItem(
              icon: AppIcons.signOut,
              title: 'logout',
              action: CustomAction(
                onTap: () async {
                  final shouldLogout =
                      await LogoutDialog.show(context) ?? false;
                  if (shouldLogout) {
                    context.read<LoginCubit>().logoutUser();
                  }
                },
              ),
            ),
          ],
        ),
    ];

    return ProfileListenersScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text('myProfile'.translate(context)),
          automaticallyImplyLeading: false,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            if (!isAuthenticated) return;
            context.read<VerificationRequestCubit>().fetchVerificationRequest();
            context.read<UserProfileCubit>().getUserProfile();
            context.read<FollowingListCubit>().getUsers();
            context.read<FollowersListCubit>().getUsers();
          },
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: Constant.appContentPadding.copyWith(
              bottom: kBottomNavigationBarHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 20,
              children: [
                ProfileHeader(),
                if (isAuthenticated) UserVerificationCard(),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: menuSections.length,
                    separatorBuilder: (_, _) => 16.vGap,
                    itemBuilder: (context, index) =>
                        MenuSectionWidget(section: menuSections[index]),
                  ),
                ),
                if (isAuthenticated)
                  Center(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        textStyle: context.labelLarge,
                      ),
                      onPressed: () async {
                        if (Constant.isDemoModeOn) {
                          HelperUtils.showSnackBarMessage(
                            context,
                            'demoWarning'.translate(context),
                          );
                        } else {
                          final shouldDelete =
                              await DeleteAccountDialog.show(context) ?? false;
                          if (shouldDelete) {
                            context.read<AuthenticationCubit>().deleteUser();
                          }
                        }
                      },
                      label: Text('deleteAccount'.translate(context)),
                      icon: Icon(AppIcons.trash),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> shareApp(BuildContext context) async {
    final appUrl = Constant.systemSettings.storeLink;
    final sharePosition = Rect.fromLTWH(
      0,
      0,
      context.screenWidth,
      context.screenHeight / 2,
    );
    await SharePlus.instance.share(
      ShareParams(
        text:
        '${AppConfig.applicationName}\n$appUrl\n${"shareApp".translate(
            context)}',
        sharePositionOrigin: sharePosition,
      ),
    );
  }

  Future<void> rateUs() {
    final appStoreId = Constant.systemSettings.storeLink
        ?.split('/')
        .lastOrNull;
    return InAppReview.instance.openStoreListing(appStoreId: appStoreId);
  }
}
