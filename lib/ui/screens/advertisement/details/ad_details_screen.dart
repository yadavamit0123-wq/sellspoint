// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/banner/banner_ad_cubit.dart';
import 'package:eClassify/data/cubits/chat/chat_list_cubit.dart';
import 'package:eClassify/data/cubits/chat/make_an_offer_item_cubit.dart';
import 'package:eClassify/data/cubits/item/change_my_items_status_cubit.dart';
import 'package:eClassify/data/cubits/item/create_featured_ad_cubit.dart';
import 'package:eClassify/data/cubits/item/delete_item_cubit.dart';
import 'package:eClassify/data/cubits/item/fetch_item_cubit.dart';
import 'package:eClassify/data/cubits/item/fetch_my_item_cubit.dart';
import 'package:eClassify/data/cubits/item/item_total_click_cubit.dart';
import 'package:eClassify/data/cubits/item/job_application/fetch_job_application_cubit.dart';
import 'package:eClassify/data/cubits/item/related_item_cubit.dart';
import 'package:eClassify/data/cubits/renew_item_cubit.dart';
import 'package:eClassify/data/cubits/report/item_report_cubit.dart';
import 'package:eClassify/data/cubits/report/item_report_list_cubit.dart';
import 'package:eClassify/data/cubits/safety_tips_cubit.dart';
import 'package:eClassify/data/cubits/seller/fetch_seller_ratings_cubit.dart';
import 'package:eClassify/data/cubits/subscription/fetch_user_package_limit_cubit.dart';
import 'package:eClassify/data/model/banner/banner_ad.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/data/model/safety_tips_model.dart';
import 'package:eClassify/ui/screens/advertisement/details/widgets/dialogs/create_offer_dialog.dart';
import 'package:eClassify/ui/screens/advertisement/details/widgets/dialogs/delete_advertisement_dialog.dart';
import 'package:eClassify/ui/screens/advertisement/details/widgets/feature_ad/feature_ad_card.dart';
import 'package:eClassify/ui/screens/advertisement/details/widgets/item_location/item_location_map.dart';
import 'package:eClassify/ui/screens/advertisement/details/widgets/media_gallery_view/media_gallery_view.dart';
import 'package:eClassify/ui/screens/advertisement/details/widgets/report_ad/report_ad_card.dart';
import 'package:eClassify/ui/screens/advertisement/details/widgets/seller_profile/seller_profile_card.dart';
import 'package:eClassify/ui/screens/google_banner_ad.dart';
import 'package:eClassify/ui/screens/home/widgets/item_card_widget.dart';
import 'package:eClassify/ui/screens/item/my_item_tab_screen.dart';
import 'package:eClassify/ui/screens/widgets/banner_widget.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/screens/widgets/expandable_text.dart';
import 'package:eClassify/ui/screens/widgets/package_select_bottom_sheet.dart';
import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_assets.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/color_mappers/primary_color_mapper.dart';
import 'package:eClassify/utils/color_mappers/svg_color_mapper.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/extensions/lib/item_model_extension.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/loading_overlay.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdDetailsScreen extends StatefulWidget {
  const AdDetailsScreen({
    super.key,
    this.model,
    this.slug,
    this.itemId,
    this.isMyAd = false,
    this.tabStatus,
  });

  final ItemModel? model;
  final String? slug;
  final int? itemId;
  final bool? isMyAd;

  // This is only relevant when the user renews an item.
  // Previously, renewing an item would pop this screen and refresh
  // the entire tab list for the current status — which was poor UX.
  //
  // Now, instead of popping the screen, we just refresh the list
  // for the currently active tab. To achieve that, we need a reference
  // to the selected tab's status.
  final String? tabStatus;

  @override
  AdDetailsScreenState createState() => AdDetailsScreenState();

  static Route route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => FetchMyItemsCubit()),
          BlocProvider(create: (context) => CreateFeaturedAdCubit()),
          BlocProvider(create: (context) => SubmitItemReportCubit()),
          BlocProvider(create: (context) => MakeAnOfferItemCubit()),
          BlocProvider(create: (context) => FetchItemCubit()),
          BlocProvider(create: (context) => FetchUserPackageLimitCubit()),
          BlocProvider(create: (context) => DetailBannerAdCubit()),
        ],
        child: AdDetailsScreen(
          model: arguments?['model'],
          slug: arguments?['slug'],
          itemId: arguments?['item_id'],
          isMyAd: arguments?['is_my_ad'] ?? false,
          tabStatus: arguments?['status_tab'],
        ),
      ),
    );
  }
}

class AdDetailsScreenState extends State<AdDetailsScreen> {
  int currentPage = 0;

  bool isShowReportAds = true;

  late ItemModel model;

  late bool isAddedByMe;
  bool isFeaturedWidget = true;
  int? categoryId;
  bool isAdminEditedReasonExpanded = false;
  late bool isAlreadyReported;

  late final LeafLocation? location;
  List<dynamic> _uniqueCustomFields = [];

  Map<String, List<DetailBannerAd>>? bannersBySectionAndPlacement;

  @override
  void initState() {
    super.initState();
    location = AppSession.currentLocation;
    if (widget.model != null) {
      initVariables(widget.model!);
    }
  }

  void initVariables(ItemModel itemModel) {
    model = itemModel;
    isAddedByMe =
        (model.user?.id != null ? model.user!.id.toString() : model.userId) ==
        HiveUtils.getUserId();

    categoryId = model.category != null ? model.category?.id : model.categoryId;
    isAlreadyReported =
        model.isAlreadyReported! ||
        context.read<ItemReportListCubit>().contains(itemId: model.id!);

    _prepareCustomFields();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isAddedByMe) {
        context.read<FetchSafetyTipsListCubit>().fetchSafetyTips();
        context.read<FetchSellerRatingsCubit>().fetch(
          sellerId: (model.user?.id != null ? model.user!.id! : model.userId!),
        );
      }

      context.read<FetchRelatedItemsCubit>().fetchRelatedItems(
        categoryId: categoryId!,
        location: location,
        excludedItemId: model.id!,
      );

      context.read<DetailBannerAdCubit>().fetchBanners();

      setItemClick();
    });
  }

  void setItemClick() {
    if (!isAddedByMe) {
      context.read<ItemTotalClickCubit>().itemTotalClick(model.id!);
    }
  }

  Widget? _resolveAdBannerWidget(
    DetailSection section,
    BannerPlacement placement,
  ) {
    final key = '${section.name}_${placement.name}';

    return BlocSelector<
      DetailBannerAdCubit,
      BannerAdState,
      List<DetailBannerAd>
    >(
      selector: (state) {
        return switch (state) {
          BannerAdSuccess(:final bannerAds) => bannerAds.cast<DetailBannerAd>(),
          _ => <DetailBannerAd>[],
        };
      },
      builder: (context, banners) {
        final banner = bannersBySectionAndPlacement?[key]?.firstOrNull;
        return banner != null
            ? BannerWidget(bannerAd: banner)
            : const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DetailBannerAdCubit, BannerAdState>(
      listener: (context, state) {
        if (state is BannerAdSuccess) {
          bannersBySectionAndPlacement ??= groupBy(
            state.bannerAds.cast<DetailBannerAd>(),
            (b) => '${b.section.name}_${b.placement.name}',
          );
        }
      },
      child: BlocConsumer<FetchItemCubit, FetchItemState>(
        listener: (context, state) {
          if (state is FetchItemSuccess) {
            initVariables(state.item);
          }
        },
        builder: (context, state) {
          if (state is FetchItemInitial &&
              (widget.slug != null || widget.itemId != null)) {
            context.read<FetchItemCubit>().fetchItem(
              itemId: widget.itemId,
              slug: widget.slug,
              isMyAd: widget.isMyAd ?? false,
            );
            return Material(child: Center(child: UiUtils.progress()));
          } else if (state is FetchItemLoading) {
            return Material(child: Center(child: UiUtils.progress()));
          } else if (state is FetchItemFailure) {
            return Material(
              child: Center(child: QErrorWidget(error: state.error)),
            );
          }

          return MultiBlocListener(
            listeners: [
              BlocListener<MakeAnOfferItemCubit, MakeAnOfferItemState>(
                listener: (context, state) {
                  if (state is MakeAnOfferItemInProgress) {
                    LoadingOverlay.show(context);
                  }
                  if (state is MakeAnOfferItemSuccess ||
                      state is MakeAnOfferItemFailure) {
                    LoadingOverlay.hide();
                  }
                },
              ),
              BlocListener<RenewItemCubit, RenewItemState>(
                listener: (context, changeState) async {
                  if (changeState is RenewItemInProgress) {
                    LoadingOverlay.show(context);
                  }
                  if (changeState is RenewItemInSuccess) {
                    HelperUtils.showSnackBarMessage(
                      context,
                      changeState.responseMessage,
                    );
                    // await Future.delayed(const Duration(seconds: 1));
                    // context.read<FetchItemCubit>().fetchItem(slug: model.slug);
                    // There was no other way to refresh the list without referencing this
                    // global array of references because FetchItemCubit is littered
                    // everywhere in the code, so you don't really know which
                    // reference belongs to which cubit. Hence, this temporary
                    // but dirty solution to avoid breaking the system.
                    // TODO: Refactor this entire global references of cubit
                    myAdsCubitReference[widget.tabStatus]?.fetchMyItems(
                      getItemsWithStatus: widget.tabStatus,
                    );
                    LoadingOverlay.hide();
                    Navigator.of(context).pop();
                  } else if (changeState is RenewItemFailure) {
                    LoadingOverlay.hide();
                    HelperUtils.showSnackBarMessage(context, changeState.error);
                  }
                },
              ),
            ],
            child: Scaffold(
              appBar: AppBar(
                actions: [
                  if (isAddedByMe && model.status == Constant.statusActive ||
                      model.status == Constant.statusApproved)
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        end:
                            isAddedByMe &&
                                (model.status != Constant.statusSoldOut &&
                                    model.status != Constant.statusReview &&
                                    model.status !=
                                        Constant.statusResubmitted &&
                                    model.status != Constant.statusInactive &&
                                    model.status !=
                                        Constant.statusPermanentRejected &&
                                    model.status != Constant.statusSoftRejected)
                            ? 30.0
                            : 15,
                      ),
                      child: IconButton(
                        onPressed: () {
                          HelperUtils.shareItem(
                            context,
                            "ad-details",
                            model.slug!,
                          );
                        },
                        icon: Icon(
                          AppIcons.shareNetwork,
                          color: context.color.textDefaultColor,
                        ),
                      ),
                    ),
                  if (isAddedByMe &&
                      (model.status != Constant.statusSoldOut &&
                          model.status != Constant.statusReview &&
                          model.status != Constant.statusResubmitted &&
                          model.status != Constant.statusInactive &&
                          model.status != Constant.statusPermanentRejected) &&
                      model.status != Constant.statusExpired)
                    MultiBlocProvider(
                      providers: [
                        BlocProvider(create: (context) => DeleteItemCubit()),
                        BlocProvider(
                          create: (context) => ChangeMyItemStatusCubit(),
                        ),
                      ],
                      child: Builder(
                        builder: (context) {
                          return BlocListener<DeleteItemCubit, DeleteItemState>(
                            listener: (context, deleteState) {
                              if (deleteState is DeleteItemSuccess) {
                                HelperUtils.showSnackBarMessage(
                                  context,
                                  "deleteItemSuccessMsg".translate(context),
                                );
                                context.read<FetchMyItemsCubit>().deleteItem(
                                  model,
                                );
                                Navigator.pop(context, "refresh");
                              } else if (deleteState is DeleteItemFailure) {
                                HelperUtils.showSnackBarMessage(
                                  context,
                                  deleteState.errorMessage,
                                );
                              }
                            },
                            child:
                                BlocListener<
                                  ChangeMyItemStatusCubit,
                                  ChangeMyItemStatusState
                                >(
                                  listener: (context, changeState) {
                                    if (changeState
                                        is ChangeMyItemStatusSuccess) {
                                      HelperUtils.showSnackBarMessage(
                                        context,
                                        "adsStatusUpdatedSuccessfully"
                                            .translate(context),
                                      );
                                      Navigator.pop(context, "refresh");
                                    } else if (changeState
                                        is ChangeMyItemStatusFailure) {
                                      HelperUtils.showSnackBarMessage(
                                        context,
                                        changeState.errorMessage,
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 24,
                                    width: 24,
                                    margin: EdgeInsetsDirectional.only(
                                      end: 30.0,
                                    ),
                                    alignment: AlignmentDirectional.center,
                                    child: PopupMenuButton(
                                      color: context.color.territoryColor,
                                      offset: Offset(-12, 15),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(17),
                                          bottomRight: Radius.circular(17),
                                          topLeft: Radius.circular(17),
                                          topRight: Radius.circular(0),
                                        ),
                                      ),
                                      child: Icon(
                                        AppIcons.dotsThreeOutlineVertical,
                                      ),
                                      itemBuilder: (context) => [
                                        if (model.status ==
                                                Constant.statusActive ||
                                            model.status ==
                                                Constant.statusApproved)
                                          PopupMenuItem(
                                            onTap: () {
                                              Future.delayed(Duration.zero, () {
                                                context
                                                    .read<
                                                      ChangeMyItemStatusCubit
                                                    >()
                                                    .changeMyItemStatus(
                                                      id: model.id!,
                                                      status: Constant
                                                          .statusInactive,
                                                    );
                                              });
                                            },
                                            child: CustomText(
                                              "deactivate".translate(context),
                                              color: context.color.buttonColor,
                                            ),
                                          ),
                                        if (model.status ==
                                                Constant.statusActive ||
                                            model.status ==
                                                Constant.statusApproved ||
                                            model.status ==
                                                Constant.statusSoftRejected)
                                          PopupMenuItem(
                                            child: CustomText(
                                              "lblremove".translate(context),
                                              color: context.color.buttonColor,
                                            ),
                                            onTap: () async {
                                              final shouldDelete =
                                                  await DeleteAdvertisementDialog.show(
                                                    context,
                                                  ) ??
                                                  false;
                                              if (shouldDelete) {
                                                context
                                                    .read<DeleteItemCubit>()
                                                    .deleteItem(id: model.id!);
                                              }
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                          );
                        },
                      ),
                    ),
                ],
              ),
              bottomNavigationBar: SafeArea(
                minimum: Constant.safeAreaMinimumPadding,
                child: bottomButtonWidget(),
              ),
              body: SingleChildScrollView(
                padding: EdgeInsets.only(top: Constant.bottomPadding),
                child: RepaintBoundary(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Section: image
                      ?_resolveAdBannerWidget(
                        DetailSection.image,
                        BannerPlacement.above,
                      ),
                      5.vGap,
                      MediaGalleryView(
                        item: model,
                        isMyItem: widget.isMyAd ?? false,
                      ),
                      ?_resolveAdBannerWidget(
                        DetailSection.image,
                        BannerPlacement.below,
                      ),
                      // Section: ad_info
                      ?_resolveAdBannerWidget(
                        DetailSection.adInfo,
                        BannerPlacement.above,
                      ),
                      Padding(
                        padding: Constant.appContentPadding,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 10,
                          children: [
                            if (isAddedByMe) setLikesAndViewsCount(),
                            if (model.isEditedByAdmin == 1 &&
                                model.translatedAdminEditReason != null &&
                                isAddedByMe)
                              adminEditedReason(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Text(
                                    model.translatedName!,
                                    style: context.titleMedium,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (model.category!.isJobCategory &&
                                    isAddedByMe) ...[
                                  Expanded(
                                    child: UiUtils.buildButton(
                                      context,
                                      disabled: model.status == 'sold out',
                                      onTapDisabledButton: () {
                                        HelperUtils.showSnackBarMessage(
                                          context,
                                          'jobIsClosed'.translate(context),
                                        );
                                      },
                                      onPressed: () =>
                                          Navigator.of(context).pushNamed(
                                            Routes.jobApplicationList,
                                            arguments: {"itemId": model.id},
                                          ),
                                      height: 30,
                                      buttonTitle: 'jobApplications'.translate(
                                        context,
                                      ),
                                      fontSize: context.font.small,
                                      buttonColor: context.color.territoryColor,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            setPriceAndStatus(),
                            if (isAddedByMe) setRejectedReason(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (model.translatedAddress != null)
                                  Expanded(child: setAddress()),
                                CustomText(
                                  model.created!.formatDate(
                                    format: "d MMM yyyy",
                                  ),
                                  maxLines: 1,
                                  color: context.color.textDefaultColor
                                      .withValues(alpha: 0.5),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ?_resolveAdBannerWidget(
                        DetailSection.adInfo,
                        BannerPlacement.below,
                      ),
                      10.vGap,
                      if (Constant.systemSettings.isBannerAdEnabled)
                        GoogleBannerAd(),

                      // Section: custom_fields
                      ?_resolveAdBannerWidget(
                        DetailSection.customFields,
                        BannerPlacement.above,
                      ),
                      if ((isAddedByMe && !model.isFeature!) ||
                          (model.allTranslatedCustomFields?.isNotEmpty ??
                              false))
                        Padding(
                          padding: Constant.appContentPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isAddedByMe && !model.isFeature!)
                                FeatureAdCard(itemId: model.id!),
                              if (model.allTranslatedCustomFields?.isNotEmpty ??
                                  false)
                                customFields(),
                            ],
                          ),
                        ),
                      ?_resolveAdBannerWidget(
                        DetailSection.customFields,
                        BannerPlacement.below,
                      ),

                      // Section: about_ad
                      ?_resolveAdBannerWidget(
                        DetailSection.aboutAd,
                        BannerPlacement.above,
                      ),

                      Padding(
                        padding: Constant.appContentPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Divider(
                              thickness: 1,
                              color: context.color.textDefaultColor.withValues(
                                alpha: 0.1,
                              ),
                            ),
                            setDescription(),
                            if (!isAddedByMe && model.user != null) ...[
                              Divider(
                                thickness: 1,
                                color: context.color.textDefaultColor
                                    .withValues(alpha: 0.1),
                              ),
                              SellerProfileCard(user: model.user!, item: model),
                            ],
                          ],
                        ),
                      ),
                      ?_resolveAdBannerWidget(
                        DetailSection.aboutAd,
                        BannerPlacement.below,
                      ),

                      // Section: location
                      ?_resolveAdBannerWidget(
                        DetailSection.location,
                        BannerPlacement.above,
                      ),
                      Padding(
                        padding: Constant.appContentPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Divider(
                              thickness: 1,
                              color: context.color.textDefaultColor.withValues(
                                alpha: 0.1,
                              ),
                            ),
                            ItemLocationMap(
                              latitude: model.latitude,
                              longitude: model.longitude,
                            ),
                          ],
                        ),
                      ),

                      ?_resolveAdBannerWidget(
                        DetailSection.location,
                        BannerPlacement.below,
                      ),

                      if (Constant.systemSettings.isBannerAdEnabled) ...[
                        Divider(
                          thickness: 1,
                          color: context.color.textDefaultColor.withValues(
                            alpha: 0.1,
                          ),
                        ),
                        GoogleBannerAd(),
                      ],

                      // Section: similar_ads
                      ?_resolveAdBannerWidget(
                        DetailSection.similarAds,
                        BannerPlacement.above,
                      ),
                      Padding(
                        padding: Constant.appContentPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isAddedByMe && !isAlreadyReported)
                              ReportAdCard(
                                itemId: model.id!,
                                isReported: isAlreadyReported,
                                onReport: () {
                                  // This should not use setState but somehow, without setState
                                  // the card is being painted even though we are setting the
                                  // isAlreadyReported flag to true. Perhaps, due to Flutter's
                                  // internal caching mechanism.
                                  setState(() {
                                    isAlreadyReported = true;
                                  });
                                },
                              ),
                            if (!isAddedByMe) relatedAds(),
                          ],
                        ),
                      ),

                      ?_resolveAdBannerWidget(
                        DetailSection.similarAds,
                        BannerPlacement.below,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget relatedAds() {
    return BlocBuilder<FetchRelatedItemsCubit, FetchRelatedItemsState>(
      builder: (context, state) {
        if (state is FetchRelatedItemsInProgress) {
          return relatedItemShimmer();
        }
        if (state is FetchRelatedItemsFailure) {
          return const SizedBox.shrink();
        }

        if (state is FetchRelatedItemsSuccess) {
          if (state.itemModel.isEmpty || state.itemModel.length == 1) {
            return SizedBox.shrink();
          }

          return buildRelatedListWidget(state);
        }

        return const SizedBox.square();
      },
    );
  }

  Widget buildRelatedListWidget(FetchRelatedItemsSuccess state) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            "relatedAds".translate(context),
            fontSize: context.font.large,
            fontWeight: FontWeight.w600,
            maxLines: 1,
          ),
          SizedBox(height: 15),
          SizedBox(
            height: HelperUtils.lerpHeight(
              screenHeight: MediaQuery.sizeOf(context).height,
              minHeight: 243,
              maxHeight: 285,
              minScreen: 600,
              maxScreen: 850,
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return ItemCard(item: state.itemModel[index], aspectRatio: .7);
              },
              separatorBuilder: (_, _) => 10.hGap,
              itemCount: state.itemModel.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget relatedItemShimmer() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: 5,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 8),
            child: const CustomShimmer(height: 200, width: 300),
          );
        },
      ),
    );
  }

  Widget customFields() {
    if (_uniqueCustomFields.isEmpty) {
      return SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Wrap(
        runSpacing: 5.0,
        spacing: 5.0,
        children: _uniqueCustomFields.map((field) {
          return DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red.withValues(alpha: 0.0)),
            ),
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width * .45,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 33,
                    width: 33,
                    alignment: Alignment.center,
                    child: CustomImage(
                      src: field['image'] ?? '',
                      size: const Size.square(33),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: field['translated_name'],
                          child: CustomText(
                            field['translated_name'] ?? "",
                            fontSize: context.font.small,
                            color: context.color.textLightColor,
                          ),
                        ),
                        if (field['type'] == 'fileinput')
                          valueContent([field['value']])
                        else
                          valueContent(field['translated_selected_values']),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _prepareCustomFields() {
    final List<dynamic> allFields = model.allTranslatedCustomFields ?? [];

    final int currentLanguageId = AppSession.currentLanguage?.id ?? 1;

    final Map<int, Map<int, dynamic>> fieldsByIdAndLang = {};
    for (var field in allFields) {
      final int id = field['id'];
      final int langId = field['language_id'] ?? 1;
      fieldsByIdAndLang.putIfAbsent(id, () => {});
      fieldsByIdAndLang[id]![langId] = field;
    }

    final Map<int, dynamic> uniqueFields = {};
    fieldsByIdAndLang.forEach((id, langMap) {
      final data = langMap[currentLanguageId] ?? langMap.values.first;
      var values;
      if (data['value'] is List) {
        values = (data['value'] as List?)?.nonNulls.toList();
        values?.removeWhere((v) => v.toString().isEmpty);
      } else if (data['value'] is String) {
        values = [data['value']];
      } else {
        values = null;
      }

      if (values?.isEmpty ?? false) {
        return;
      }
      if (langMap.containsKey(currentLanguageId)) {
        uniqueFields[id] = langMap[currentLanguageId];
      } else {
        uniqueFields[id] = langMap.values.first;
      }
    });

    _uniqueCustomFields = uniqueFields.values.toList();
  }

  Widget valueContent(List<dynamic>? value) {
    if (value == null || value.isEmpty) return SizedBox.shrink();
    if (((value[0].toString()).startsWith("http") ||
        (value[0].toString()).startsWith("https"))) {
      if ((value[0].toString()).toLowerCase().endsWith(".pdf")) {
        // Render PDF link as clickable text
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.pdfViewerScreen,
              arguments: {"url": value[0]},
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Icon(AppIcons.filePdf),
          ),
        );
      } else if ((value[0]).toLowerCase().endsWith(".png") ||
          (value[0]).toLowerCase().endsWith(".jpg") ||
          (value[0]).toLowerCase().endsWith(".jpeg") ||
          (value[0]).toLowerCase().endsWith(".svg")) {
        // Render image
        return InkWell(
          onTap: () {
            UiUtils.showFullScreenImage(
              context,
              provider: NetworkImage(value[0]),
            );
          },
          child: Container(
            width: 50,
            height: 50,
            margin: EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: context.color.territoryColor.withValues(alpha: 0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomImage(src: value[0], fit: BoxFit.cover),
            ),
          ),
        );
      }
    }

    value.removeWhere((v) => v.toString().isEmpty);

    // Default text if not a supported format or not a URL
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * .3,
      child: CustomText(
        value.join(','),
        softWrap: true,
        color: context.color.textDefaultColor,
      ),
    );
  }

  Widget deleteItemWidget() {
    return BlocProvider(
      create: (context) => DeleteItemCubit(),
      child: Builder(
        builder: (context) {
          return BlocListener<DeleteItemCubit, DeleteItemState>(
            listener: (context, deleteState) {
              if (deleteState is DeleteItemSuccess) {
                HelperUtils.showSnackBarMessage(
                  context,
                  "deleteItemSuccessMsg".translate(context),
                );
                context.read<FetchMyItemsCubit>().deleteItem(model);
                Navigator.pop(context, "refresh");
              } else if (deleteState is DeleteItemFailure) {
                HelperUtils.showSnackBarMessage(
                  context,
                  deleteState.errorMessage,
                );
              }
            },
            child: Expanded(
              child: _buildButton(
                "lblremove".translate(context),
                () async {
                  final shouldDelete =
                      await DeleteAdvertisementDialog.show(context) ?? false;
                  if (shouldDelete) {
                    context.read<DeleteItemCubit>().deleteItem(id: model.id!);
                  }
                },
                null,
                null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget changeItemStatusWidget({
    required String buttonName,
    required String status,
  }) {
    return BlocListener<ChangeMyItemStatusCubit, ChangeMyItemStatusState>(
      listener: (context, changeState) {
        if (changeState is ChangeMyItemStatusSuccess) {
          HelperUtils.showSnackBarMessage(
            context,
            "adsStatusUpdatedSuccessfully".translate(context),
          );
          Navigator.pop(context, "refresh");
        } else if (changeState is ChangeMyItemStatusFailure) {
          HelperUtils.showSnackBarMessage(context, changeState.errorMessage);
        }
      },
      child: Expanded(
        child: _buildButton(
          buttonName,
          () {
            Future.delayed(Duration.zero, () {
              context.read<ChangeMyItemStatusCubit>().changeMyItemStatus(
                id: model.id!,
                status: status,
              );
            });
          },
          null,
          null,
        ),
      ),
    );
  }

  bool isEditBtnVisible() {
    List statuslist = [
      Constant.statusReview,
      Constant.statusResubmitted,
      Constant.statusActive,
      Constant.statusApproved,
      Constant.statusSoftRejected,
    ];
    return statuslist.contains(model.status);
  }

  bool isDeleteBtnVisible() {
    List statuslist = [
      Constant.statusReview,
      Constant.statusResubmitted,
      Constant.statusSoldOut,
      Constant.statusInactive,
      Constant.statusExpired,
      Constant.statusPermanentRejected,
    ];
    return statuslist.contains(model.status);
  }

  Widget bottomButtonWidget() {
    if (isAddedByMe) {
      final contextColor = context.color;

      return Row(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEditBtnVisible())
            Expanded(
              child: _buildButton(
                "editBtnLbl".translate(context),
                () {
                  final data = model.toAdPostingData();
                  Navigator.pushNamed(
                    context,
                    Routes.adPostingScreen,
                    arguments: data,
                  );
                },
                contextColor.secondaryColor,
                contextColor.territoryColor,
              ),
            ),
          if (model.status == Constant.statusExpired)
            Expanded(
              child: _buildButton(
                "renew".translate(context),
                () {
                  final isFreeAdListingEnabled =
                      Constant.systemSettings.isFreeAdListingEnabled;
                  if (isFreeAdListingEnabled) {
                    context.read<RenewItemCubit>().renewItem(itemId: model.id!);
                  } else {
                    PackageSelectBottomSheet.show(
                      context,
                      (packageId) {
                        if (packageId == null) return;
                        context.read<RenewItemCubit>().renewItem(
                          packageId: packageId,
                          itemId: model.id!,
                        );
                      },
                      category: model.category!,
                      adItemType: model.itemType!,
                    );
                  }
                },
                contextColor.secondaryColor,
                contextColor.territoryColor,
              ),
            ),
          if (model.status == Constant.statusInactive)
            changeItemStatusWidget(
              buttonName: "activate".translate(context),
              status: Constant.statusActive,
            ),
          if (isDeleteBtnVisible()) deleteItemWidget(),
          if (model.status == Constant.statusActive ||
              model.status == Constant.statusApproved)
            Expanded(
              child: _buildButton(
                model.category!.isJobCategory
                    ? "markAsClosed".translate(context)
                    : "soldOut".translate(context),
                () async {
                  Navigator.pushNamed(
                    context,
                    Routes.soldOutBoughtScreen,
                    arguments: {
                      "itemId": model.id,
                      "price": model.price,
                      "itemName": model.translatedName,
                      "itemImage": model.image,
                      "isJobCategory": model.category!.isJobCategory,
                    },
                  );
                },
                null,
                null,
              ),
            ),
          if (model.status == Constant.statusSoftRejected)
            changeItemStatusWidget(
              buttonName: "resubmit".translate(context),
              status: Constant.statusResubmitted,
            ),
        ],
      );
    } else {
      return BlocBuilder<FetchJobApplicationCubit, FetchJobApplicationState>(
        builder: (context, state) {
          final itemJobApplied = context.select(
            (FetchJobApplicationCubit cubit) =>
                cubit.getJobAppliedItem(model.id!),
          );
          return BlocBuilder<BuyingChatListCubit, ChatListState>(
            builder: (context, state) {
              final chatUser = context
                  .read<BuyingChatListCubit>()
                  .getChatFromItemId(model.id!);
              return BlocListener<MakeAnOfferItemCubit, MakeAnOfferItemState>(
                listener: (context, state) {
                  if (state is MakeAnOfferItemSuccess) {
                    context.read<BuyingChatListCubit>().addChatUser(
                      state.chatUser,
                    );

                    if (state.from == 'offer') {
                      HelperUtils.showSnackBarMessage(
                        context,
                        state.message.toString(),
                      );
                    }

                    Navigator.of(context).pushNamed(
                      Routes.chatScreen,
                      arguments: {'chat_user': state.chatUser},
                    );
                  }
                  if (state is MakeAnOfferItemFailure) {
                    HelperUtils.showSnackBarMessage(
                      context,
                      state.errorMessage.toString(),
                    );
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!model.category!.isJobCategory &&
                        (!model.category!.isPriceOptional ||
                            model.price != null))
                      if (chatUser == null)
                        Expanded(
                          child: _buildButton(
                            "makeAnOffer".translate(context),
                            () {
                              UiUtils.checkUser(
                                onNotGuest: () {
                                  safetyTipsBottomSheet();
                                },
                                context: context,
                              );
                            },
                            null,
                            null,
                          ),
                        ),
                    if (model.category!.isJobCategory)
                      if (itemJobApplied == null)
                        Expanded(
                          child: _buildButton(
                            "applyNow".translate(context),
                            () {
                              UiUtils.checkUser(
                                onNotGuest: () {
                                  Navigator.pushNamed(
                                    context,
                                    Routes.jobApplicationForm,
                                    arguments: widget.model,
                                  );
                                },
                                context: context,
                              );
                            },
                            null,
                            null,
                          ),
                        ),
                    if (chatUser == null || itemJobApplied == null)
                      SizedBox(width: 10),
                    Expanded(
                      child: _buildButton(
                        "chat".translate(context),
                        () {
                          UiUtils.checkUser(
                            onNotGuest: () {
                              if (chatUser != null) {
                                Navigator.of(context).pushNamed(
                                  Routes.chatScreen,
                                  arguments: {'chat_user': chatUser},
                                );
                              } else {
                                context
                                    .read<MakeAnOfferItemCubit>()
                                    .makeAnOfferItem(
                                      id: model.id!,
                                      from: "chat",
                                    );
                              }
                            },
                            context: context,
                          );
                        },
                        null,
                        null,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
  }

  void safetyTipsBottomSheet() async {
    List<SafetyTipsModel>? tipsList = context
        .read<FetchSafetyTipsListCubit>()
        .getList();
    if (tipsList == null || tipsList.isEmpty || 1 == 1) {
      final offer = await CreateOfferDialog.show(
        context,
        formattedPrice: model.formattedAmount ?? '',
        price: model.price!,
      );
      if (offer != null) {
        context.read<MakeAnOfferItemCubit>().makeAnOfferItem(
          id: model.id!,
          from: "offer",
          amount: offer,
        );
      }
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.0),
          topRight: Radius.circular(18.0),
        ),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: context.color.secondaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: context.color.textColorDark.withValues(alpha: 0.1),
                    ),
                    height: 6,
                    width: 60,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: CustomImage(
                  src: AppAssets.illustrators.safetyTips,
                  size: Size.square(100),
                  fit: BoxFit.scaleDown,
                  svgColorMapper: PrimaryColorMapper(
                    context.colorScheme.primary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 5),
                child: CustomText(
                  'safetyTips'.translate(context),
                  fontWeight: FontWeight.w600,
                  fontSize: context.font.larger,
                  textAlign: TextAlign.center,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: tipsList.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return checkmarkPoint(
                    context,
                    tipsList[index].translatedName!,
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: _buildButton(
                  "continueToOffer".translate(context),
                  () async {
                    Navigator.pop(context);
                    final offer = await CreateOfferDialog.show(
                      context,
                      formattedPrice: model.formattedAmount ?? '',
                      price: model.price!,
                    );
                    if (offer != null) {
                      context.read<MakeAnOfferItemCubit>().makeAnOfferItem(
                        id: model.id!,
                        from: "offer",
                        amount: offer,
                      );
                    }
                  },
                  context.color.territoryColor,
                  context.color.secondaryColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget checkmarkPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(AppIcons.checkBold, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: CustomText(
              text.firstUpperCase(),
              textAlign: TextAlign.start,
              color: context.color.textDefaultColor,
              fontSize: context.font.large,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String title,
    VoidCallback onPressed,
    Color? buttonColor,
    Color? textColor,
  ) {
    return UiUtils.buildButton(
      context,
      onPressed: onPressed,
      radius: 10,
      height: 46,
      border: buttonColor != null
          ? BorderSide(color: context.color.territoryColor)
          : null,
      buttonColor: buttonColor,
      textColor: textColor,
      buttonTitle: title,
      width: 50,
    );
  }

  Widget setLikesAndViewsCount() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                width: 1,
                color: context.color.textDefaultColor.withValues(alpha: 0.1),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            height: 46,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.eye),
                const SizedBox(width: 8),
                CustomText(
                  model.views != null ? model.views!.toString() : "0",
                  color: context.color.textDefaultColor.withValues(alpha: 0.8),
                  fontSize: context.font.large,
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                width: 1,
                color: context.color.textDefaultColor.withValues(alpha: 0.1),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            height: 46,
            //alignment: AlignmentDirectional.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.heart),
                const SizedBox(width: 8),
                CustomText(
                  model.totalLikes == null ? "0" : model.totalLikes.toString(),
                  color: context.color.textDefaultColor.withValues(alpha: 0.8),
                  fontSize: context.font.large,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget setRejectedReason() {
    if (model.status == Constant.statusPermanentRejected ||
        model.status == Constant.statusSoftRejected &&
            (model.translatedRejectedReason != null ||
                model.translatedRejectedReason != "")) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: context.color.textDefaultColor.withValues(alpha: 0.1),
          ),

          // Background color
        ),
        margin: const EdgeInsets.symmetric(vertical: 15),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Row(
          //crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.warningOctagon,
              size: 20,
              color: Colors.red, // Icon color can be adjusted
            ),
            SizedBox(width: 5),
            Expanded(
              child: CustomText(
                '${"rejectionReason".translate(context)}: ${model.translatedRejectedReason ?? 'N/A'}',
                color: context.color.textDefaultColor,
                fontSize: context.font.large,
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget adminEditedReason() {
    String message = model.translatedAdminEditReason!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: StatusColors.deactivateButtonColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StatusColors.deactivateButtonColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomImage(
            src: AppAssets.common.adminEdit,
            size: Size.square(40),
            svgColorMapper: SvgColorMapper(color: context.colorScheme.error),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "adEditedBy".translate(context),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: context.color.textDefaultColor,
                        ),
                      ),
                      TextSpan(
                        text: "\t${"admin".translate(context)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.color.textDefaultColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final span = TextSpan(
                      text: message,
                      style: TextStyle(color: context.color.textDefaultColor),
                    );
                    final tp = TextPainter(
                      text: span,
                      maxLines: 2,
                      textDirection: TextDirection.ltr,
                    );
                    tp.layout(maxWidth: (constraints.maxWidth - 65));
                    final isOverflowing = tp.didExceedMaxLines;

                    String displayText = message;
                    if (!isAdminEditedReasonExpanded && isOverflowing) {
                      int endIndex = tp
                          .getPositionForOffset(Offset(tp.width, tp.height))
                          .offset;
                      displayText = message.substring(0, endIndex).trim();
                    }

                    return Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: isAdminEditedReasonExpanded || !isOverflowing
                                ? message
                                : displayText + "...",
                            style: TextStyle(
                              color: context.color.textDefaultColor,
                            ),
                          ),
                          if (isOverflowing)
                            TextSpan(
                              text: isAdminEditedReasonExpanded
                                  ? "\t${"readLessLbl".translate(context)}"
                                  : "\t${"readMoreLbl".translate(context)}",
                              style: const TextStyle(
                                color: StatusColors.deactivateButtonColor,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  setState(() {
                                    isAdminEditedReasonExpanded =
                                        !isAdminEditedReasonExpanded;
                                  });
                                },
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget setPriceAndStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (UiUtils.displayPrice(model))
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: UiUtils.getPriceWidget(model, context),
            ),
          ),
        if (model.status != null && isAddedByMe)
          Container(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: _getStatusColor(model.status),
            ),
            child: CustomText(
              _getStatusCustomText(model.status)!,
              fontSize: context.font.normal,
              color: _getStatusTextColor(model.status),
            ),
          ),
      ],
    );
  }

  String? _getStatusCustomText(String? status) {
    switch (status) {
      case Constant.statusReview:
        return "underReview".translate(context);
      case Constant.statusActive:
        return "active".translate(context);
      case Constant.statusApproved:
        return "approved".translate(context);
      case Constant.statusInactive:
        return "deactivate".translate(context);
      case Constant.statusSoldOut:
        return model.category!.isJobCategory
            ? "jobClosed".translate(context)
            : "soldOut".translate(context);
      case Constant.statusPermanentRejected:
        return "permanentRejected".translate(context);
      case Constant.statusSoftRejected:
        return "softRejected".translate(context);
      case Constant.statusExpired:
        return "expired".translate(context);
      case Constant.statusResubmitted:
        return "resubmitted".translate(context);
      default:
        return status;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case Constant.statusReview || Constant.statusResubmitted:
        return StatusColors.pendingButtonColor.withValues(alpha: 0.1);
      case Constant.statusActive || Constant.statusApproved:
        return StatusColors.activateButtonColor.withValues(alpha: 0.1);
      case Constant.statusInactive:
        return StatusColors.deactivateButtonColor.withValues(alpha: 0.1);
      case Constant.statusSoldOut:
        return StatusColors.soldOutButtonColor.withValues(alpha: 0.1);
      case Constant.statusPermanentRejected || Constant.statusSoftRejected:
        return StatusColors.deactivateButtonColor.withValues(alpha: 0.1);
      case Constant.statusExpired:
        return StatusColors.deactivateButtonColor.withValues(alpha: 0.1);
      default:
        return context.color.territoryColor.withValues(alpha: 0.1);
    }
  }

  Color _getStatusTextColor(String? status) {
    switch (status) {
      case Constant.statusReview || Constant.statusResubmitted:
        return StatusColors.pendingButtonColor;
      case Constant.statusActive || Constant.statusApproved:
        return StatusColors.activateButtonColor;
      case Constant.statusInactive:
        return StatusColors.deactivateButtonColor;
      case Constant.statusSoldOut:
        return StatusColors.soldOutButtonColor;
      case Constant.statusPermanentRejected || Constant.statusSoftRejected:
        return StatusColors.deactivateButtonColor;
      case Constant.statusExpired:
        return StatusColors.deactivateButtonColor;
      default:
        return context.color.territoryColor;
    }
  }

  Widget setAddress() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            AppIcons.mapPinLine,
            color: context.colorScheme.primary,
            size: 16,
          ),
          Expanded(
            child: CustomText(
              UiUtils.formatDisplayAddress(model.translatedAddress ?? ''),
              color: context.color.textDefaultColor.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget setDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          "aboutThisItemLbl".translate(context),
          fontWeight: FontWeight.bold,
          fontSize: context.font.large,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: ExpandableText(
            text: model.translatedDescription!,
            maxLines: 10,
            style: context.bodyMedium.withColor(context.mutedColor),
          ),
        ),
      ],
    );
  }
}
