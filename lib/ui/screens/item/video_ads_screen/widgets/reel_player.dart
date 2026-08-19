import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eClassify/data/cubits/system/bottom_nav_cubit.dart';
import 'package:eClassify/data/model/item/video_ad.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

class ReelPlayer extends StatefulWidget {
  const ReelPlayer({
    required this.ad,
    required this.pageController,
    required this.index,
    required this.isRouting,
    required this.isMutedNotifier,
    super.key,
  });

  final VideoAd ad;
  final PageController pageController;
  final int index;
  final bool isRouting;
  final ValueNotifier<bool> isMutedNotifier;

  @override
  State<ReelPlayer> createState() => _ReelPlayerState();
}

class _ReelPlayerState extends State<ReelPlayer>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver, RouteAware {
  late final VideoPlayerController _controller;
  late final Future<void> _initializeVideoPlayerFuture;
  bool _isKeptAlive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.ad.video));
    _initializeVideoPlayerFuture = _initializePlayer();

    widget.pageController.addListener(_updatePlaybackState);
    widget.isMutedNotifier.addListener(_updateVolume);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updatePlaybackState();
    });
  }

  void _updateVolume() {
    if (!mounted) return;
    _controller.setVolume(widget.isMutedNotifier.value ? 0.0 : 1.0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      Constant.routeObserver.subscribe(this, route);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      _updatePlaybackState();
    }
  }

  @override
  void didPushNext() {
    _controller.pause();
  }

  @override
  void didPopNext() {
    _updatePlaybackState();
  }

  Future<void> _initializePlayer() async {
    await _controller.initialize();
    _controller.setLooping(true);
    _controller.setVolume(widget.isMutedNotifier.value ? 0.0 : 1.0);
    _controller.play();
  }

  void _updatePlaybackState() {
    if (!mounted) return;
    if (!widget.pageController.hasClients) return;

    final currentPage = widget.pageController.page?.round() ?? 0;

    // Update keep alive status (keep 1 page ahead and behind loaded in memory)
    final shouldBeKeptAlive = (widget.index - currentPage).abs() <= 1;
    if (shouldBeKeptAlive != _isKeptAlive) {
      _isKeptAlive = shouldBeKeptAlive;
      updateKeepAlive();
    }

    final isCurrentlyActive = currentPage == widget.index;
    final isTabActive =
        context.read<BottomNavCubit>().state == BottomTab.videoAds;
    final shouldPlay = isCurrentlyActive && (widget.isRouting || isTabActive);
    if (shouldPlay) {
      if (!_controller.value.isPlaying) {
        _controller.seekTo(Duration.zero);
        _controller.play();
      }
    } else {
      _controller.pause();
    }
  }

  @override
  bool get wantKeepAlive => _isKeptAlive;

  @override
  void didUpdateWidget(covariant ReelPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageController != widget.pageController) {
      oldWidget.pageController.removeListener(_updatePlaybackState);
      widget.pageController.addListener(_updatePlaybackState);
      _updatePlaybackState();
    }
    if (oldWidget.isMutedNotifier != widget.isMutedNotifier) {
      oldWidget.isMutedNotifier.removeListener(_updateVolume);
      widget.isMutedNotifier.addListener(_updateVolume);
      _updateVolume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Constant.routeObserver.unsubscribe(this);
    widget.pageController.removeListener(_updatePlaybackState);
    widget.isMutedNotifier.removeListener(_updateVolume);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.sizeOf(context);
    final aspectRatio = size.width / size.height;

    return BlocListener<BottomNavCubit, BottomTab>(
      listener: (context, state) {
        _updatePlaybackState();
      },
      child: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Stack(
              fit: StackFit.expand,
              children: [
                CustomImage(src: widget.ad.thumbnail, fit: BoxFit.cover),
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black45,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Icon(
                          AppIcons.warning,
                          size: 40,
                          color: context.colorScheme.error,
                        ),
                        Text(
                          'somethingWentWrongTitle'.translate(context),
                          style: context.titleMedium.withColor(Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          final isInitialized =
              snapshot.connectionState == ConnectionState.done;

          return AspectRatio(
            aspectRatio: aspectRatio,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [...previousChildren, ?currentChild],
                );
              },
              child: isInitialized
                  ? GestureDetector(
                      key: const ValueKey('video'),
                      onTap: () {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(_controller),
                          ValueListenableBuilder<VideoPlayerValue>(
                            valueListenable: _controller,
                            builder: (context, value, child) {
                              return IgnorePointer(
                                child: AnimatedOpacity(
                                  opacity: value.isPlaying ? 0.0 : 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      color: Colors.black45,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow_rounded,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  : CustomImage(
                      key: const ValueKey('thumbnail'),
                      src: widget.ad.thumbnail,
                      size: MediaQuery.sizeOf(context),
                      placeholder: CachedNetworkImage(
                        imageUrl: widget.ad.thumbnail,
                        height: MediaQuery.sizeOf(context).height,
                        width: MediaQuery.sizeOf(context).width,
                        fit: BoxFit.cover,
                      ),
                      fit: BoxFit.cover,
                    ),
            ),
          );
        },
      ),
    );
  }
}
