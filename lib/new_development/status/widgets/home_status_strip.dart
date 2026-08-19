import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/home/featured_section_cubit.dart';
import 'package:eClassify/new_development/status/models/status_models.dart';
import 'package:eClassify/new_development/status/widgets/status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Builds the horizontal status strip on home from featured-section listings.
class HomeStatusStrip extends StatelessWidget {
  const HomeStatusStrip({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.enableStatusStories) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<FeaturedSectionCubit, FeaturedSectionState>(
      builder: (context, state) {
        if (state is! FeaturedScreenSuccess) {
          return const SizedBox.shrink();
        }

        final allStatus = <StatusModel>[];
        for (final section in state.sections) {
          for (final item in section.items) {
            final images = (item.galleryImages ?? [])
                .map((image) => image.image)
                .whereType<String>()
                .where((url) => url.isNotEmpty)
                .toList();
            if (images.isEmpty) continue;

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
        }

        if (allStatus.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: StatusWidget(allStatus: allStatus),
        );
      },
    );
  }
}
