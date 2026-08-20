import 'package:eClassify/data/cubits/followers/follow_user_list_cubit.dart';
import 'package:eClassify/data/cubits/item/video_ads/video_ads_cubit.dart';
import 'package:eClassify/data/cubits/system/bottom_nav_cubit.dart';
import 'package:eClassify/ui/screens/item/video_ads_screen/widgets/overscroll_indicator.dart';
import 'package:eClassify/ui/screens/item/video_ads_screen/widgets/reel_feed_hud_overlay.dart';
import 'package:eClassify/ui/screens/item/video_ads_screen/widgets/reel_filter_tab.dart';
import 'package:eClassify/ui/screens/item/video_ads_screen/widgets/reel_player.dart';
import 'package:eClassify/ui/screens/widgets/loading_indicator.dart';
import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/bottom_nav_tap_listener.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoAdsScreen extends StatefulWidget {
  const VideoAdsScreen({
    this.reelId,
    this.isRouting = false,
    this.showCurrentUserReel = false,
    super.key,
  });

  final int? reelId;
  final bool isRouting;
  final bool showCurrentUserReel;

  @override
  State<VideoAdsScreen> createState() => _VideoAdsScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>?;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider(
        create: (_) => VideoAdsCubit(),
        child: VideoAdsScreen(
          reelId: args?['reel_id'] as int?,
          showCurrentUserReel: args?['show_current_user_reel'] ?? false,
          isRouting: true,
        ),
      ),
    );
  }
}

class _VideoAdsScreenState extends State<VideoAdsScreen> {
  final PageController _controller = PageController();
  final ValueNotifier<bool> _isMutedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double> _overscrollNotifier = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();
    context.read<VideoAdsCubit>().getVideoAds(
      location: AppSession.currentLocation,
      reelId: widget.reelId,
      showCurrentUserReel: widget.showCurrentUserReel,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _isMutedNotifier.dispose();
    _overscrollNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavTapListener(
      listenFor: BottomTab.videoAds,
      onTap: () {
        context.read<VideoAdsCubit>().getVideoAds(
          location: AppSession.currentLocation,
        );
      },
      child: Material(
        color: context.colorScheme.surface,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.topCenter,
                children: [
                  Positioned.fill(
                    child: BlocBuilder<VideoAdsCubit, VideoAdsState>(
                      builder: (context, state) {
                        if (state is VideoAdsFailure) {
                          return QErrorWidget(
                            error: state.exception,
                            onRetry: () =>
                                context.read<VideoAdsCubit>().getVideoAds(
                                  location: AppSession.currentLocation,
                                  reelId: widget.reelId,
                                  showCurrentUserReel:
                                      widget.showCurrentUserReel,
                                ),
                          );
                        }
                        if (state is VideoAdsSuccess) {
                          if (state.ads.isEmpty) {
                            return QErrorWidget.emptyData(
                              onRetry: () =>
                                  context.read<VideoAdsCubit>().getVideoAds(
                                    location: AppSession.currentLocation,
                                  ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: () async {
                              context.read<VideoAdsCubit>().getVideoAds(
                                location: AppSession.currentLocation,
                                showCurrentUserReel: widget.showCurrentUserReel,
                              );
                            },
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (notification) {
                                final hasMore = context
                                    .read<VideoAdsCubit>()
                                    .hasMore;
                                if (notification.isNearBottom && hasMore) {
                                  context.read<VideoAdsCubit>().getMoreVideoAds(
                                    location: AppSession.currentLocation,
                                  );
                                }

                                // PageView dispatches scroll notifications during layout,
                                // so we must not mutate the notifier mid-frame. Defer to
                                // the next post-frame callback to avoid the
                                // "Build scheduled during frame" assertion.
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (!mounted) return;
                                  if (notification
                                          is ScrollUpdateNotification &&
                                      notification.metrics.extentAfter <= 0.0) {
                                    if (hasMore) return;
                                    final overscroll =
                                        notification.metrics.pixels -
                                        notification.metrics.maxScrollExtent;
                                    final val = overscroll > 0
                                        ? overscroll
                                        : 0.0;
                                    if (_overscrollNotifier.value != val) {
                                      _overscrollNotifier.value = val;
                                    }
                                  } else {
                                    if (_overscrollNotifier.value != 0.0) {
                                      _overscrollNotifier.value = 0.0;
                                    }
                                  }
                                });
                                return false;
                              },
                              child: PageView.builder(
                                controller: _controller,
                                scrollDirection: Axis.vertical,
                                itemCount: state.ads.length,
                                padEnds: false,
                                physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                ),
                                itemBuilder: (context, index) {
                                  final ad = state.ads[index];
                                  return Stack(
                                    alignment: Alignment.topCenter,
                                    children: [
                                      Positioned.fill(
                                        child: ReelPlayer(
                                          ad: ad,
                                          pageController: _controller,
                                          index: index,
                                          isRouting: widget.isRouting,
                                          isMutedNotifier: _isMutedNotifier,
                                        ),
                                      ),
                                      PositionedDirectional(
                                        end: 16,
                                        start: 16,
                                        bottom:
                                            MediaQuery.paddingOf(
                                              context,
                                            ).bottom +
                                            (widget.isRouting ? 0 : 32),
                                        child: ReelFeedHudOverlay(
                                          videoAd: ad,
                                          isMutedNotifier: _isMutedNotifier,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          );
                        }
                        return Center(child: LoadingIndicator());
                      },
                    ),
                  ),
                  if (HiveUtils.isUserAuthenticated() &&
                      !widget.showCurrentUserReel)
                    BlocSelector<
                      FollowingListCubit,
                      FollowUsersListState,
                      bool
                    >(
                      selector: (state) => switch (state) {
                        final FollowUsersListSuccess s => s.totalCount > 0,
                        _ => false,
                      },
                      builder: (context, showFilter) {
                        if (!showFilter) return const SizedBox.shrink();
                        return PositionedDirectional(
                          top: kToolbarHeight,
                          child: ReelFilterTab(
                            onChanged: (isFollowing) {
                              context.read<VideoAdsCubit>().getVideoAds(
                                location: AppSession.currentLocation,
                                following: isFollowing,
                              );
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            OverscrollIndicator(overscrollNotifier: _overscrollNotifier),
          ],
        ),
      ),
    );
  }
}
