import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eClassify/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum _FileType { network, asset, file }

class CustomImage extends StatefulWidget {
  const CustomImage({
    required String? src,
    this.fit = BoxFit.cover,
    this.size,
    this.resolution,
    this.radius = 0,
    this.placeholder,
    this.errorImage,
    this.svgColorMapper,
    this.adaptive = false,
    super.key,
  }) : this.src = src ?? '';

  final String src;
  final BoxFit fit;
  final Size? size;
  final Size? resolution;
  final double radius;
  final Widget? placeholder;
  final Widget? errorImage;
  final bool adaptive;

  // This is ignored if the src has type other than SVG
  final ColorMapper? svgColorMapper;

  @override
  State<CustomImage> createState() => _CustomImageState();
}

class _CustomImageState extends State<CustomImage> {
  late bool _isSvg;
  late _FileType _fileType;

  late Widget placeHolderImage;
  late Widget errorImage;

  double? get height => widget.size?.height;

  double? get width => widget.size?.width;

  Size? get res => widget.resolution ?? widget.size;

  @override
  void initState() {
    super.initState();
    _resolveImageProvider(widget.src);
    placeHolderImage =
        widget.placeholder ??
        SvgPicture.asset(
          AppAssets.branding.placeholder,
          height: height,
          width: width,
          fit: widget.fit,
        );
    errorImage =
        widget.errorImage ??
        SvgPicture.asset(
          AppAssets.branding.placeholder,
          height: height,
          width: width,
          fit: widget.fit,
        );
  }

  @override
  void didUpdateWidget(covariant CustomImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.src != widget.src) {
      _resolveImageProvider(widget.src);
    }
    if (oldWidget.errorImage != widget.errorImage ||
        oldWidget.placeholder != widget.placeholder) {
      placeHolderImage =
          widget.placeholder ??
          SvgPicture.asset(
            AppAssets.branding.placeholder,
            height: height,
            width: width,
            fit: widget.fit,
          );
      errorImage =
          widget.errorImage ??
          SvgPicture.asset(
            AppAssets.branding.placeholder,
            height: height,
            width: width,
            fit: widget.fit,
          );
    }
  }

  void _resolveImageProvider(String src) {
    final uri = Uri.tryParse(src);
    if (uri == null) return;

    if (uri.hasScheme && ['http', 'https'].contains(uri.scheme)) {
      _fileType = _FileType.network;
    } else if (uri.path.contains('assets')) {
      _fileType = _FileType.asset;
    } else {
      _fileType = _FileType.file;
    }
    _isSvg = uri.pathSegments.lastOrNull?.endsWith('svg') ?? false;
  }

  double clampSize(double size, double dpr) {
    final scaledSize = size * dpr;
    // Removing the strict 700px cap to ensure sharpness on high-res devices.
    // Using a 2000px sanity cap instead.
    return min(scaledSize, 2000);
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_isSvg) {
      child = switch (_fileType) {
        _FileType.asset => SvgPicture.asset(
          widget.src,
          height: height,
          width: width,
          fit: widget.fit,
          errorBuilder: (_, _, _) => errorImage,
          placeholderBuilder: (_) => placeHolderImage,
          colorMapper: widget.svgColorMapper,
        ),
        _FileType.network => SvgPicture.network(
          widget.src,
          height: height,
          width: width,
          fit: widget.fit,
          errorBuilder: (_, _, _) => errorImage,
          placeholderBuilder: (_) => placeHolderImage,
          colorMapper: widget.svgColorMapper,
        ),
        _FileType.file => SvgPicture.file(
          File(widget.src),
          height: height,
          width: width,
          fit: widget.fit,
          errorBuilder: (_, _, _) => errorImage,
          placeholderBuilder: (_) => placeHolderImage,
          colorMapper: widget.svgColorMapper,
        ),
      };
    } else {
      final dpr = MediaQuery.of(context).devicePixelRatio;

      final int? cacheWidth = res?.width != null && widget.adaptive
          ? clampSize(res!.width, dpr).toInt()
          : null;
      final int? cacheHeight = res?.height != null && widget.adaptive
          ? clampSize(res!.height, dpr).toInt()
          : null;

      child = switch (_fileType) {
        _FileType.asset => Image.asset(
          widget.src,
          height: height,
          width: width,
          fit: widget.fit,
          cacheHeight: cacheHeight,
          cacheWidth: cacheWidth,
          errorBuilder: (_, _, _) => errorImage,
        ),
        _FileType.network => CachedNetworkImage(
          imageUrl: widget.src,
          imageBuilder: (context, provider) {
            return Image(
              image: provider,
              height: height,
              width: width,
              fit: widget.fit,
            );
          },
          memCacheWidth: cacheWidth,
          memCacheHeight: cacheHeight,
          maxWidthDiskCache: cacheWidth,
          maxHeightDiskCache: cacheHeight,
          errorWidget: (_, _, _) => errorImage,
          placeholder: (_, _) => placeHolderImage,
        ),
        _FileType.file => Image.file(
          File(widget.src),
          height: height,
          width: width,
          fit: widget.fit,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          errorBuilder: (_, _, _) => errorImage,
        ),
      };
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: child,
    );
  }
}
