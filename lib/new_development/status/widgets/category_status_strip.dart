import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/item/item_list_cubit.dart';
import 'package:eClassify/new_development/status/utils/status_item_collector.dart';
import 'package:eClassify/new_development/status/widgets/status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Status strip scoped to items in the current category listing.
class CategoryStatusStrip extends StatelessWidget {
  const CategoryStatusStrip({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.enableStatusStories) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<ItemListCubit, ItemListState>(
      builder: (context, state) {
        if (state is! ItemListSuccess) {
          return const SizedBox.shrink();
        }

        final allStatus = collectStatusFromItems(state.items);
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
