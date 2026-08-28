// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/app_update_cubit.dart';
import 'package:eClassify/data/cubits/system/bottom_nav_cubit.dart';
import 'package:eClassify/ui/listeners/notification_provider.dart';
import 'package:eClassify/ui/screens/chat/inbox/chat_list_screen.dart';
import 'package:eClassify/ui/screens/home/home_screen.dart';
import 'package:eClassify/ui/screens/item/my_items_screen.dart';
import 'package:eClassify/ui/screens/item/video_ads_screen/video_ads_screen.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/profile_tab_screen.dart';
import 'package:eClassify/ui/screens/widgets/bottom_navigation_bar/app_fab.dart';
import 'package:eClassify/ui/screens/widgets/bottom_navigation_bar/custom_bottom_navigation_bar.dart';
import 'package:eClassify/ui/screens/widgets/version_update_dialog.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainActivity extends StatefulWidget {
  final String from;
  final String? itemSlug;
  final String? sellerId;

  MainActivity({Key? key, required this.from, this.itemSlug, this.sellerId})
    : super(key: key);

  @override
  State<MainActivity> createState() => MainActivityState();

  static Route route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return MaterialPageRoute(
      builder: (_) => NotificationProvider(
        child: BlocProvider(
          create: (context) => AppUpdateCubit(),
          child: MainActivity(
            from: arguments['from'] as String,
            itemSlug: arguments['slug'] as String?,
            sellerId: arguments['sellerId'] as String?,
          ),
        ),
      ),
    );
  }
}

class MainActivityState extends State<MainActivity> {
  final PageController _pageController = PageController();

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    ///This will check for update
    versionCheck();

    if (widget.itemSlug != null) {
      Navigator.of(context).pushNamed(
        Routes.adDetailsScreen,
        arguments: {"slug": widget.itemSlug!},
      );
    }
    if (widget.sellerId != null) {
      Navigator.pushNamed(
        context,
        Routes.sellerProfileScreen,
        arguments: {"sellerId": int.parse(widget.sellerId!)},
      );
    }
  }

  void versionCheck() async {
    final remoteVersion = Constant.systemSettings.version;
    final forceUpdate = Constant.systemSettings.forceUpdate;

    context.read<AppUpdateCubit>().checkForUpdates(
      required: remoteVersion,
      forceUpdate: forceUpdate,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (context.read<BottomNavCubit>().state != BottomTab.home) {
          context.read<BottomNavCubit>().changeTab(BottomTab.home);
        } else {
          if (_timer == null) {
            _timer = Timer(const Duration(seconds: 2), () {
              _timer?.cancel();
              _timer = null;
            });
            HelperUtils.showSnackBarMessage(
              context,
              "pressAgainToExit".translate(context),
              isFloating: true,
            );
          } else {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: CustomBottomNavigationBar(),
        body: Stack(
          children: [
            BlocListener<AppUpdateCubit, AppUpdateState>(
              listener: (context, state) {
                if (state is AppUpdateAvailable) {
                  VersionUpdateDialog.show(
                    context,
                    availableVersion: state.required,
                    isForceUpdate: state.isMandatory,
                  );
                }
              },
              child: BlocListener<BottomNavCubit, BottomTab>(
                listener: (context, state) {
                  _pageController.jumpToPage(state.index);
                },
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    HomeScreen(from: widget.from),
                    const ChatListScreen(),
                    const VideoAdsScreen(),
                    const ItemsScreen(),
                    const ProfileTabScreen(),
                  ],
                ),
              ),
            ),
            BlocBuilder<BottomNavCubit, BottomTab>(
              builder: (context, state) {
                if (state case BottomTab.home || BottomTab.myAds) {
                  return PositionedDirectional(
                    end: 8,
                    bottom:
                        kBottomNavigationBarHeight +
                        MediaQuery.paddingOf(context).bottom +
                        4,
                    child: AppFab(type: FabType.tricolor),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
