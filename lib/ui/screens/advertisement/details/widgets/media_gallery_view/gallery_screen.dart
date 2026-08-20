import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/model/item/product_video.dart';
import 'package:eClassify/ui/screens/advertisement/details/widgets/media_gallery_view/media_gallery.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/interstitial_ad_on_exit_mixin.dart';
import 'package:flutter/material.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({
    required this.gallery,
    this.video,
    this.initialIndex = 0,
    super.key,
  });

  final List<GalleryImages> gallery;
  final ProductVideo? video;
  final int initialIndex;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with InterstitialAdOnExitMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black.withValues(alpha: .4),
            child: IconButton(
              icon: const Icon(AppIcons.x, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: Constant.appContentPadding.copyWith(
          bottom: MediaQuery.paddingOf(context).bottom + 20,
        ),
        child: MediaGallery(
          gallery: widget.gallery,
          video: widget.video,
          initialIndex: widget.initialIndex,
          allowAutoSlider: false,
          isFullScreen: true,
        ),
      ),
    );
  }
}
