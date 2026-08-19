import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/app_assets.dart';
import 'package:eClassify/utils/color_mappers/primary_color_mapper.dart';
import 'package:flutter/material.dart';

List kOnboardingList = [
  {
    'svg': AppAssets.illustrators.onboardingA,
    'title': "onboarding_1_title",
    'description': "onboarding_1_des",
  },
  {
    'svg': AppAssets.illustrators.onboardingB,
    'title': "onboarding_2_title",
    'description': "onboarding_2_des",
  },
  {
    'svg': AppAssets.illustrators.onboardingC,
    'title': "onboarding_3_title",
    'description': "onboarding_3_des",
  },
];

class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({required this.controller, super.key});

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: kOnboardingList.length,
      itemBuilder: (context, index) {
        final data = kOnboardingList[index];
        return CustomImage(
          src: data['svg'] as String,
          svgColorMapper: PrimaryColorMapper(context.colorScheme.primary),
          fit: BoxFit.contain,
        );
      },
    );
  }
}
