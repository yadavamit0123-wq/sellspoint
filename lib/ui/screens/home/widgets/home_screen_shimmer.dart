import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:flutter/material.dart';

class HomeScreenShimmer extends StatelessWidget {
  const HomeScreenShimmer({super.key});

  Widget _titleAndContentShimmer({required Widget content}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [CustomShimmer(height: 20, width: 200), content],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: Constant.appContentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: [
          CustomShimmer(height: 60),
          SizedBox(
            height: 30,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, _) => 10.hGap,
              itemBuilder: (_, _) => CustomShimmer(height: 30, width: 100),
            ),
          ),
          AspectRatio(aspectRatio: 2, child: CustomShimmer(height: 200)),
          _titleAndContentShimmer(
            content: SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                separatorBuilder: (_, _) => 10.hGap,
                itemBuilder: (_, _) => Column(
                  spacing: 5,
                  children: [
                    CustomShimmer(height: 70, width: 70, borderRadius: 18),
                    CustomShimmer(height: 20, width: 70, borderRadius: 18),
                  ],
                ),
              ),
            ),
          ),
          _titleAndContentShimmer(
            content: SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                separatorBuilder: (_, _) => 10.hGap,
                itemBuilder: (_, _) =>
                    CustomShimmer(height: 200, width: 200, borderRadius: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
