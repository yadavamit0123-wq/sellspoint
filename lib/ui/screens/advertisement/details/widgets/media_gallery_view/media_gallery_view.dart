import 'package:eClassify/data/model/item/ad_item_type.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/screens/advertisement/details/widgets/media_gallery_view/media_gallery.dart';
import 'package:eClassify/ui/screens/advertisement/details/widgets/media_gallery_view/reel_view_widget.dart';
import 'package:eClassify/ui/screens/home/widgets/favorite_button.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:flutter/material.dart';

class MediaGalleryView extends StatefulWidget {
  const MediaGalleryView({
    required this.item,
    required this.isMyItem,
    super.key,
  });

  final ItemModel item;
  final bool isMyItem;

  @override
  State<MediaGalleryView> createState() => _MediaGalleryViewState();
}

class _MediaGalleryViewState extends State<MediaGalleryView> {
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);

  @override
  void dispose() {
    _currentIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isMyItem = widget.isMyItem;

    int totalPages =
        (item.galleryImages?.length ?? 0) + (item.video != null ? 1 : 0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        // The inner item will have horizontal padding applied, so we calculate
        // the height based on the padded width to maintain a perfect 16:9 ratio inside.
        final double innerWidth = width - (Constant.horizontalPadding * 2);
        final double targetHeight = innerWidth * (9 / 16);

        return SizedBox(
          height: targetHeight,
          child: Stack(
            children: [
              MediaGallery(
                gallery: item.galleryImages!,
                video: item.video,
                allowAutoSlider: false,
                onPageChanged: (index) {
                  _currentIndexNotifier.value = index;
                },
              ),
              PositionedDirectional(
                end: Constant.horizontalPadding + 8,
                top: 8,
                child: FavoriteButton(item: item),
              ),
              if (item.itemType == AdItemType.videoAd)
                PositionedDirectional(
                  end: Constant.horizontalPadding + 8,
                  bottom: 16,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _currentIndexNotifier,
                    builder: (context, currentIndex, _) {
                      bool isVideoPage =
                          (item.video != null) && (currentIndex == totalPages - 1);
                      if (isVideoPage) return const SizedBox.shrink();

                      return ReelViewWidget(itemId: item.id!, isMyReel: isMyItem);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
