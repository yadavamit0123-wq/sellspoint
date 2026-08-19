import 'package:eClassify/data/cubits/blog/blog_list_cubit.dart';
import 'package:eClassify/data/model/blog/blog_tag.dart';
import 'package:eClassify/ui/screens/blogs/widgets/blog_item.dart';
import 'package:eClassify/ui/screens/blogs/widgets/blog_list_shimmer.dart';
import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogList extends StatefulWidget {
  const BlogList({
    required this.categoryId,
    required this.selectedTag,
    required this.isActive,
    super.key,
  });

  final int? categoryId;
  final BlogTag? selectedTag;
  final bool isActive;

  @override
  State<BlogList> createState() => _BlogListState();
}

class _BlogListState extends State<BlogList>
    with AutomaticKeepAliveClientMixin {
  late final BlogListCubit _cubit;
  BlogTag? _lastFetchedTag;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _cubit = BlogListCubit(widget.categoryId);
    _lastFetchedTag = widget.selectedTag;
    if (widget.isActive) {
      _cubit.getBlogs(tag: widget.selectedTag?.value);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(BlogList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive) {
      if (_cubit.state is BlogListInitial || _lastFetchedTag != widget.selectedTag) {
        _lastFetchedTag = widget.selectedTag;
        _cubit.getBlogs(tag: widget.selectedTag?.value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider.value(
      value: _cubit,
      child: Builder(
        builder: (context) {
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.isNearBottom &&
                  context.read<BlogListCubit>().hasMore) {
                context.read<BlogListCubit>().getMoreBlogs();
              }
              return true;
            },
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(
                parent: const AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Constant.horizontalPadding,
                  ),
                  sliver: BlocBuilder<BlogListCubit, BlogListState>(
                    builder: (context, state) {
                      if (state is BlogListFailure) {
                        return SliverToBoxAdapter(
                          child: QErrorWidget(
                            error: state.error,
                            onRetry: () => context
                                .read<BlogListCubit>()
                                .getBlogs(tag: _lastFetchedTag?.value),
                          ),
                        );
                      }
                      if (state is BlogListSuccess) {
                        if (state.blogs.isEmpty) {
                          return SliverToBoxAdapter(
                            child: QErrorWidget.emptyData(),
                          );
                        }
                        final length =
                            state.blogs.length + (state.isPageLoading ? 1 : 0);

                        return SliverList.separated(
                          itemBuilder: (context, index) {
                            if (index == state.blogs.length) {
                              return Center(child: UiUtils.progress());
                            }
                            return BlogItem(blog: state.blogs[index]);
                          },
                          separatorBuilder: (_, _) => 10.vGap,
                          itemCount: length,
                        );
                      }
                      return const BlogListShimmer(isSliver: true);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
