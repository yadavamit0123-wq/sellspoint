import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/item/video_ads/fetch_reel_cubit.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReelViewWidget extends StatelessWidget {
  const ReelViewWidget({
    required this.itemId,
    required this.isMyReel,
    super.key,
  });

  final int itemId;
  final bool isMyReel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FetchReelCubit(),
      child: Builder(
        builder: (context) {
          return BlocBuilder<FetchReelCubit, FetchReelState>(
            builder: (context, state) {
              if (state is FetchReelInitial) {
                context.read<FetchReelCubit>().fetchReel(
                  itemId: itemId,
                  isMyReel: isMyReel,
                );
              }
              if (state is FetchReelSuccess) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      Routes.videoAdsScreen,
                      arguments: {
                        'reel_id': state.ad.id,
                        'show_current_user_reel': isMyReel,
                      },
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox.fromSize(
                        size: Size.square(48),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black26,
                                BlendMode.srcOver,
                              ),
                              image: NetworkImage(state.ad.thumbnail),
                            ),
                          ),
                          child: Icon(AppIcons.playCircle, color: Colors.white),
                        ),
                      ),
                      PositionedDirectional(
                        end: 0,
                        start: 0,
                        bottom: -5,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              'videoAd'.translate(context),
                              textAlign: TextAlign.center,
                              style: context.labelSmall.copyWith(
                                fontSize: 8,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
