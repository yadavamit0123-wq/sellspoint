import 'dart:async';

import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/model/item/product_video.dart';
import 'package:eClassify/ui/screens/advertisement/details/widgets/media_gallery_view/gallery_screen.dart';
import 'package:eClassify/ui/screens/advertisement/details/widgets/media_gallery_view/video_player_widget.dart';
import 'package:eClassify/ui/screens/widgets/contained_blur_image.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/build_context.dart';
import 'package:flutter/material.dart';

class MediaGallery extends StatefulWidget {
  const MediaGallery({
    required this.gallery,
    this.video,
    this.allowAutoSlider = true,
    this.isFullScreen = false,
    this.initialIndex = 0,
    this.onPageChanged,
    super.key,
  });

  final List<GalleryImages> gallery;
  final ProductVideo? video;
  final bool allowAutoSlider;
  final bool isFullScreen;
  final int initialIndex;
  final ValueChanged<int>? onPageChanged;

  @override
  State<MediaGallery> createState() => _MediaGalleryState();
}

class _MediaGalleryState extends State<MediaGallery> {
  Timer? _timer;
  late final PageController _controller;
  late final List<String> _images;
  late final int _totalPages;

  bool get _hasVideo => widget.video != null;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
    _extractImages();
    _setTotalPages();
    if (widget.allowAutoSlider) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTimer();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _clearTimer();
    super.dispose();
  }

  void _extractImages() {
    final galleryImages = widget.gallery.map((e) => e.image!).toList();
    _images = galleryImages;
  }

  void _setTotalPages() {
    var count = _images.length;
    if (_hasVideo) {
      count++;
    }
    _totalPages = count;
  }

  void _clearTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startTimer() {
    _clearTimer();
    if (_totalPages > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) => _nextPage());
    }
  }

  void _nextPage() {
    if (!mounted || _totalPages <= 1) return;
    final currentPage = _controller.page?.round() ?? 0;
    final nextPage = (currentPage + 1) % _totalPages;

    _controller.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.isFullScreen) return;
        final index = _controller.page?.toInt() ?? 0;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryScreen(
              gallery: widget.gallery,
              video: widget.video,
              initialIndex: index,
            ),
          ),
        );
      },
      child: PageView.builder(
        controller: _controller,
        onPageChanged: (index) {
          widget.onPageChanged?.call(index);
        },
        itemCount: _totalPages,
        itemBuilder: (context, index) {
          final isVideo = _hasVideo && index == _totalPages - 1;
          final imageSize = context.sizeFromAspectRatio(16 / 9);
          return Padding(
            padding: widget.isFullScreen
                ? EdgeInsets.zero
                : Constant.appContentPadding.copyWith(top: 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.isFullScreen ? 0 : 16),
              child: isVideo
                  ? VideoPlayerWidget(
                      videoUrl: widget.video!.videoSource.filePath,
                      type: widget.video!.type,
                    )
                  : InteractiveViewer(
                      maxScale: 5,
                      child: widget.isFullScreen
                          ? CustomImage(
                              src: _images[index],
                              fit: BoxFit.contain,
                            )
                          : ContainedBlurImage(
                              src: _images[index],
                              size: imageSize,
                              radius: 16,
                            ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
