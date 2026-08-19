import 'dart:io';
import 'dart:ui' as ui;

import 'package:eClassify/data/cubits/fetch_my_reviews_cubit.dart';
import 'package:eClassify/data/cubits/my_item_review_report_cubit.dart';
import 'package:eClassify/data/model/user/my_review_model.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/screens/widgets/profile_avatar.dart';
import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/loading_overlay.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyReviewScreen extends StatefulWidget {
  const MyReviewScreen({super.key});

  @override
  MyReviewScreenState createState() => MyReviewScreenState();

  static Route route(RouteSettings routeSettings) {
    return MaterialPageRoute(builder: (_) => MyReviewScreen());
  }
}

class MyReviewScreenState extends State<MyReviewScreen> {
  late ScrollController reviewController;
  final TextEditingController _reportController = TextEditingController();

  @override
  void initState() {
    super.initState();
    reviewController = ScrollController()..addListener(_reviewLoadMore);
    context.read<FetchMyRatingsCubit>().fetch();
  }

  @override
  void dispose() {
    reviewController.removeListener(_reviewLoadMore);
    reviewController.dispose();
    _reportController.dispose();
    super.dispose();
  }

  void _reviewLoadMore() async {
    if (reviewController.isEndReached()) {
      if (context.read<FetchMyRatingsCubit>().hasMoreData()) {
        context.read<FetchMyRatingsCubit>().fetchMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('myReview'.translate(context))),
      body: SafeArea(bottom: Platform.isAndroid, child: ratingsListWidget()),
    );
  }

  Widget ratingsListWidget() {
    return BlocBuilder<FetchMyRatingsCubit, FetchMyRatingsState>(
      builder: (context, state) {
        if (state is FetchMyRatingsInProgress) {
          return Column(
            children: List.generate(3, (i) {
              return Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    spacing: 10,
                    children: [
                      CustomShimmer(height: 40, width: 40, borderRadius: 30),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 10,
                          children: [
                            CustomShimmer(width: 80, height: 15),
                            CustomShimmer(width: 180, height: 15),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        }

        if (state is FetchMyRatingsFail) {
          return QErrorWidget(
            error: state.error,
            onRetry: () {
              context.read<FetchMyRatingsCubit>().fetch();
            },
          );
        }
        if (state is FetchMyRatingsSuccess) {
          if (state.ratings.isEmpty) {
            return const QErrorWidget.emptyData();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Average Rating & Breakdown Section
                _buildMySummary(
                  state.averageRating!,
                  state.total,
                  state.ratings,
                  state.ratingsCount,
                ),

                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    controller: reviewController,
                    itemCount: state.ratings.length,
                    itemBuilder: (context, index) {
                      MyReviewModel ratings = state.ratings[index];

                      return _buildReviewCard(ratings, index);
                    },
                  ),
                ),
                if (state.isLoadingMore) UiUtils.progress(),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }

  // Rating summary widget (similar to the top section of your image)
  Widget _buildMySummary(
    double averageRating,
    int total,
    List<MyReviewModel> ratings,
    Map<String, int> ratingsCount,
  ) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          spacing: 10,
          children: [
            Column(
              spacing: 4,
              children: [
                Text(
                  averageRating.toStringAsFixed(2),
                  style: context.headlineMedium,
                ),
                CustomRatingBar(
                  rating: averageRating,
                  allowHalfRating: true,
                  inactiveColor: context.colorScheme.onSurface.withValues(
                    alpha: .15,
                  ),
                ),
                Text(
                  '$total ${'ratings'.translate(context)}',
                  style: context.labelLarge,
                ),
              ],
            ),
            Expanded(
              child: Column(
                children: List.generate(5, (i) {
                  final rating = 5 - i;
                  final count = ratingsCount['${rating}'] ?? 0;
                  final percentage = total == 0 ? 0.0 : count / total;
                  return Row(
                    spacing: 5,
                    children: [
                      SizedBox(
                        width: 10,
                        height: 20,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Text('$rating', style: context.labelMedium),
                        ),
                      ),
                      Icon(AppIcons.starFill, color: Colors.amber, size: 16),
                      Expanded(
                        child: TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: percentage),
                          duration: const Duration(milliseconds: 400),
                          builder: (context, value, child) {
                            return LinearProgressIndicator(
                              value: value,
                              color: Colors.amber,
                              backgroundColor: context.colorScheme.onSurface
                                  .withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(16),
                              minHeight: 8,
                            );
                          },
                        ),
                      ),
                      Text('$count', style: context.labelMedium),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String dateTime(String isoDate) {
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return isoDate;
    return timeago.format(dt, locale: '${AppSession.currentLocale}_short');
  }

  // Individual review card widget
  Widget _buildReviewCard(MyReviewModel ratings, int index) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            ProfileAvatar(
              src: ratings.buyer?.profile ?? '',
              size: Size.square(48),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ratings.buyer?.name ?? 'Unknown User',
                          style: context.titleMedium,
                        ),
                      ),
                      if (ratings.createdAt != null)
                        Text(
                          dateTime(ratings.createdAt!),
                          style: context.labelMedium.withColor(
                            context.mutedColor,
                          ),
                        ),
                      if (ratings.reportStatus == null)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8),
                          child: GestureDetector(
                            onTap: () {
                              reportAlertDialog(ratings.id!);
                            },
                            child: Icon(AppIcons.warningOctagon, size: 20),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      CustomRatingBar(
                        rating: ratings.ratings ?? 0,
                        allowHalfRating: true,
                        inactiveColor: context.colorScheme.onSurface.withValues(
                          alpha: .1,
                        ),
                      ),
                      Text(
                        '${ratings.ratings ?? 0}',
                        style: context.labelMedium.withColor(
                          context.mutedColor,
                        ),
                      ),
                    ],
                  ),
                  if ((ratings.review ?? '').isNotEmpty)
                    itemDetails(ratings, index),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: CustomImage(
                src: ratings.item?.image,
                size: Size.square(70),
                radius: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void reportAlertDialog(int sellerReviewId) async {
    await showDialog(
      context: context,
      barrierDismissible: true,

      // Set to false if you don't want the dialog to close by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.color.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Center(child: Text("reportReview".translate(context))),
          content:
              BlocListener<
                AddMyItemReviewReportCubit,
                AddMyItemReviewReportState
              >(
                listener: (context, state) {
                  if (state is AddMyItemReviewReportInSuccess) {
                    LoadingOverlay.hide();
                    Navigator.pop(context);
                    context.read<FetchMyRatingsCubit>().updateReportReason(
                      sellerReviewId,
                      _reportController.text.trim().toString(),
                    );
                    HelperUtils.showSnackBarMessage(
                      context,
                      state.responseMessage,
                    );
                    _reportController.clear();
                  }
                  if (state is AddMyItemReviewReportFailure) {
                    LoadingOverlay.hide();
                    Navigator.pop(context);
                    HelperUtils.showSnackBarMessage(
                      context,
                      state.error.toString(),
                    );
                  }
                  if (state is AddMyItemReviewReportInProgress) {
                    LoadingOverlay.show(context);
                  }
                },
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setStater) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            onChanged: (value) {
                              setStater(() {});
                              setState(() {});
                            },
                            controller: _reportController,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: context.color.territoryColor,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: context.color.textLightColor
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          actions: [
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colorScheme.surface,
                      foregroundColor: context.colorScheme.onSurface,
                    ),
                    onPressed: () {
                      _reportController.clear();
                      Navigator.of(context).pop();
                    },
                    child: Text('cancel'.translate(context)),
                  ),
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      context
                          .read<AddMyItemReviewReportCubit>()
                          .addMyItemReviewReport(
                            sellerReviewId: sellerReviewId,
                            reportReason: _reportController.text
                                .trim()
                                .toString(),
                          );
                    },
                    child: Text('submit'.translate(context)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget itemDetails(MyReviewModel ratings, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Expanded(
          child: Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ratings.item?.name?.localized ?? '',
                style: context.labelLarge,
              ),
              SizedBox(
                width: context.screenWidth * 0.63,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final span = TextSpan(
                      text: "${ratings.review!}\t",
                      style: context.bodySmall,
                    );
                    final tp = TextPainter(
                      text: span,
                      maxLines: 2,
                      textDirection: ui.TextDirection.ltr,
                    );
                    tp.layout(maxWidth: constraints.maxWidth);
                    final isOverflowing = tp.didExceedMaxLines;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            "${ratings.review!}\t",
                            maxLines: ratings.isExpanded! ? null : 2,
                            softWrap: true,
                            overflow: ratings.isExpanded!
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                            style: context.bodySmall,
                          ),
                        ),
                        if (isOverflowing)
                          Padding(
                            padding: EdgeInsetsDirectional.only(start: 3),
                            child: GestureDetector(
                              onTap: () {
                                context
                                    .read<FetchMyRatingsCubit>()
                                    .updateIsExpanded(index);
                              },
                              child: Text(
                                ratings.isExpanded!
                                    ? "readLessLbl".translate(context)
                                    : "readMoreLbl".translate(context),
                                style: context.labelMedium.withColor(
                                  context.color.territoryColor,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              if (ratings.reportReason != null) ...[
                Divider(),
                Text(
                  "${"reportReason".translate(context)}: ${ratings.reportReason}",
                  style: context.bodySmall.withColor(
                    context.colorScheme.onSurface.withValues(alpha: .5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget buildItemsShimmer(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      children: [
        Row(
          children: [
            CustomShimmer(
              height: MediaQuery.of(context).size.height / 3.2,
              width: context.screenWidth / 2.3,
            ),
            SizedBox(width: 10),
            CustomShimmer(
              height: MediaQuery.of(context).size.height / 3.2,
              width: context.screenWidth / 2.3,
            ),
          ],
        ),
        SizedBox(height: 5),
        Row(
          children: [
            CustomShimmer(
              height: MediaQuery.of(context).size.height / 3.2,
              width: context.screenWidth / 2.3,
            ),
            SizedBox(width: 10),
            CustomShimmer(
              height: MediaQuery.of(context).size.height / 3.2,
              width: context.screenWidth / 2.3,
            ),
          ],
        ),
      ],
    );
  }
}

class CustomRatingBar extends StatelessWidget {
  final double rating; // The rating value (e.g., 4.5)

  final double itemSize; // Size of each star icon
  final Color activeColor; // Color for filled stars
  final Color inactiveColor; // Color for unfilled stars
  final bool allowHalfRating; // Whether to allow half-star ratings

  const CustomRatingBar({
    Key? key,
    required this.rating,
    this.itemSize = 16.0,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
    this.allowHalfRating = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        // Determine whether to display a full star, half star, or empty star
        IconData icon;
        if (index < rating.floor()) {
          icon = AppIcons.starFill; // Full star
        } else if (allowHalfRating && index < rating) {
          icon = AppIcons.starHalfFill; // Half star
        } else {
          icon = AppIcons.starFill; // Empty star
        }

        return Icon(
          icon,
          color: index < rating ? activeColor : inactiveColor,
          size: itemSize,
        );
      }),
    );
  }
}
