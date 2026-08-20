import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/blog/blog.dart';
import 'package:eClassify/ui/screens/blogs/widgets/blog_category_badge.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';

class BlogItem extends StatelessWidget {
  const BlogItem({required this.blog, super.key});

  final Blog blog;

  @override
  Widget build(BuildContext context) {
    final document = parse(blog.description.localized);
    final description = document.body?.text;
    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).pushNamed(Routes.blogDetailsScreen, arguments: blog.id),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.color.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              12.vGap,
              BlogCategoryBadge(name: blog.category.name.localized),
              8.vGap,
              Text(
                blog.title.localized,
                style: context.titleMedium,
                maxLines: 1,
              ),
              if (description != null)
                Flexible(
                  child: Text(
                    description,
                    style: context.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
