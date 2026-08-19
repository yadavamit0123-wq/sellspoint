import 'dart:math';

import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class FeaturesAnimatedList extends StatefulWidget {
  const FeaturesAnimatedList({required this.points, required this.title, super.key});

  final List<String> points;
  final String title;

  @override
  State<FeaturesAnimatedList> createState() => _FeaturesAnimatedListState();
}

class _FeaturesAnimatedListState extends State<FeaturesAnimatedList> {
  final ValueNotifier<bool> _showMore = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _showMore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Text(
          widget.title,
          style: context.labelMedium.withColor(context.mutedColor),
        ),
        AnimatedSize(
          alignment: Alignment.topCenter,
          duration: const Duration(milliseconds: 300),
          child: ValueListenableBuilder(
            valueListenable: _showMore,
            builder: (context, value, child) {
              final totalKeyPoints = widget.points.length;
              final totalKeyPointsToShow = value
                  ? totalKeyPoints
                  : min(3, totalKeyPoints);
              final shouldShowViewMore = totalKeyPoints > totalKeyPointsToShow;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(totalKeyPointsToShow, (index) {
                  return RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            AppIcons.checkCircleFill,
                            color: Colors.green,
                            size: 16,
                          ),
                        ),
                        const TextSpan(text: '\t\t'),
                        TextSpan(
                          text: widget.points[index],
                          style: context.labelLarge,
                        ),
                        if (index == totalKeyPointsToShow - 1 &&
                            (shouldShowViewMore || value)) ...[
                          const TextSpan(text: '\t'),
                          TextSpan(
                            text: value
                                ? 'viewLess'.translate(context)
                                : 'viewMore'.translate(context),
                            style: context.labelLarge.copyWith(
                              color: context.colorScheme.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: context.colorScheme.primary,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _showMore.value = !_showMore.value;
                              },
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}
