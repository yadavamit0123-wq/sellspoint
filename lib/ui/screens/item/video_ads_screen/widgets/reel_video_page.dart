import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/item/video_ads/reel_like_cubit.dart';
import 'package:eClassify/data/cubits/item/video_ads/video_ads_cubit.dart';
import 'package:eClassify/data/model/item/video_ad.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/currency_formatter.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

class ReelVideoPage extends StatefulWidget {
  const ReelVideoPage({
    super.key,
    required this.ad,
    required this.pageIndex,
    required this.currentPageListenable,
    required this.isMutedNotifier,
  });

  final VideoAd ad;
  final int pageIndex;
  final ValueListenable<int> currentPageListenable;
  final ValueNotifier<bool> isMutedNotifier;

  @override
  State<ReelVideoPage> createState() => _ReelVideoPageState();
}

class _ReelVideoPageState extends State<ReelVideoPage> {
  VideoPlayerController? _controller;
  Timer? _likeDebounce;
  bool _serverLiked = false;

  @override
  void initState() {
    super.initState();
    _serverLiked = widget.ad.isLiked;
    _initPlayer();
    widget.currentPageListenable.addListener(_onPageChanged);
    widget.isMutedNotifier.addListener(_onMuteChanged);
  }

  @override
  void didUpdateWidget(covariant ReelVideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ad.id != widget.ad.id) {
      _serverLiked = widget.ad.isLiked;
      _disposePlayer();
      _initPlayer();
    }
  }

  void _initPlayer() {
    final url = widget.ad.video;
    if (url.isEmpty) return;
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (!mounted) return;
        _onMuteChanged();
        _onPageChanged();
        setState(() {});
      });
  }

  void _onPageChanged() {
    final active = widget.currentPageListenable.value == widget.pageIndex;
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (active) {
      c.play();
    } else {
      c.pause();
    }
  }

  void _onMuteChanged() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    c.setVolume(widget.isMutedNotifier.value ? 0 : 1);
  }

  void _toggleLike() {
    UiUtils.checkUser(
      context: context,
      onNotGuest: () {
        final newLiked = !widget.ad.isLiked;
        context.read<VideoAdsCubit>().updateLikeState(
              reelId: widget.ad.id,
              isLiked: newLiked,
            );
        _likeDebounce?.cancel();
        _likeDebounce = Timer(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          context.read<ReelLikeCubit>().manageLike(
                reelId: widget.ad.id,
                isLiked: newLiked,
              );
        });
      },
    );
  }

  @override
  void dispose() {
    _likeDebounce?.cancel();
    widget.currentPageListenable.removeListener(_onPageChanged);
    widget.isMutedNotifier.removeListener(_onMuteChanged);
    _disposePlayer();
    super.dispose();
  }

  void _disposePlayer() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReelLikeCubit, ReelLikeState>(
      listener: (context, state) {
        if (state is ReelLikeSuccess && state.reelId == widget.ad.id) {
          _serverLiked = state.isLiked;
        }
        if (state is ReelLikeFailure && state.reelId == widget.ad.id) {
          context.read<VideoAdsCubit>().updateLikeState(
                reelId: widget.ad.id,
                isLiked: _serverLiked,
              );
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            )
          else if (widget.ad.thumbnail.isNotEmpty)
            CachedNetworkImage(
              imageUrl: widget.ad.thumbnail,
              fit: BoxFit.cover,
            )
          else
            ColoredBox(color: Colors.black),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.adDetailsScreen,
                          arguments: {'model': widget.ad.item},
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.ad.item.user?.name?.isNotEmpty == true)
                            CustomText(
                              widget.ad.item.user!.name!,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          const SizedBox(height: 6),
                          CustomText(
                            widget.ad.item.name ?? '',
                            maxLines: 2,
                            color: Colors.white,
                            fontSize: context.font.large,
                          ),
                          if (widget.ad.item.price != null) ...[
                            const SizedBox(height: 4),
                            CustomText(
                              widget.ad.item.price!.currencyFormat,
                              color: Colors.white70,
                            ),
                          ],
                          const SizedBox(height: 8),
                          CustomText(
                            'viewItem'.translate(context),
                            color: context.color.territoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _toggleLike,
                        icon: Icon(
                          widget.ad.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.ad.isLiked ? Colors.red : Colors.white,
                        ),
                      ),
                      if (widget.ad.likeCount > 0)
                        Text(
                          '${widget.ad.likeCount}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<bool>(
                        valueListenable: widget.isMutedNotifier,
                        builder: (context, muted, _) {
                          return IconButton(
                            onPressed: () {
                              widget.isMutedNotifier.value = !muted;
                            },
                            icon: Icon(
                              muted ? Icons.volume_off : Icons.volume_up,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
