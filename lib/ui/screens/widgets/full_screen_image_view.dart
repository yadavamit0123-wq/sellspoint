import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/utils/app_assets.dart';

import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class FullScreenImageView extends StatefulWidget {
  final ImageProvider provider;

  const FullScreenImageView({super.key, required this.provider});

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        body: SafeArea(
          left: false,
          right: false,
          child: InteractiveViewer(
            maxScale: 4,
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Image(
                  image: widget.provider,
                  errorBuilder: (context, error, stackTrace) {
                    return CustomImage(
                      src: AppAssets.branding.placeholder,
                      size: Size.square(100),
                      radius: 10,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return FittedBox(
                      fit: BoxFit.none,
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: UiUtils.progress(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
