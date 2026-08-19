import 'package:collection/collection.dart';
import 'package:eClassify/data/cubits/banner/banner_ad_cubit.dart';
import 'package:eClassify/data/cubits/home/featured_section_cubit.dart';
import 'package:eClassify/data/model/banner/banner_ad.dart';
import 'package:eClassify/ui/screens/home/widgets/featured_section/featured_section_header.dart';
import 'package:eClassify/ui/screens/home/widgets/featured_section/featured_section_sliver.dart';
import 'package:eClassify/ui/screens/home/widgets/featured_section/featured_section_style.dart';
import 'package:eClassify/ui/screens/widgets/banner_widget.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeaturedSectionWidget extends StatelessWidget {
  const FeaturedSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(vertical: 5),
      sliver: BlocBuilder<FeaturedSectionCubit, FeaturedSectionState>(
        builder: (context, state) {
          if (state is FeaturedSectionLoading) {
            return SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: Constant.horizontalPadding,
                vertical: 10,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    CustomShimmer(height: 20, width: 200),
                    SizedBox(
                      height: 200,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 6,
                        separatorBuilder: (_, _) => 10.hGap,
                        itemBuilder: (_, _) => CustomShimmer(
                          height: 200,
                          width: 200,
                          borderRadius: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is FeaturedScreenSuccess) {
            final banners = context.watch<HomeBannerAdCubit>().featuredBanners;
            final bannersById = groupBy(
              banners,
              (b) => '${b.featuredSectionId}_${b.placement.name}',
            );

            Widget? _resolveAdBannerWidget(String key) {
              final banner = bannersById[key]?.firstOrNull;

              return banner != null
                  ? SliverToBoxAdapter(child: BannerWidget(bannerAd: banner))
                  : null;
            }

            if (state.sections.isNotEmpty) {
              return SliverMainAxisGroup(
                slivers: state.sections.map((section) {
                  final style = FeaturedSectionStyles.styleFromName(
                    section.style,
                  );
                  return SliverMainAxisGroup(
                    slivers: [
                      ?_resolveAdBannerWidget(
                        '${section.id}_${BannerPlacement.above.name}',
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Constant.horizontalPadding,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: FeaturedSectionHeader(
                            id: section.id,
                            title: section.title.localized,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 10)),
                      FeaturedSectionSliver(
                        style: style!,
                        items: section.items,
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 10)),
                      ?_resolveAdBannerWidget(
                        '${section.id}_${BannerPlacement.below.name}',
                      ),
                    ],
                  );
                }).toList(),
              );
            }
          }

          return SliverToBoxAdapter(child: const SizedBox.shrink());
        },
      ),
    );
  }
}
