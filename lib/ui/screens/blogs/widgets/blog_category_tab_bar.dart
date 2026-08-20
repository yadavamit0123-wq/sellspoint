import 'package:eClassify/data/cubits/blog/blog_category_cubit.dart';
import 'package:eClassify/ui/screens/widgets/app_tab_bar.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogCategoryTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  const BlogCategoryTabBar({required this.controllerProvider, super.key});

  final TabController? Function() controllerProvider;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlogCategoryCubit, BlogCategoryState>(
      builder: (context, state) {
        if (state is BlogCategoryInitial) {
          context.read<BlogCategoryCubit>().getBlogCategories();
        }
        if (state is BlogCategoryFailure) {
          return const SizedBox.shrink();
        }
        if (state is BlogCategorySuccess) {
          final controller = controllerProvider();
          if (controller == null) return const SizedBox.shrink();
          return AppTabBar(
            controller: controller,
            tabs: state.categories
                .map((category) => category.name.localized)
                .toList(),
          );
        }
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: context.colorScheme.outline)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: kToolbarHeight * 1.5),
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: Constant.horizontalPadding,
                vertical: 20,
              ),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, _) =>
                  CustomShimmer(height: 20, width: 100, borderRadius: 8),
              separatorBuilder: (_, _) => 5.hGap,
              itemCount: 5,
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight * 1.5);
}
