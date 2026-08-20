import 'package:eClassify/data/cubits/item/ad_posting_cubit.dart';
import 'package:eClassify/data/model/custom_field/file_resource.dart';
import 'package:eClassify/data/model/item/ad_item_type.dart';
import 'package:eClassify/data/model/item/product_video.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/ad_posting_step_controller.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/media_selection/ad_image_widget.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/media_selection/media_card_skeleton.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/media_selection/media_controller.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/media_selection/product_video_widget.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/media_selection/video_ad_widget.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/media_selection/video_type_selector.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MediaSelectionStep extends StatefulWidget {
  const MediaSelectionStep({super.key});

  @override
  State<MediaSelectionStep> createState() => _MediaSelectionStepState();
}

class _MediaSelectionStepState extends State<MediaSelectionStep> {
  late final MediaController _mediaController;
  late final bool isVideoAdListing;

  @override
  void initState() {
    super.initState();
    final data = context.read<AdPostingCubit>().state.adPostingData;
    isVideoAdListing = data.adType == AdItemType.videoAd;
    _mediaController = MediaController(
      initialImages: data.images,
      initialVideo: data.productVideo,
      initialVideoAd: data.videoAd,
      initialThumbnail: data.thumbnail,
    );
  }

  @override
  void dispose() {
    _mediaController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AdPostingStepController.of(
      context,
    ).register(onPrevious: _onPrevious, onNext: _onNext);
  }

  void _onPrevious() {
    context.read<AdPostingCubit>().updateData((data) {
      return data.copyWith(
        images: _mediaController.images.value,
        deletedImages: _mediaController.deletedImages,
        video: _mediaController.productVideo,
        videoAd: _mediaController.videoAd,
        thumbnail: _mediaController.thumbnail,
        deleteProductVideo: _mediaController.deleteProductVideo,
      );
    });
    context.read<AdPostingCubit>().previousStep();
  }

  Future<void> _onNext() async {
    final isValid = await _mediaController.validate(
      shouldValidateVideoAd: isVideoAdListing,
    );
    if (!isValid) return;

    if (mounted) {
      context.read<AdPostingCubit>().updateData((data) {
        return data.copyWith(
          images: _mediaController.images.value,
          deletedImages: _mediaController.deletedImages,
          video: _mediaController.productVideo,
          videoAd: _mediaController.videoAd,
          thumbnail: _mediaController.thumbnail,
          deleteProductVideo: _mediaController.deleteProductVideo,
        );
      });
      context.read<AdPostingCubit>().nextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaControllerProvider(
      controller: _mediaController,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: Constant.safeAreaMinimumPadding,
              child: Column(
                spacing: 16,
                children: [
                  if (isVideoAdListing)
                    MediaCardSkeleton(
                      title: 'videoAd',
                      trailing: Text(
                        'videoAdRecommendation'.translate(context),
                        style: context.labelMedium,
                      ),
                      child: VideoAdWidget(),
                    ),
                  MediaCardSkeleton(
                    title: 'adImages',
                    child: const AdImageWidget(),
                  ),
                  MediaCardSkeleton(
                    title: 'productVideo',
                    trailing: ValueListenableBuilder(
                      valueListenable: _mediaController.videoTypeNotifier,
                      builder: (context, type, child) {
                        return VideoTypeSelector(
                          selected: type,
                          onTypeChanged: (newType) {
                            if (_mediaController.videoTypeNotifier.value ==
                                    ProductVideoType.custom &&
                                _mediaController.productVideo?.videoSource
                                    is RemoteFileResource) {
                              _mediaController.deleteProductVideo = true;
                            }
                            _mediaController.videoTypeNotifier.value = newType;
                            _mediaController.productVideo = null;
                            _mediaController.linkController.clear();
                            _mediaController.clearError(MediaType.video);
                          },
                        );
                      },
                    ),
                    child: const ProductVideoWidget(),
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
