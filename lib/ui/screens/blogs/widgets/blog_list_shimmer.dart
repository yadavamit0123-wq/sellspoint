import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:flutter/material.dart';

class BlogListShimmer extends StatelessWidget {
  const BlogListShimmer({this.isSliver = false, super.key});

  final bool isSliver;

  @override
  Widget build(BuildContext context) {
    final shimmerItem = Column(
      spacing: 5,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(aspectRatio: 2, child: CustomShimmer(borderRadius: 12)),
        CustomShimmer(height: 20, width: 300, borderRadius: 8),
        CustomShimmer(height: 10, width: double.maxFinite, borderRadius: 8),
        CustomShimmer(height: 10, width: 300, borderRadius: 8),
      ],
    );

    if (isSliver) {
      return SliverList.separated(
        itemBuilder: (_, _) => shimmerItem,
        separatorBuilder: (_, _) => 15.vGap,
        itemCount: 5,
      );
    }

    return ListView.separated(
      itemBuilder: (_, _) => shimmerItem,
      separatorBuilder: (_, _) => 15.vGap,
      itemCount: 5,
    );
  }
}
