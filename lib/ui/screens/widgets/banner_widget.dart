import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/banner/banner_action.dart';
import 'package:eClassify/data/model/banner/banner_ad.dart';
import 'package:eClassify/data/model/item/item_list.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/build_context.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerWidget extends StatelessWidget {
  const BannerWidget({super.key, required this.bannerAd});

  final BannerAd bannerAd;

  @override
  Widget build(BuildContext context) {
    if (bannerAd.banners.isEmpty) return const SizedBox.shrink();

    final size = context.sizeFromAspectRatio(bannerAd.layout.aspectRatio);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Constant.horizontalPadding,
        vertical: 5,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          for (final banner in bannerAd.banners)
            AspectRatio(
              aspectRatio: bannerAd.layout.aspectRatio,
              child: GestureDetector(
                onTap: () => BannerActionHandler.handle(context, banner.action),
                child: CustomImage(
                  src: banner.image,
                  fit: BoxFit.cover,
                  size: size,
                  radius: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BannerActionHandler {
  static void handle(BuildContext context, BannerAction action) async {
    switch (action) {
      case final OpenCategory a:
        _categoryActionHandler(context, a);
      case final OpenAdvertisement a:
        _advertisementActionHandler(context, a);
      case final OpenExternalLink a:
        _externalLinkHandler(context, a);
      case final NoAction _:
        break;
    }
  }

  static void _categoryActionHandler(
    BuildContext context,
    OpenCategory action,
  ) {
    final category = action.category;
    Navigator.of(context).pushNamed(
      Routes.itemsList,
      arguments: CategoryMetaData(category: category),
    );
  }

  static void _advertisementActionHandler(
    BuildContext context,
    OpenAdvertisement action,
  ) {
    Navigator.of(
      context,
    ).pushNamed(Routes.adDetailsScreen, arguments: {'item_id': action.itemId});
  }

  static void _externalLinkHandler(
    BuildContext context,
    OpenExternalLink action,
  ) async {
    final didLaunch = await launchUrl(action.url);
    if (!didLaunch) {
      Log.error('Could not launch the url', null, null);
    }
  }
}
