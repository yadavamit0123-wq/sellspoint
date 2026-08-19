import 'package:eClassify/data/cubits/item/video_ads/liked_reels_cubit.dart';
import 'package:eClassify/data/cubits/item/video_ads/reel_like_cubit.dart';
import 'package:eClassify/data/cubits/item/video_ads/video_ads_cubit.dart';
import 'package:eClassify/data/model/item/video_ad.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/debounce_mixin.dart';
import 'package:eClassify/utils/extensions/lib/number_formatter.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReelLikeButton extends StatefulWidget {
  const ReelLikeButton({required this.ad, super.key});

  final VideoAd ad;

  @override
  State<ReelLikeButton> createState() => _ReelLikeButtonState();
}

class _ReelLikeButtonState extends State<ReelLikeButton>
    with DebounceMixin<ReelLikeButton, bool> {
  // This tracks the last known state saved on the server
  late bool _serverIsLiked;

  @override
  void initState() {
    super.initState();
    _serverIsLiked = widget.ad.isLiked;
  }

  @override
  Duration get debounceDuration => const Duration(milliseconds: 1000);

  @override
  void onDebounced(bool isLiked) {
    if (_serverIsLiked == isLiked) return;
    context.read<ReelLikeCubit>().manageLike(
      reelId: widget.ad.id,
      isLiked: isLiked,
    );
  }

  @override
  void didUpdateWidget(covariant ReelLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset server state tracking when the reel changes
    if (oldWidget.ad.id != widget.ad.id) {
      cancelDebounce();
      _serverIsLiked = widget.ad.isLiked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReelLikeCubit, ReelLikeState>(
      listener: (context, state) {
        if (state is ReelLikeSuccess && state.reelId == widget.ad.id) {
          _serverIsLiked = state.isLiked;
          if (!state.isLiked) {
            context.read<LikedReelsCubit>().removeLikedReel(state.reelId);
          }
        } else if (state is ReelLikeFailure && state.reelId == widget.ad.id) {
          // Revert the UI state to the server state on failure
          context.read<VideoAdsCubit>().updateLikeState(
            reelId: widget.ad.id,
            isLiked: _serverIsLiked,
          );
        }
      },
      child: Column(
        children: [
          IconButton(
            onPressed: () {
              UiUtils.checkUser(
                onNotGuest: () {
                  final newIsLiked = !widget.ad.isLiked;

                  // Update UI instantly via VideoAdsCubit
                  context.read<VideoAdsCubit>().updateLikeState(
                    reelId: widget.ad.id,
                    isLiked: newIsLiked,
                  );

                  // Start debounce to call API
                  debounce(newIsLiked);
                },
                context: context,
              );
            },
            icon: Icon(
              widget.ad.isLiked ? AppIcons.heartFill : AppIcons.heart,
              color: widget.ad.isLiked ? Colors.red : Colors.white,
            ),
          ),
          if (widget.ad.likeCount > 0) ...[
            const SizedBox(height: 4),
            Text(
              widget.ad.likeCount.compact,
              style: context.titleSmall.withColor(Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}
