import 'dart:developer';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/seller/fetch_seller_ratings_cubit.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/screens/advertisement/details/widgets/seller_profile/verified_badge.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_assets.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/color_mappers/svg_color_mapper.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerProfileCard extends StatefulWidget {
  const SellerProfileCard({required this.user, required this.item, super.key});

  final User user;
  final ItemModel item;

  @override
  State<SellerProfileCard> createState() => _SellerProfileCardState();
}

class _SellerProfileCardState extends State<SellerProfileCard> {
  late final String? formattedNumber;
  late final String phoneCode;

  @override
  void initState() {
    super.initState();
    if (widget.item.contact != null) {
      phoneCode =
          widget.item.phoneCode ??
          HelperUtils.getPhoneCodeFromRegionCode(widget.item.regionCode) ??
          AppConfig.defaultPhoneCode;
      formattedNumber = HelperUtils.getFormattedNumber(
        widget.item.contact!,
        widget.item.phoneCode,
        widget.item.regionCode,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sellerRatings = context.watch<FetchSellerRatingsCubit>();

    final seller = sellerRatings.sellerData();
    final totalRating = sellerRatings.totalSellerRatings();
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.sellerProfileScreen,
          arguments: widget.user.id,
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CustomImage(
              src: widget.user.profile ?? '',
              size: Size.square(70),
              radius: 16,
              fit: BoxFit.cover,
              errorImage: CustomImage(
                src: AppAssets.profile.defaultPerson,
                size: Size.square(50),
                radius: 16,
                fit: BoxFit.cover,
                svgColorMapper: SvgColorMapper(),
              ),
            ),
            10.hGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.user.isVerified ?? false) VerifiedBadge(),
                  Text(widget.user.name!, style: context.bodyLarge),
                  if (seller != null)
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                child: Icon(AppIcons.starFill, size: 16),
                              ),
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: seller.averageRating.toStringAsFixed(1),
                                style: TextStyle(
                                  color: context.color.textDefaultColor,
                                  fontSize: context.font.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10, child: VerticalDivider()),
                        if (totalRating != null)
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: totalRating.toString(),
                                  style: TextStyle(
                                    color: context.color.textDefaultColor,
                                    fontSize: context.font.normal,
                                  ),
                                ),
                                const TextSpan(text: ' '),
                                TextSpan(
                                  text: 'ratings'.translate(context),
                                  style: TextStyle(
                                    color: context.color.textDefaultColor,
                                    fontSize: context.font.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  if (widget.user.email.isNotNullAndNotEmpty)
                    Text(widget.user.email!, style: context.labelSmall),
                ],
              ),
            ),
            if (widget.item.contact.isNotNullAndNotEmpty &&
                HiveUtils.isUserAuthenticated()) ...[
              IconButton(
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: context.color.borderColor),
                  ),
                  fixedSize: const Size(40, 40),
                  iconSize: 24,
                ),
                onPressed: _showContactBottomSheet,
                icon: CustomImage(
                  src: AppAssets.profile.contactUs,
                  size: const Size.square(24),
                  svgColorMapper: SvgColorMapper(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showContactBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    final uri = Uri.parse(
                      'tel:${_normalizePhoneNumber(widget.item.contact!, phoneCode)}',
                    );
                    launchUrl(uri);
                  },
                  leading: Icon(
                    AppIcons.phone,
                    color: context.colorScheme.primary,
                  ),
                  title: Text(formattedNumber!),
                ),
                ListTile(
                  onTap: () {
                    final uri = Uri.parse(
                      'sms:${_normalizePhoneNumber(widget.item.contact!, phoneCode)}',
                    );
                    launchUrl(uri);
                  },
                  leading: Icon(
                    AppIcons.chatDots,
                    color: context.colorScheme.primary,
                  ),
                  title: Text(formattedNumber!),
                ),
                ListTile(
                  onTap: () {
                    final whatsappLink = _generateWhatsappLink(
                      _normalizePhoneNumber(widget.item.contact!, phoneCode),
                    );
                    launchUrl(whatsappLink);
                  },
                  leading: CustomImage(
                    src: AppAssets.social.whatsapp,
                    size: Size.square(24),
                  ),
                  title: Text(formattedNumber!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _normalizePhoneNumber(String mobile, String phoneCode) =>
      HelperUtils.normalizeNumber('$phoneCode$mobile');

  Uri _generateWhatsappLink(String normalizedNumber) {
    final message =
        'Hi! I saw your advertisement for ${widget.item.name} on ${AppConfig.applicationName} '
        'and I’m interested in buying it. Is it still available?'
        '\n${HelperUtils.shareUrl('ad-details', widget.item.slug!)}';

    final encodedMessage = Uri.encodeComponent(message);

    final uri = Uri.parse(
      'https://wa.me/$normalizedNumber?text=$encodedMessage',
    );
    log('$uri');
    return uri;
  }
}
