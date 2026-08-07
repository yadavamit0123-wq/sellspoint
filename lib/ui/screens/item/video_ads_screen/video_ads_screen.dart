import 'package:eClassify/data/cubits/item/video_ads/reel_like_cubit.dart';
import 'package:eClassify/data/cubits/item/video_ads/video_ads_cubit.dart';
import 'package:eClassify/data/repositories/item/item_repository.dart';
import 'package:eClassify/data/cubits/subscription/fetch_user_package_limit_cubit.dart';
import 'package:eClassify/ui/screens/item/video_ads_screen/widgets/reel_video_page.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_data_found.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_internet.dart';
import 'package:eClassify/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/utils/ad_posting_launcher.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/reel_deep_link_intent.dart';
import 'package:eClassify/utils/reel_feature_gate.dart';
import 'package:eClassify/utils/reel_feed_refresh.dart';
import 'package:eClassify/utils/video_ad_editor_launcher.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoAdsScreen extends StatefulWidget {
  const VideoAdsScreen({
    super.key,
    this.reelId,
    this.itemId,
    this.showCurrentUserReel = false,
    this.embeddedInMainShell = false,
  });

  final int? reelId;
  final int? itemId;
  final bool showCurrentUserReel;
  final bool embeddedInMainShell;

  static Route<dynamic> route(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => VideoAdsCubit()),
          BlocProvider(create: (_) => ReelLikeCubit()),
        ],
        child: VideoAdsScreen(
          reelId: args?['reel_id'] as int? ?? args?['reelId'] as int?,
          itemId: args?['item_id'] as int? ?? args?['itemId'] as int?,
          showCurrentUserReel: args?['show_current_user_reel'] == true,
        ),
      ),
    );
  }

  @override
  State<VideoAdsScreen> createState() => _VideoAdsScreenState();
}

class _VideoAdsScreenState extends State<VideoAdsScreen> {
  final PageController _pageController = PageController();
  final ValueNotifier<bool> _isMuted = ValueNotifier(false);
  final ValueNotifier<int> _currentPage = ValueNotifier(0);
  int? _reelId;
  int? _itemId;

  @override
  void initState() {
    super.initState();
    if (widget.reelId != null || widget.itemId != null) {
      _reelId = widget.reelId;
      _itemId = widget.itemId;
      ReelDeepLinkIntent.consume();
    } else {
      final pending = ReelDeepLinkIntent.consume();
      _reelId = pending.reelId;
      _itemId = pending.itemId;
    }
    _load();
    _pageController.addListener(_onScroll);
    if (widget.embeddedInMainShell &&
        AppConfig.enableReelsTabRepeatTapRefreshV214) {
      ReelFeedRefresh.revision.addListener(_onFeedRefreshSignal);
    }
  }

  void _onFeedRefreshSignal() {
    if (!mounted) return;
    _load();
  }

  void _onPostVideoAdTap() {
    UiUtils.checkUser(
      onNotGuest: () async {
        if (AppConfig.enableReelsTabPostAdReelGateV214 &&
            AppConfig.enableReelSubscriptionGateV214) {
          if (!await ReelFeatureGate.ensureAllowed(context)) return;
          if (!mounted) return;
        }
        if (!mounted) return;
        context.read<FetchUserPackageLimitCubit>().fetchUserPackageLimit(
              packageType: 'item_listing',
            );
      },
      context: context,
    );
  }

  void _load() {
    context.read<VideoAdsCubit>().getVideoAds(
          reelId: _reelId,
          itemId: _itemId,
          showCurrentUserReel: widget.showCurrentUserReel,
        );
  }

  void _onScroll() {
    if (!_pageController.hasClients) return;
    final page = _pageController.page?.round() ?? 0;
    if (_currentPage.value != page) {
      _currentPage.value = page;
    }
    final cubit = context.read<VideoAdsCubit>();
    final state = cubit.state;
    if (state is VideoAdsSuccess &&
        page >= state.ads.length - 2 &&
        cubit.hasMore &&
        !state.isLoadingPage) {
      cubit.getMoreVideoAds(reelId: _reelId, itemId: _itemId);
    }
  }

  @override
  void dispose() {
    if (widget.embeddedInMainShell &&
        AppConfig.enableReelsTabRepeatTapRefreshV214) {
      ReelFeedRefresh.revision.removeListener(_onFeedRefreshSignal);
    }
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    _isMuted.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final embedded = widget.embeddedInMainShell &&
        AppConfig.enableReelsTabEmbeddedShellV214;
    final showPostCta =
        embedded && AppConfig.enableReelsTabPostAdCtaV214;

    Widget child = Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: !embedded,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'videoAds'.translate(context),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (showPostCta)
            IconButton(
              tooltip: 'reelsTabPostVideoAdCta'.translate(context),
              onPressed: _onPostVideoAdTap,
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            ),
          if (widget.showCurrentUserReel &&
              AppConfig.enableVideoAdEditorRouteV214)
            IconButton(
              tooltip: 'videoAdEditorTitle'.translate(context),
              onPressed: () async {
                if (!await ReelFeatureGate.ensureAllowed(context)) return;
                if (!context.mounted) return;
                VideoAdEditorLauncher.open(context);
              },
              icon: const Icon(Icons.video_call_outlined, color: Colors.white),
            ),
        ],
      ),
      body: BlocBuilder<VideoAdsCubit, VideoAdsState>(
        builder: (context, state) {
          if (state is VideoAdsLoading) {
            return Center(child: UiUtils.progress(color: Colors.white));
          }
          if (state is VideoAdsFailure) {
            if (state.error is ApiException &&
                (state.error as ApiException).error == 'no-internet') {
              return NoInternet(onRetry: _load);
            }
            return SomethingWentWrong();
          }
          if (state is VideoAdsSuccess) {
            if (state.ads.isEmpty) {
              if (_itemId != null &&
                  AppConfig.enableReelsFeedEmptyItemAdDetailsCtaV214) {
                return _ReelsEmptyForItemState(
                  itemId: _itemId!,
                  onRetry: _load,
                );
              }
              if (embedded && AppConfig.enableReelsTabEmptyPostCtaV214) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        NoDataFound(
                          onTap: _load,
                          mainMessage:
                              'reelsFeedEmptyHint'.translate(context),
                        ),
                        const SizedBox(height: 20),
                        UiUtils.buildButton(
                          context,
                          height: 44,
                          radius: 10,
                          buttonTitle:
                              'reelsTabPostVideoAdCta'.translate(context),
                          buttonColor: context.color.territoryColor,
                          textColor: context.color.secondaryColor,
                          onPressed: _onPostVideoAdTap,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return NoDataFound(onTap: _load);
            }
            return Stack(
              children: [
                RefreshIndicator(
                  color: context.color.territoryColor,
                  onRefresh: () async => _load(),
                  child: PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: state.ads.length,
                    itemBuilder: (context, index) {
                      return ReelVideoPage(
                        ad: state.ads[index],
                        pageIndex: index,
                        currentPageListenable: _currentPage,
                        isMutedNotifier: _isMuted,
                      );
                    },
                  ),
                ),
                if (state.isLoadingPage)
                  const Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );

    if (showPostCta) {
      child = BlocListener<FetchUserPackageLimitCubit,
          FetchUserPackageLimitState>(
        listener: (context, state) {
          if (state is FetchUserPackageLimitFailure) {
            UiUtils.noPackageAvailableDialog(context);
          }
          if (state is FetchUserPackageLimitInSuccess) {
            AdPostingLauncher.openVideoAdPosting(context);
          }
        },
        child: child,
      );
    }

    return child;
  }
}

class _ReelsEmptyForItemState extends StatelessWidget {
  const _ReelsEmptyForItemState({
    required this.itemId,
    required this.onRetry,
  });

  final int itemId;
  final VoidCallback onRetry;

  Future<void> _openListing(BuildContext context) async {
    try {
      final result = await ItemRepository().fetchItemFromItemId(itemId);
      if (!context.mounted || result.modelList.isEmpty) return;
      await Navigator.pushNamed(
        context,
        Routes.adDetailsScreen,
        arguments: {'model': result.modelList.first},
      );
    } catch (_) {
      if (!context.mounted) return;
      UiUtils.showSnackBarMessage(
        context,
        'somethingWentWrong'.translate(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NoDataFound(
              onTap: onRetry,
              mainMessage: 'reelsFeedEmptyForItemHint'.translate(context),
            ),
            const SizedBox(height: 20),
            UiUtils.buildButton(
              context,
              height: 44,
              radius: 10,
              buttonTitle: 'reelFeedViewListing'.translate(context),
              buttonColor: context.color.territoryColor,
              textColor: context.color.secondaryColor,
              onPressed: () => _openListing(context),
            ),
          ],
        ),
      ),
    );
  }
}
