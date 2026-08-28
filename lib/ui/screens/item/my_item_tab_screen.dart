import 'dart:developer';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/item/delete_item_cubit.dart';
import 'package:eClassify/data/cubits/item/fetch_my_item_cubit.dart';
import 'package:eClassify/data/model/item/ad_item_type.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/screens/advertisement/details/widgets/dialogs/delete_advertisement_dialog.dart';
import 'package:eClassify/ui/screens/item/item_listeners.dart';
import 'package:eClassify/ui/screens/widgets/contained_blur_image.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_data_found.dart';
import 'package:eClassify/ui/screens/widgets/promoted_widget.dart';
import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/collection_notifiers.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

Map<String, FetchMyItemsCubit> myAdsCubitReference = {};

class MyItemTab extends StatefulWidget {
  final String? getItemsWithStatus;

  const MyItemTab({super.key, this.getItemsWithStatus});

  @override
  State<MyItemTab> createState() => _MyItemTabState();
}

class _MyItemTabState extends State<MyItemTab> {
  final ScrollController _pageScrollController = ScrollController();
  final SetNotifier<int> _selectedItems = SetNotifier({});
  final ListNotifier<ItemModel> _filteredItems = ListNotifier({});
  final OverlayPortalController _overlayController = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    if (HiveUtils.isUserAuthenticated()) {
      context.read<FetchMyItemsCubit>().fetchMyItems(
        getItemsWithStatus: widget.getItemsWithStatus,
      );
      _pageScrollController.addListener(_pageScroll);
      setReferenceOfCubit();
    }

    _selectedItems.addListener(() {
      if (_selectedItems.isEmpty) {
        _overlayController.hide();
      }
    });
  }

  @override
  void dispose() {
    if (_overlayController.isShowing) {
      _overlayController.hide();
    }
    _selectedItems.dispose();
    _filteredItems.dispose();
    _pageScrollController.dispose();
    super.dispose();
  }

  void _pageScroll() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchMyItemsCubit>().hasMoreData()) {
        context.read<FetchMyItemsCubit>().fetchMyMoreItems(
          getItemsWithStatus: widget.getItemsWithStatus,
        );
      }
    }
  }

  void setReferenceOfCubit() {
    myAdsCubitReference[widget.getItemsWithStatus!] = context
        .read<FetchMyItemsCubit>();
  }

  ListView shimmerEffect() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      itemCount: 5,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 12);
      },
      itemBuilder: (context, index) {
        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CustomShimmer(height: 90, width: 90, borderRadius: 15),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    return Column(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 10),
                        CustomShimmer(height: 10, width: c.maxWidth - 50),
                        const CustomShimmer(height: 10),
                        CustomShimmer(height: 10, width: c.maxWidth / 1.2),
                        Align(
                          alignment: AlignmentDirectional.bottomStart,
                          child: CustomShimmer(width: c.maxWidth / 4),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget showAdminEdited() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
      //margin: EdgeInsetsDirectional.only(end: 4, start: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: StatusColors.deactivateButtonColor.withValues(alpha: 0.1),
      ),
      child: CustomText(
        "adminEdited".translate(context),
        fontSize: context.font.small,
        maxLines: 1,
        color: StatusColors.deactivateButtonColor,
      ),
    );
  }

  Widget showStatus(ItemModel model) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: _getStatusColor(model.status),
      ),
      child: CustomText(
        _getStatusCustomText(model)!,
        fontSize: context.font.small,
        maxLines: 1,
        color: _getStatusTextColor(model.status),
      ),
    );
  }

  String? _getStatusCustomText(ItemModel model) {
    switch (model.status) {
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
        return model.status;
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

  @override
  Widget build(BuildContext context) {
    return ItemListeners(
      onComplete: (isSuccess) {
        _overlayController.hide();
        _selectedItems.clear();
        if (isSuccess) {
          context.read<FetchMyItemsCubit>().fetchMyItems(
            getItemsWithStatus: widget.getItemsWithStatus,
          );
        }
      },
      child: BlocBuilder<FetchMyItemsCubit, FetchMyItemsState>(
        builder: (context, state) {
          if (state is FetchMyItemsInProgress) {
            return shimmerEffect();
          }

          if (state is FetchMyItemsFailed) {
            return QErrorWidget(
              error: state.error,
              onRetry: () {
                context.read<FetchMyItemsCubit>().fetchMyItems(
                  getItemsWithStatus: widget.getItemsWithStatus,
                );
              },
            );
          }

          if (state is FetchMyItemsSuccess) {
            _filteredItems.replaceAll(state.items);
            if (state.items.isEmpty) {
              return NoDataFound(
                mainMessage: "noAdsFound".translate(context),
                subMessage: "noAdsAvailable".translate(context),
                onTap: () {
                  context.read<FetchMyItemsCubit>().fetchMyItems(
                    getItemsWithStatus: widget.getItemsWithStatus,
                  );
                },
              );
            }

            return OverlayPortal(
              controller: _overlayController,
              overlayChildBuilder: (context) => _optionsOverlay(context, () {
                _selectedItems.clear();
                _filteredItems.replaceAll(state.items);
                _overlayController.hide();
              }),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 5,
                children: [
                  if (widget.getItemsWithStatus == Constant.statusExpired)
                    ColoredBox(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: CustomText(
                          '${"note".translate(context)}: ${"expiredItemsMultiRenewNote".translate(context)}',
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ListenableBuilder(
                    listenable: _selectedItems,
                    builder: (context, child) {
                      return _selectedItems.isEmpty
                          ? const SizedBox.shrink()
                          : Row(
                              children: [
                                Checkbox(
                                  value:
                                      _selectedItems.length ==
                                      _filteredItems.length,
                                  activeColor: context.color.territoryColor,
                                  onChanged: (value) {
                                    if (value == null) return;
                                    if (value) {
                                      final items = _filteredItems.value.map(
                                        (item) => item.id!,
                                      );
                                      _selectedItems.addAll(items);
                                    } else {
                                      _selectedItems.clear();
                                      if (!_filteredItems.isEmpty) {
                                        _filteredItems.replaceAll(state.items);
                                      }
                                    }
                                  },
                                ),
                                Expanded(
                                  child: CustomText(
                                    'selectAll'.translate(context),
                                    color: context.color.territoryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                CustomText(
                                  '${_selectedItems.value.length} ${'itemsSelected'.translate(context)}',
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            );
                    },
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      triggerMode: RefreshIndicatorTriggerMode.anywhere,
                      onRefresh: () async {
                        context.read<FetchMyItemsCubit>().fetchMyItems(
                          getItemsWithStatus: widget.getItemsWithStatus,
                        );

                        setReferenceOfCubit();
                      },
                      color: context.color.territoryColor,
                      child: ListenableBuilder(
                        listenable: _filteredItems,
                        builder: (context, child) {
                          return ListView.separated(
                            itemCount: _filteredItems.length,
                            physics: const AlwaysScrollableScrollPhysics(),
                            controller: _pageScrollController,
                            padding: const EdgeInsets.only(bottom: 20),
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 8);
                            },
                            itemBuilder: (context, index) {
                              ItemModel item = _filteredItems[index];

                              return ListenableBuilder(
                                listenable: _selectedItems,
                                builder: (context, child) {
                                  final isSelected = _selectedItems.value
                                      .contains(item.id!);
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(15),
                                    onTap: () {
                                      if (_selectedItems.isEmpty) {
                                        Navigator.pushNamed(
                                          context,
                                          Routes.adDetailsScreen,
                                          arguments: {
                                            "item_id": item.id,
                                            'is_my_ad': true,
                                            'status_tab':
                                                widget.getItemsWithStatus,
                                          },
                                        ).then((value) {
                                          if (value == "refresh" ||
                                              value == true) {
                                            context
                                                .read<FetchMyItemsCubit>()
                                                .fetchMyItems(
                                                  getItemsWithStatus:
                                                      widget.getItemsWithStatus,
                                                );

                                            setReferenceOfCubit();
                                          }
                                        });
                                      } else {
                                        _selectedItems.toggle(item.id!);
                                        if (_selectedItems.isEmpty) {
                                          _filteredItems.replaceAll(
                                            state.items,
                                          );
                                        }
                                      }
                                    },
                                    onLongPress:
                                        widget.getItemsWithStatus ==
                                                Constant.statusExpired ||
                                            item.status ==
                                                Constant.statusExpired
                                        ? () {
                                            if (!_selectedItems.isEmpty) return;
                                            if (item.status ==
                                                Constant.statusExpired) {
                                              final filteredItems = state.items
                                                  .where(
                                                    (item) =>
                                                        item.status ==
                                                        Constant.statusExpired,
                                                  );
                                              _filteredItems.replaceAll(
                                                filteredItems,
                                              );
                                            }
                                            if (!_selectedItems.isEmpty) return;
                                            _overlayController.show();
                                            _selectedItems.add(item.id!);
                                          }
                                        : null,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Container(
                                        height: 130,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          color:
                                              item.status ==
                                                      Constant.statusInactive ||
                                                  isSelected
                                              ? context.color.deactivateColor
                                                    .withValues(
                                                      alpha: isSelected
                                                          ? .1
                                                          : 0.5,
                                                    )
                                              : context.color.secondaryColor,
                                          border: Border.all(
                                            color: context.color.textLightColor
                                                .withValues(alpha: 0.18),
                                            width: 1,
                                          ),
                                        ),
                                        width: double.infinity,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 110,
                                              height: 130,
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
                                                    child: ContainedBlurImage(
                                                      src: item.image!,
                                                      size: const Size(
                                                        110,
                                                        130,
                                                      ),
                                                      radius: 15,
                                                    ),
                                                  ),
                                                  if (item.isFeature ?? false)
                                                    const PositionedDirectional(
                                                      start: 5,
                                                      top: 5,
                                                      child: PromotedCard(),
                                                    ),
                                                  if (isSelected)
                                                    PositionedDirectional(
                                                      end: 2,
                                                      top: 2,
                                                      child: Checkbox(
                                                        value: true,
                                                        onChanged: null,
                                                        fillColor:
                                                            WidgetStatePropertyAll(
                                                              context
                                                                  .color
                                                                  .territoryColor,
                                                            ),
                                                        visualDensity:
                                                            VisualDensity
                                                                .compact,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 8,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12.0,
                                                      vertical: 15,
                                                    ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Row(
                                                      spacing: 10,
                                                      children: [
                                                        if (item.isEditedByAdmin ==
                                                            1)
                                                          Flexible(
                                                            child:
                                                                showAdminEdited(),
                                                          ),
                                                        Expanded(
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional
                                                                    .centerStart,
                                                            child: showStatus(
                                                              item,
                                                            ),
                                                          ),
                                                        ),
                                                        if (item.itemType ==
                                                            AdItemType
                                                                .videoAd) ...[
                                                          CircleAvatar(
                                                            radius: 12,
                                                            backgroundColor:
                                                                context
                                                                    .colorScheme
                                                                    .primary
                                                                    .withValues(
                                                                      alpha: .1,
                                                                    ),
                                                            foregroundColor:
                                                                context
                                                                    .colorScheme
                                                                    .primary,
                                                            child: Icon(
                                                              AppIcons
                                                                  .playCircle,
                                                              size: 16,
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        if (UiUtils.displayPrice(
                                                          item,
                                                        ))
                                                          Expanded(
                                                            child:
                                                                UiUtils.getPriceWidget(
                                                                  item,
                                                                  context,
                                                                ),
                                                          )
                                                        else
                                                          Expanded(
                                                            child: CustomText(
                                                              item.translatedName ??
                                                                  "",
                                                              maxLines: 2,
                                                              firstUpperCaseWidget:
                                                                  true,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    if (UiUtils.displayPrice(
                                                      item,
                                                    ))
                                                      CustomText(
                                                        item.translatedName ??
                                                            "",
                                                        maxLines: 2,
                                                        firstUpperCaseWidget:
                                                            true,
                                                      ),
                                                    Row(
                                                      spacing: 20,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Flexible(
                                                          flex: 1,
                                                          child: Row(
                                                            spacing: 4,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                PhosphorIcons
                                                                    .eye,
                                                                size: 15,
                                                              ),
                                                              CustomText(
                                                                "${"views".translate(context)}:${item.views}",
                                                                fontSize:
                                                                    context
                                                                        .font
                                                                        .small,
                                                                color: context
                                                                    .color
                                                                    .textColorDark
                                                                    .withValues(
                                                                      alpha:
                                                                          0.5,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Flexible(
                                                          flex: 1,
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                PhosphorIcons
                                                                    .heart,
                                                                size: 15,
                                                              ),
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              CustomText(
                                                                "${"like".translate(context)}:${item.totalLikes.toString()}",
                                                                fontSize:
                                                                    context
                                                                        .font
                                                                        .small,
                                                                color: context
                                                                    .color
                                                                    .textColorDark
                                                                    .withValues(
                                                                      alpha:
                                                                          0.5,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  if (state.isLoadingMore) UiUtils.progress(),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _optionsOverlay(BuildContext context, VoidCallback resetState) {
    final buttonStyle = FilledButton.styleFrom(
      backgroundColor: context.color.territoryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: Theme.of(context).textTheme.titleMedium,
    );

    log(
      '${kBottomNavigationBarHeight} ${MediaQuery.paddingOf(context).bottom}',
    );
    return Stack(
      children: [
        PositionedDirectional(
          end: 10,
          bottom: kBottomNavigationBarHeight * 2,
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: .8, end: 1),
            duration: const Duration(milliseconds: 400),
            curve: Curves.decelerate,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child!);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 10,
              children: [
                // FilledButton.icon(
                //   style: buttonStyle,
                //   onPressed: () async {
                //     final isFreeAdListingEnabled =
                //         Constant.systemSettings.isFreeAdListingEnabled;
                //     if (isFreeAdListingEnabled) {
                //       context.read<RenewItemCubit>().renewMultiItems(
                //         ids: _selectedItems.value,
                //       );
                //     } else {
                //       await PackageSelectBottomSheet.show(context, (packageId) {
                //         if (packageId == null) {
                //           resetState();
                //           return;
                //         }
                //         context.read<RenewItemCubit>().renewMultiItems(
                //           ids: _selectedItems.value,
                //           packageId: packageId,
                //         );
                //       });
                //     }
                //   },
                //   label: Text('renew'.translate(context)),
                //   icon: Icon(Icons.autorenew),
                // ),
                FilledButton.icon(
                  style: buttonStyle,
                  onPressed: () async {
                    final shouldDelete =
                        await DeleteAdvertisementDialog.show(context) ?? false;
                    if (shouldDelete) {
                      context.read<DeleteItemCubit>().deleteMultiItem(
                        ids: _selectedItems.value,
                      );
                    }
                  },
                  label: Text('delete'.translate(context)),
                  icon: Icon(AppIcons.trash),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
