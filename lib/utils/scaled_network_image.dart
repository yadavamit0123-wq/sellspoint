import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:flutter/material.dart';

class ScaledNetworkImage extends StatefulWidget {
  const ScaledNetworkImage({required this.url, super.key});

  final String url;

  @override
  State<ScaledNetworkImage> createState() => _ScaledNetworkImageState();
}

class _ScaledNetworkImageState extends State<ScaledNetworkImage> {
  static final Map<String, double> _aspectRatioCache = {};
  ui.Image? _image;
  double? _cachedAspectRatio;

  @override
  void initState() {
    super.initState();
    _cachedAspectRatio = _aspectRatioCache[widget.url];
    if (_cachedAspectRatio == null) {
      _loadImage(widget.url);
    }
  }

  @override
  void didUpdateWidget(covariant ScaledNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _image = null;
      _cachedAspectRatio = _aspectRatioCache[widget.url];
      if (_cachedAspectRatio == null) {
        _loadImage(widget.url);
      }
    }
  }

  void _loadImage(String url) {
    final imageProvider = CachedNetworkImageProvider(url);
    final stream = imageProvider.resolve(ImageConfiguration.empty);
    late ImageStreamListener listener;

    listener = ImageStreamListener((ImageInfo info, bool _) {
      if (!mounted) return;
      final image = info.image;
      final aspectRatio = image.width / image.height;
      _aspectRatioCache[url] = aspectRatio;

      if (widget.url == url) {
        setState(() {
          _image = image;
          _cachedAspectRatio = aspectRatio;
        });
      }
      stream.removeListener(listener);
    });

    stream.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    const targetWidth = 150.0;

    if (_cachedAspectRatio != null) {
      final targetHeight = targetWidth / _cachedAspectRatio!;
      return SizedBox(
        width: targetWidth,
        height: targetHeight,
        child: _image != null
            ? RawImage(image: _image, fit: BoxFit.contain)
            : CachedNetworkImage(
                imageUrl: widget.url,
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                    CustomShimmer(height: targetHeight, width: targetWidth),
              ),
      );
    }

    // fallback shimmer while resolving initial aspect ratio
    return const CustomShimmer(height: 200, width: targetWidth);
  }
}
