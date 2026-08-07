import 'package:eClassify/ui/screens/home/widgets/home_search.dart';
import 'package:flutter/material.dart';

/// Pinned home search under the app bar ([AppConfig.enableHomeSliverV214]).
class HomeStickySearchDelegate extends SliverPersistentHeaderDelegate {
  HomeStickySearchDelegate({required this.backgroundColor});

  final Color backgroundColor;

  static const double extent = 78;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: backgroundColor,
      elevation: overlapsContent ? 0.5 : 0,
      child: const Align(
        alignment: Alignment.bottomCenter,
        child: HomeSearchField(),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant HomeStickySearchDelegate oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor;
  }
}
