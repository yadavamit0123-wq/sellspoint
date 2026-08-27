import 'package:eClassify/data/cubits/home/featured_section_cubit.dart';
import 'package:eClassify/data/cubits/home/home_items_cubit.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/new_development/status/models/status_models.dart';
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

            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: StatusWidget(allStatus: allStatus),
            );
          },
        );
      },
    );
  }

  List<StatusModel> _collectStatusItems(
    FeaturedSectionState featuredState,
    HomeItemsState homeItemsState,
  ) {
    final seenIds = <int>{};
    final allStatus = <StatusModel>[];

    void addFromItem(ItemModel item) {
      final id = item.id;
      if (id == null || seenIds.contains(id)) return;

      final images = (item.galleryImages ?? [])
          .map((image) => image.image)
          .whereType<String>()
          .where((url) => url.isNotEmpty)
          .toList();
      if (images.isEmpty) return;

      seenIds.add(id);
      allStatus.add(
        StatusModel(
          item: item,
          name: item.user?.name ?? '',
          avatarUrl: item.user?.profile ?? '',
          mediaUrls: images,
          description: item.name ?? '',
        ),
      );
    }

    if (featuredState is FeaturedScreenSuccess) {
      for (final section in featuredState.sections) {
        for (final item in section.items) {
          addFromItem(item);
        }
      }
    }

    if (homeItemsState is HomeItemsSuccess) {
      for (final item in homeItemsState.items) {
        addFromItem(item);
      }
    }

    return allStatus;
  }
}
