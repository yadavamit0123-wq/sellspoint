// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:eClassify/data/cubits/item/video_ads/reel_like_cubit.dart';
import 'package:eClassify/data/cubits/item/video_ads/video_ads_cubit.dart';
import 'package:eClassify/data/cubits/system/bottom_nav_cubit.dart';
import 'package:eClassify/ui/screens/item/video_ads_screen/video_ads_screen.dart';
import 'package:eClassify/ui/screens/widgets/bottom_navigation/custom_bottom_navigation_bar_v214.dart';
import 'package:eClassify/ui/screens/widgets/bottom_navigation/main_fab_v214.dart';
import 'package:eClassify/utils/reel_deep_link_intent.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/chat/get_buyer_chat_users_cubit.dart';
import 'package:eClassify/data/cubits/chat/get_seller_chat_users_cubit.dart';
import 'package:eClassify/data/cubits/item/search_item_cubit.dart';
import 'package:eClassify/data/cubits/subscription/fetch_user_package_limit_cubit.dart';
import 'package:eClassify/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/model/system_settings_model.dart';
import 'package:eClassify/ui/screens/chat/chat_list_screen.dart';
import 'package:eClassify/ui/screens/home/home_screen.dart';
import 'package:eClassify/ui/screens/home/search_screen.dart';
import 'package:eClassify/ui/screens/item/my_items_screen.dart';
import 'package:eClassify/ui/screens/user_profile/profile_screen.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/screens/widgets/maintenance_mode.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/ad_posting_launcher.dart';
import 'package:eClassify/utils/app_update_helper.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/error_filter.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/svg/svg_edit.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

List<ItemModel> myItemList = [];
Map<String, dynamic> searchBody = {};
String selectedCategoryId = "0";
String selectedCategoryName = "";
dynamic selectedCategory;

//this will set when i will visit in any category
dynamic currentVisitingCategoryId = "";
dynamic currentVisitingCategory = "";

List<int> navigationStack = [0];

ScrollController homeScreenController = ScrollController();
//ScrollController chatScreenController = ScrollController();
ScrollController profileScreenController = ScrollController();

List<ScrollController> controllerList = [
  homeScreenController,
  //chatScreenController,
  profileScreenController
];

//
class MainActivity extends StatefulWidget {
  final String from;
  final String? itemSlug;
  static final GlobalKey<MainActivityState> globalKey =
      GlobalKey<MainActivityState>();

  MainActivity({Key? key, required this.from, this.itemSlug})
      : super(key: globalKey);

  @override
  State<MainActivity> createState() => MainActivityState();

  static Route route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return BlurredRouter(
        builder: (_) => MainActivity(
              from: arguments['from'] as String,
              itemSlug: arguments['slug'] as String?,
            ));
  }
}

class MainActivityState extends State<MainActivity>
    with TickerProviderStateMixin {
  PageController pageController = PageController(initialPage: 0);
  int currentTab = 0;
  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final List _pageHistory = [];

  DateTime? currentBackPressTime;

//This is rive file artboards and setting you can check rive package's documentation at [pub.dev]
  bool svgLoaded = false;
  bool isAddMenuOpen = false;
  int rotateAnimationDurationMs = 2000;

  bool isChecked = false;
  SVGEdit svgEdit = SVGEdit();
  bool isBack = false;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  int totalUnread = 0;
  @override
  void initState() {
    super.initState();

    if (HiveUtils.isUserAuthenticated()) {
      context.read<GetBuyerChatListCubit>().fetch(); // Buying chats load
      context.read<GetSellerChatListCubit>().fetch(); // Selling chats load
    }
    initAppLinks();

    rootBundle.loadString(AppIcons.plusIcon).then((value) {
      svgEdit.loadSVG(value);
      svgEdit.change("Path_11299-2",
          attribute: "fill",
          value: svgEdit.flutterColorToHexColor(context.color.territoryColor));
      svgLoaded = true;
      setState(() {});
    });

    FetchSystemSettingsCubit settings =
        context.read<FetchSystemSettingsCubit>();
    if (!const bool.fromEnvironment("force-disable-demo-mode",
        defaultValue: false)) {
      Constant.isDemoModeOn =
          settings.getSetting(SystemSetting.demoMode) ?? false;
    }
    var numberWithSuffix = settings.getSetting(SystemSetting.numberWithSuffix);
    Constant.isNumberWithSuffix = numberWithSuffix == "1" ? true : false;

    ///This will check for update
    if (AppConfig.enableVersionUpdateDialogV214) {
      AppUpdateHelper.checkAndPrompt(context, settings);
    }

//This will init page controller
    initPageController();

    if (widget.itemSlug != null) {
      Navigator.of(context).pushNamed(Routes.adDetailsScreen,
          arguments: {"slug": widget.itemSlug!});
    }
  }

  Future<void> initAppLinks() async {
    _appLinks = AppLinks();

    // Listen for incoming deep links
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        handleDeepLink(uri);
      }
    });
  }

  void handleDeepLink(Uri uri) {
    if (uri.path.contains('/product-details/')) {
      // Navigator.push(
      //   context,
      //   Routes.onGenerateRouted(RouteSettings(name: uri.toString())),
      // );
    } else {
      print('Received deep link: $uri');
      // Handle other deep link paths here if necessary
    }
  }

  void addHistory(int index) {
    List<int> stack = navigationStack;
    if (stack.last != index) {
      stack.add(index);
      navigationStack = stack;
    }

    setState(() {});
  }

  void initPageController() {
    pageController
      ..addListener(() {
        _pageHistory.insert(0, pageController.page);
      });
  }

  void completeProfileCheck() {
    if (HiveUtils.getUserDetails().name == "" ||
        HiveUtils.getUserDetails().email == "") {
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          Navigator.pushReplacementNamed(context, Routes.completeProfile,
              arguments: {"from": "login"});
        },
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ErrorFilter.setContext(context);
    svgEdit.change("Path_11299-2",
        attribute: "fill",
        value: svgEdit.flutterColorToHexColor(context.color.territoryColor));
  }

  @override
  void dispose() {
    pageController.dispose();
    _linkSubscription?.cancel();
    super.dispose();
  }

  Widget _buildVideoAdsPage() {
    final intent = ReelDeepLinkIntent.peek();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => VideoAdsCubit()),
        BlocProvider(create: (_) => ReelLikeCubit()),
      ],
      child: VideoAdsScreen(
        key: ValueKey('reels-${intent.reelId}-${intent.itemId}'),
        reelId: intent.reelId,
        itemId: intent.itemId,
      ),
    );
  }

  /// Rebuild reels tab and switch to it (notification / deep link).
  void applyReelsDeepLink() {
    if (!AppConfig.enableFiveTabNavV214) return;
    setState(() {
      if (pages.length > MainNavigationV214.videoAdsTabIndex) {
        pages[MainNavigationV214.videoAdsTabIndex] = _buildVideoAdsPage();
      }
    });
    onItemTapped(MainNavigationV214.videoAdsTabIndex);
  }

  List<Widget> _buildPages() {
    if (AppConfig.enableFiveTabNavV214) {
      return [
        HomeScreen(from: widget.from),
        ChatListScreen(),
        _buildVideoAdsPage(),
        const ItemsScreen(),
        const ProfileScreen(),
      ];
    }
    return [
      HomeScreen(from: widget.from),
      ChatListScreen(),
      const ItemsScreen(),
      const ProfileScreen(),
    ];
  }

  late List<Widget> pages = _buildPages();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
          context: context, statusBarColor: context.color.primaryColor),
      child: PopScope(
        canPop: isBack,
        onPopInvokedWithResult: (didPop, result) {
          if (currentTab != 0) {
            pageController.animateToPage(0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut);
            setState(() {
              currentTab = 0;
              isBack = false;
            });
            return;
          } else {
            DateTime now = DateTime.now();
            if (currentBackPressTime == null ||
                now.difference(currentBackPressTime!) >
                    const Duration(seconds: 2)) {
              currentBackPressTime = now;

              HelperUtils.showSnackBarMessage(
                  context, "pressAgainToExit".translate(context));

              setState(() {
                isBack = false;
              });
              return;
            }
            setState(() {
              isBack = true;
            });
            return;
          }
        },
        child: Scaffold(
          backgroundColor: context.color.primaryColor,
          floatingActionButton:
              _showV214Fab ? const MainFabV214() : null,
          floatingActionButtonLocation: _showV214Fab
              ? FloatingActionButtonLocation.centerDocked
              : null,
          bottomNavigationBar: Constant.maintenanceMode == "1"
              ? null
              : _showV214Fab
                  ? CustomBottomNavigationBarV214(
                      currentIndex: currentTab,
                      onTap: onItemTapped,
                    )
                  : bottomBar(),
          body: Stack(
            children: <Widget>[
              PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: pageController,
                //onPageChanged: onItemSwipe,
                children: pages,
              ),
              if (Constant.maintenanceMode == "1") MaintenanceMode()
            ],
          ),
        ),
      ),
    );
  }

  bool get _showV214Fab =>
      AppConfig.enableFiveTabNavV214 &&
      (currentTab == MainNavigationV214.homeTabIndex ||
          currentTab == MainNavigationV214.myAdsTabIndex);

  void onItemTapped(int index) {
    if (AppConfig.enableFiveTabNavV214 && index == currentTab) {
      context.read<BottomNavCubit>().changeTabByIndex(index);
      return;
    }

    addHistory(index);

    FocusManager.instance.primaryFocus?.unfocus();

    if (index != 1) {
      context.read<SearchItemCubit>().clearSearch();

      if (SearchScreenState.searchController.hasListeners) {
        SearchScreenState.searchController.text = "";
      }
    }
    searchBody = {};
    final authTabs = AppConfig.enableFiveTabNavV214
        ? {1, 3}
        : {1, 2};
    if (authTabs.contains(index)) {
      UiUtils.checkUser(
          onNotGuest: () {
            currentTab = index;
            pageController.jumpToPage(currentTab);
            setState(
              () {},
            );
          },
          context: context);
    } else {
      currentTab = index;
      pageController.jumpToPage(currentTab);

      setState(() {});
    }

    if (AppConfig.enableFiveTabNavV214) {
      context.read<BottomNavCubit>().changeTabByIndex(index);
    }
  }

  BottomAppBar bottomBar() {
    return BottomAppBar(
      color: context.color.secondaryColor,
      shape: const CircularNotchedRectangle(),
      child: Container(
        color: context.color.secondaryColor,
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              buildBottomNavigationbarItem(0, AppIcons.homeNav, AppIcons.homeNavActive, "homeTab".translate(context)),
             SizedBox(width: 15,),
              BlocBuilder<GetBuyerChatListCubit, GetBuyerChatListState>(
                builder: (context, buyerState) {
                  return BlocBuilder<GetSellerChatListCubit, GetSellerChatListState>(
                    builder: (context, sellerState) {
                      int buyerUnread = 0;
                      int sellerUnread = 0;

                      // Buying unread calculate
                      if (buyerState is GetBuyerChatListSuccess) {
                        buyerUnread = buyerState.chatedUserList.fold(0, (sum, user) => sum + (user.unreadCount ?? 0));
                      }

                      // Selling unread calculate
                      if (sellerState is GetSellerChatListSuccess) {
                        sellerUnread = sellerState.chatedUserList.fold(0, (sum, user) => sum + (user.unreadCount ?? 0));
                      }

                      totalUnread = buyerUnread + sellerUnread; // Total

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          buildBottomNavigationBarItemNoExpanded(1, AppIcons.chatNav, AppIcons.chatNavActive, "chat".translate(context)),
                          if (totalUnread > 0)
                            Positioned(
                              top: -4,
                              right: 5,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
              SizedBox(width: 15,),

              Expanded(
                child: BlocListener<FetchUserPackageLimitCubit, FetchUserPackageLimitState>(
                    listener: (context, state) {
                      if (state is FetchUserPackageLimitFailure) {
                        UiUtils.noPackageAvailableDialog(context);
                      }
                      if (state is FetchUserPackageLimitInSuccess) {
                        AdPostingLauncher.openCategoryStep(context);
                      }
                    },
                    child: Transform(
                      transform: Matrix4.identity()..translate(0.toDouble(), -20),
                      child: InkWell(
                        onTap: () async {
                          //TODO:TEMP
                          UiUtils.checkUser(
                              onNotGuest: () {
                                context
                                    .read<FetchUserPackageLimitCubit>()
                                    .fetchUserPackageLimit(
                                        packageType: "item_listing");
                              },
                              context: context);
                        },
                        child: SizedBox(
                          width: 53,
                          height: 58,
                          child: svgLoaded == false
                              ? Container()
                              : SvgPicture.string(
                                  svgEdit.toSVGString() ?? "",
                                ),
                        ),
                      ),
                    )),
              ),
              buildBottomNavigationbarItem(2, AppIcons.myAdsNav, AppIcons.myAdsNavActive, "myAdsTab".translate(context)),
              buildBottomNavigationbarItem(3, AppIcons.profileNav, AppIcons.profileNavActive, "profileTab".translate(context))
            ]),
      ),
    );
  }

  Widget buildBottomNavigationbarItem(
    int index,
    String svgImage,
    String activeSvg,
    String title,
  ) {
    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () => onItemTapped(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (currentTab == index) ...{
                UiUtils.getSvg(activeSvg),
              } else ...{
                UiUtils.getSvg(svgImage,
                    color: context.color.textLightColor.darken(30)),
              },
              CustomText(title,
                  textAlign: TextAlign.center,
                  color: currentTab == index
                      ? context.color.textDefaultColor
                      : context.color.textLightColor.darken(30)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBottomNavigationBarItemNoExpanded(
    int index,
    String svgImage,
    String activeSvg,
    String title,
  ) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () => onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (currentTab == index) ...{
              UiUtils.getSvg(activeSvg),
            } else ...{
              UiUtils.getSvg(svgImage,
                  color: context.color.textLightColor.darken(30)),
            },
            CustomText(title,
                textAlign: TextAlign.center,
                color: currentTab == index
                    ? context.color.textDefaultColor
                    : context.color.textLightColor.darken(30)),
          ],
        ),
      ),
    );
  }
}
