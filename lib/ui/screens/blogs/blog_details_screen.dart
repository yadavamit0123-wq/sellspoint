import 'package:eClassify/data/cubits/blog/blog_details_cubit.dart';
import 'package:eClassify/data/cubits/blog/blog_feedback_cubit.dart';
import 'package:eClassify/data/model/blog/blog.dart';
import 'package:eClassify/ui/screens/blogs/widgets/blog_category_badge.dart';
import 'package:eClassify/ui/screens/blogs/widgets/blog_feedback_widget.dart';
import 'package:eClassify/ui/screens/blogs/widgets/blog_item.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/date_extensions.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/tap_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class BlogDetailsScreen extends StatelessWidget {
  BlogDetailsScreen({required this.blogId, super.key});

  final int blogId;

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => BlogDetailsCubit()),
          BlocProvider(create: (_) => BlogFeedbackCubit()),
        ],
        child: BlogDetailsScreen(blogId: routeSettings.arguments as int),
      ),
    );
  }

  final TapGuard _guard = TapGuard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('blogs'.translate(context)),
        actions: [
          IconButton(
            onPressed: () {
              final state = context.read<BlogDetailsCubit>().state;
              final blogSlug = switch (state) {
                BlogDetailsSuccess(blog: final blog) => blog.slug,
                _ => null,
              };

              if (blogSlug == null) return;

              _guard.run(() async {
                HelperUtils.shareItem(context, 'blogs', blogSlug);
              });
            },
            icon: Icon(AppIcons.shareNetwork),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: BlocBuilder<BlogDetailsCubit, BlogDetailsState>(
            builder: (context, state) {
              if (state is BlogDetailsInitial) {
                context.read<BlogDetailsCubit>().getBlogDetails(id: blogId);
              }
              if (state is BlogDetailsFailure) {
                return QErrorWidget(
                  error: state.error,
                  onRetry: () {
                    context.read<BlogDetailsCubit>().getBlogDetails(id: blogId);
                  },
                );
              }
              if (state is BlogDetailsSuccess) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 20,
                    children: [
                      _BlogDetails(blog: state.blog),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Constant.horizontalPadding,
                        ),
                        child: BlogFeedbackWidget(blog: state.blog),
                      ),
                      if (state.relatedBlogs.isNotNullAndNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Constant.horizontalPadding,
                          ),
                          child: Text(
                            'relatedBlogs'.translate(context),
                            style: context.titleMedium,
                          ),
                        ),
                        SizedBox(
                          height: 260,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(
                              horizontal: Constant.horizontalPadding,
                            ),
                            itemCount: state.relatedBlogs.length,
                            separatorBuilder: (_, __) => 10.hGap,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                width: 280,
                                child: BlogItem(
                                  blog: state.relatedBlogs[index],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: Constant.horizontalPadding,
                ),
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 2,
                      child: CustomShimmer(borderRadius: 8),
                    ),
                    CustomShimmer(height: 20, width: 300, borderRadius: 8),
                    ...List.generate(20, (index) {
                      return CustomShimmer(
                        height: 10,
                        width: double.maxFinite,
                        borderRadius: 8,
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BlogDetails extends StatelessWidget {
  const _BlogDetails({required this.blog});

  final Blog blog;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Constant.horizontalPadding),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.color.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: Constant.safeAreaMinimumPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 2,
                child: CustomImage(
                  src: blog.image,
                  fit: BoxFit.cover,
                  radius: 8,
                ),
              ),
              16.vGap,
              BlogCategoryBadge(name: blog.category.name.localized),
              8.vGap,
              Row(
                spacing: 5,
                children: [
                  Icon(AppIcons.eye, size: 16),
                  Text(
                    '${'view'.translate(context)} : ${blog.views}',
                    style: context.bodySmall,
                  ),
                  const SizedBox(height: 10, child: VerticalDivider()),
                  Icon(AppIcons.calendarDots, size: 16),
                  Text(
                    blog.createdAt.format(formatString: 'MMMM dd, yyyy'),
                    style: context.bodySmall,
                  ),
                ],
              ),
              8.vGap,
              Text(blog.title.localized, style: context.titleMedium.semiBold),
              12.vGap,
              HtmlWidget(blog.description.localized),
            ],
          ),
        ),
      ),
    );
  }
}
