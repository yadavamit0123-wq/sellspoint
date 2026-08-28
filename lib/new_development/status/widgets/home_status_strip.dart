import 'package:eClassify/data/cubits/home/featured_section_cubit.dart';
import 'package:eClassify/data/cubits/home/home_items_cubit.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/new_development/status/models/status_models.dart';
import 'package:eClassify/new_development/status/utils/status_item_collector.dart';
import 'package:eClassify/new_development/status/widgets/status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Builds the horizontal status strip on home (old live: featured + home ads).
class HomeStatusStrip extends StatelessWidget {
  const HomeStatusStrip({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.enableStatusStories) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<FeaturedSectionCubit, FeaturedSectionState>(
      builder: (context, featuredState) {
        return BlocBuilder<HomeItemsCubit, HomeItemsState>(
          builder: (context, homeItemsState) {
            final allStatus = _collectStatusItems(
              featuredState,
              homeItemsState,
            );

            if (allStatus.isEmpty) {
              return const SizedBox.shrink();
            }

            return StatusWidget(allStatus: allStatus);
          },
        );
      },
    );
  }

  List<StatusModel> _collectStatusItems(
    FeaturedSectionState featuredState,
    HomeItemsState homeItemsState,
  ) {
    final items = <ItemModel>[];

    if (featuredState is FeaturedScreenSuccess) {
      for (final section in featuredState.sections) {
        items.addAll(section.items);
      }
    }

    if (homeItemsState is HomeItemsSuccess) {
      items.addAll(homeItemsState.items);
    }

    return collectStatusFromItems(items);
  }
}
