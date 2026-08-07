// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/location/leaf_location_cubit.dart';
import 'package:eClassify/data/cubits/category/fetch_category_cubit.dart';
import 'package:eClassify/data/cubits/chat/blocked_users_list_cubit.dart';
import 'package:eClassify/data/cubits/chat/get_buyer_chat_users_cubit.dart';
import 'package:eClassify/data/cubits/favorite/favorite_cubit.dart';
import 'package:eClassify/data/cubits/home/fetch_home_all_items_cubit.dart';
import 'package:eClassify/data/cubits/home/fetch_home_screen_cubit.dart';
import 'package:eClassify/data/cubits/home/popular_categories_cubit.dart';
import 'package:eClassify/data/cubits/system/bottom_nav_cubit.dart';
import 'package:eClassify/utils/bottom_nav_tap_listener.dart';
import 'package:eClassify/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:eClassify/data/cubits/system/get_api_keys_cubit.dart';
import 'package:eClassify/data/helper/designs.dart';
import 'package:eClassify/data/model/home/home_screen_section.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/model/system_settings_model.dart';
import 'package:eClassify/new_development/status/models/status_models.dart';
import 'package:eClassify/new_development/status/widgets/status_widget.dart';
import 'package:eClassify/ui/screens/ad_banner_screen.dart';
import 'package:eClassify/ui/screens/home/slider_widget.dart';
import 'package:eClassify/ui/screens/home/widgets/category_widget_home.dart';
import 'package:eClassify/ui/screens/home/widgets/grid_list_adapter.dart';
import 'package:eClassify/ui/screens/home/widgets/all_items_widget.dart';
import 'package:eClassify/ui/screens/home/widgets/home_section_layout_builder.dart';
import 'package:eClassify/ui/screens/home/widgets/home_sticky_search_delegate.dart';
import 'package:eClassify/data/cubits/home/home_screen_configuration_cubit.dart';
import 'package:eClassify/ui/screens/home/widgets/home_search.dart';
import 'package:eClassify/ui/screens/home/widgets/home_sections_adapter.dart';
import 'package:eClassify/ui/screens/home/widgets/home_shimmers.dart';
import 'package:eClassify/ui/screens/home/widgets/location_widget.dart';
import 'package:eClassify/ui/screens/home/widgets/popular_category_home_widget.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_internet.dart';
import 'package:eClassify/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:eClassify/ui/screens/widgets/shimmerLoadingContainer.dart';
import 'package:eClassify/ui/theme/theme.dart';
//import 'package:uni_links/uni_links.dart';

import 'package:eClassify/utils/app_assets.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/leaf_location_bridge.dart';
import 'package:eClassify/utils/notification/awsome_notification.dart';
import 'package:eClassify/utils/notification/notification_service.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

const double sidePadding = 10;

class HomeScreen extends StatefulWidget {
  final String? from;

  const HomeScreen({super.key, this.from});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<HomeScreen> {
  //
  @override
  bool get wantKeepAlive => true;

  //
  List<ItemModel> itemLocalList = [];

  //
  bool isCategoryEmpty = false;

  //
  late final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    initializeSettings();
    addPageScrollListener();
    notificationPermissionChecker();
    LocalAwesomeNotification().init(context);
    ///////////////////////////////////////
    NotificationService.init(context);
    context.read<SliderCubit>().fetchSlider(
          context,
        );
    context.read<FetchCategoryCubit>().fetchCategories();
    context.read<PopularCategoriesCubit>().fetchPopularCategories();
    _fetchHomeData();

    if (AppConfig.enableHomeConfigurationV214) {
      final configCubit = context.read<HomeConfigurationCubit>();
      if (configCubit.state is! HomeConfigurationSuccess) {
        configCubit.getHomeConfiguration();
      }
    }

    if (HiveUtils.isUserAuthenticated()) {
      context.read<FavoriteCubit>().getFavorite();
      //fetchApiKeys();
      context.read<GetBuyerChatListCubit>().fetch();
      context.read<BlockedUsersListCubit>().blockedUsersList();
    }

    _scrollController.addListener(() {
      if (_scrollController.isEndReached()) {
        final configState = context.read<HomeConfigurationCubit>().state;
        if (!HomeSectionLayoutBuilder.shouldFetchAllItems(configState)) {
          return;
        }
        if (context.read<FetchHomeAllItemsCubit>().hasMoreData()) {
          final loc = LeafLocationBridge.allItems;
          context.read<FetchHomeAllItemsCubit>().fetchMore(
                city: loc.city,
                areaId: loc.areaId,
                radius: loc.radius,
                longitude: loc.longitude,
                latitude: loc.latitude,
                country: loc.country,
                stateName: loc.state,
              );
        }
      }
    });
  }

  void _fetchHomeData() {
    context.read<LeafLocationCubit>().syncFromLegacyHive();
    final featured = LeafLocationBridge.featuredSection;
    context.read<FetchHomeScreenCubit>().fetch(
          city: featured.city,
          areaId: featured.areaId,
          country: featured.country,
          state: featured.state,
        );
    _fetchHomeAllItemsIfNeeded();
  }

  void _fetchHomeAllItemsIfNeeded() {
    final configState = context.read<HomeConfigurationCubit>().state;
    if (!HomeSectionLayoutBuilder.shouldFetchAllItems(configState)) {
      return;
    }
    final items = LeafLocationBridge.allItems;
    context.read<FetchHomeAllItemsCubit>().fetch(
          city: items.city,
          areaId: items.areaId,
          radius: items.radius,
          longitude: items.longitude,
          latitude: items.latitude,
          country: items.country,
          state: items.state,
        );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initializeSettings() {
    final settingsCubit = context.read<FetchSystemSettingsCubit>();
    if (!const bool.fromEnvironment("force-disable-demo-mode",
        defaultValue: false)) {
      Constant.isDemoModeOn =
          settingsCubit.getSetting(SystemSetting.demoMode) ?? false;
    }
  }

  void addPageScrollListener() {
    //homeScreenController.addListener(pageScrollListener);
  }

  void fetchApiKeys() {
    context.read<GetApiKeysCubit>().fetch();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget shell = SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leadingWidth: double.maxFinite,
          leading: Padding(
              padding: EdgeInsetsDirectional.only(start: sidePadding, end: sidePadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const LocationWidget(),
                  if (!AppConfig.enableFiveTabNavV214)
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, Routes.videoAdsScreen);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.color.secondaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: UiUtils.getSvg(
                            AppAssets.bottomNavigation.videoAds,
                            color: context.color.textColorDark,
                          ),
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: (){
                      UiUtils.checkUser(
                          onNotGuest: () {
                            Navigator.pushNamed(context, Routes.notificationPage);
                          },
                          context: context
                      );
                    },
                    child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.color.secondaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.notifications_active, color:context.color.textColorDark, )),
                  )

                ],
              )),
          backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        ),
        backgroundColor: context.color.primaryColor,
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          color: context.color.territoryColor,
          onRefresh: _onHomeRefresh,
          child: AppConfig.enableHomeSliverV214
              ? _buildSliverHomeBody(context)
              : _buildLegacyHomeBody(context),
        ),
      ),
    );

    if (AppConfig.enableFiveTabNavV214) {
      shell = BottomNavTapListener(
        listenFor: BottomTab.home,
        onRepeatTap: _scrollHomeToTop,
        child: shell,
      );
    }
    if (AppConfig.enableHomeConfigurationV214) {
      shell = BlocListener<HomeConfigurationCubit, HomeConfigurationState>(
        listenWhen: (previous, current) =>
            current is HomeConfigurationSuccess &&
            previous is! HomeConfigurationSuccess,
        listener: (context, state) => _fetchHomeAllItemsIfNeeded(),
        child: shell,
      );
    }
    return shell;
  }

  void _scrollHomeToTop() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels > 0) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
      return;
    }
    if (AppConfig.enableHomeSliverV214) {
      _onHomeRefresh();
    }
  }

  Future<void> _onHomeRefresh() async {
    context.read<SliderCubit>().fetchSlider(context);
    context.read<FetchCategoryCubit>().fetchCategories();
    context.read<PopularCategoriesCubit>().fetchPopularCategories();
    if (AppConfig.enableHomeConfigurationV214) {
      context.read<HomeConfigurationCubit>().getHomeConfiguration();
    }
    _fetchHomeData();
  }

  Widget _buildLegacyHomeBody(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      controller: _scrollController,
      child: Column(
        children: [
          _buildHomeScreenBloc(includeSearch: true),
          if (_showAllAdsAtTail()) const AllItemsWidget(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSliverHomeBody(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: HomeStickySearchDelegate(
            backgroundColor: context.color.primaryColor,
          ),
        ),
        SliverToBoxAdapter(child: _buildHomeScreenBloc(includeSearch: false)),
        SliverToBoxAdapter(
          child: Column(
            children: [
              if (_showAllAdsAtTail()) const AllItemsWidget(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHomeScreenBloc({required bool includeSearch}) {
    return BlocBuilder<FetchHomeScreenCubit, FetchHomeScreenState>(
      builder: (context, state) {
        if (state is FetchHomeScreenInProgress) {
          return shimmerEffect();
        }
        if (state is FetchHomeScreenSuccess) {
          final List<StatusModel> allStatus = [];
          for (var section in state.sections) {
            for (ItemModel data in (section.sectionData ?? [])) {
              final images = (data.galleryImages ?? [])
                  .map((i) => i.image)
                  .whereType<String>()
                  .toList();
              if (images.isNotEmpty) {
                allStatus.add(StatusModel(
                  name: data.user?.name ?? '',
                  avatarUrl: data.user?.profile ?? '',
                  mediaUrls: images,
                  description: data.name ?? '',
                  item: data,
                ));
              }
            }
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (includeSearch) const HomeSearchField(),
              if (allStatus.isNotEmpty) StatusWidget(allStatus: allStatus),
              ..._homeContentBlocks(state.sections),
              if (state.sections.isNotEmpty &&
                  Constant.isGoogleBannerAdsEnabled == "1") ...[
                Container(
                  padding: const EdgeInsets.only(top: 5),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: AdBannerWidget(),
                ),
              ] else ...[
                const SizedBox(height: 10),
              ],
            ],
          );
        }

        if (state is FetchHomeScreenFail) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: TextButton(
                onPressed: _fetchHomeData,
                child: Text('retry'.translate(context)),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  List<Widget> _homeContentBlocks(List<HomeScreenSection> featuredSections) {
    if (AppConfig.enableHomeConfigurationV214) {
      final configState = context.watch<HomeConfigurationCubit>().state;
      if (configState is HomeConfigurationSuccess &&
          configState.sections.isNotEmpty) {
        return HomeSectionLayoutBuilder.build(
          configuration: configState.sections,
          featuredSections: featuredSections,
        );
      }
    }
    return HomeSectionLayoutBuilder.build(
      configuration: const [],
      featuredSections: featuredSections,
    );
  }

  bool _showAllAdsAtTail() {
    return HomeSectionLayoutBuilder.showAllAdsAtTail(
      context.watch<HomeConfigurationCubit>().state,
    );
  }

  Widget shimmerEffect() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 24,
          horizontal: defaultPadding,
        ),
        child: Column(
          children: [
            ClipRRect(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: CustomShimmer(height: 52, width: double.maxFinite),
            ),
            SizedBox(
              height: 12,
            ),
            ClipRRect(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: CustomShimmer(height: 170, width: double.maxFinite),
            ),
            SizedBox(
              height: 12,
            ),
            Container(
              height: 100,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 10,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 8.0),
                    child: const Column(
                      children: [
                        ClipRRect(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: CustomShimmer(
                            height: 70,
                            width: 66,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        CustomShimmer(
                          height: 10,
                          width: 48,
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        const CustomShimmer(
                          height: 10,
                          width: 60,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomShimmer(
                  height: 20,
                  width: 150,
                ),
                /* CustomShimmer(
                  height: 20,
                  width: 50,
                ),*/
              ],
            ),
            Container(
              height: 214,
              margin: EdgeInsets.only(top: 10),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 5,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 10.0),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: CustomShimmer(
                            height: 147,
                            width: 250,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        CustomShimmer(
                          height: 15,
                          width: 90,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const CustomShimmer(
                          height: 14,
                          width: 230,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const CustomShimmer(
                          height: 14,
                          width: 200,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: 16,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: CustomShimmer(
                          height: 147,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      CustomShimmer(
                        height: 15,
                        width: 70,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const CustomShimmer(
                        height: 14,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const CustomShimmer(
                        height: 14,
                        width: 130,
                      ),
                    ],
                  );
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisExtent: 215,
                  crossAxisCount: 2, // Single column grid
                  mainAxisSpacing: 15.0,
                  crossAxisSpacing: 15.0,
                  // You may adjust this aspect ratio as needed
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sliderWidget() {
    return BlocConsumer<SliderCubit, SliderState>(
      listener: (context, state) {
        if (state is SliderFetchSuccess) {
          setState(() {});
        }
      },
      builder: (context, state) {
        log('State is  $state');
        if (state is SliderFetchInProgress) {
          return const SliderShimmer();
        }
        if (state is SliderFetchFailure) {
          return Container();
        }
        if (state is SliderFetchSuccess) {
          if (state.sliderlist.isNotEmpty) {
            return const SliderWidget();
          }
        }
        return Container();
      },
    );
  }
}

Future<void> notificationPermissionChecker() async {
  if (!(await Permission.notification.isGranted)) {
    await Permission.notification.request();
  }
}
