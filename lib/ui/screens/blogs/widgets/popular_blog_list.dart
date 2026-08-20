import 'package:eClassify/data/cubits/blog/popular_blog_list_cubit.dart';
import 'package:eClassify/ui/screens/blogs/widgets/blog_item.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PopularBlogList extends StatelessWidget {
  const PopularBlogList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PopularBlogListCubit, PopularBlogListState>(
      builder: (context, state) {
        if (state is PopularBlogListInitial) {
          context.read<PopularBlogListCubit>().getPopularBlogs();
        }
        if (state is PopularBlogListLoading) {
          return SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: Constant.horizontalPadding,
              ),
              itemCount: 5,
              separatorBuilder: (_, __) => 10.hGap,
              itemBuilder: (_, __) => const SizedBox(
                width: 250,
                child: Column(
                  spacing: 5,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 2,
                      child: CustomShimmer(borderRadius: 12),
                    ),
                    CustomShimmer(height: 20, width: 150, borderRadius: 8),
                    CustomShimmer(
                      height: 10,
                      width: double.maxFinite,
                      borderRadius: 8,
                    ),
                    CustomShimmer(height: 10, width: 150, borderRadius: 8),
                  ],
                ),
              ),
            ),
          );
        }
        if (state is PopularBlogListSuccess) {
          if (state.blogs.isEmpty) {
            return const SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Constant.horizontalPadding,
                ),
                child: Text('Popular Blogs', style: context.titleMedium),
              ),
              SizedBox(
                height: 260,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: Constant.horizontalPadding,
                  ),
                  itemCount: state.blogs.length,
                  separatorBuilder: (_, __) => 10.hGap,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 280,
                      child: BlogItem(blog: state.blogs[index]),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
