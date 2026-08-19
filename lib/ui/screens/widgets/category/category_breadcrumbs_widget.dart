import 'package:eClassify/data/cubits/category/category_browsing_cubit.dart';
import 'package:eClassify/data/cubits/category/category_path_notifier.dart';
import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eClassify/utils/app_icons.dart';

/// Breadcrumb navigation widget for categories.
class CategoryBreadcrumbs extends StatelessWidget {
  const CategoryBreadcrumbs.static({
    required List<Category> this.path,
    required ValueChanged<Category?> this.onTap,
    super.key,
  }) : _isStatic = true,
       notifier = null;

  const CategoryBreadcrumbs.dynamic({
    required CategoryPathNotifier this.notifier,
    super.key,
  }) : _isStatic = false,
       path = null,
       onTap = null;

  final List<Category>? path;
  final ValueChanged<Category?>? onTap;
  final CategoryPathNotifier? notifier;
  final bool _isStatic;

  @override
  Widget build(BuildContext context) {
    if (_isStatic) {
      return _BreadcrumbsContent(path: path!, onTap: onTap!);
    }

    return ListenableBuilder(
      listenable: notifier!,
      builder: (context, child) {
        return _BreadcrumbsContent(
          path: notifier!.value,
          onTap: (category) {
            try {
              // Current way: Use the cubit for navigation and fetching
              context.read<CategoryBrowsingCubit>().navigateBackTo(category);
              // ignore: empty_catches
            } catch (e) {
              // Fallback: Just update the notifier if cubit is not in context
              notifier!.navigateTo(category);
            }
          },
        );
      },
    );
  }
}

class _BreadcrumbsContent extends StatelessWidget {
  const _BreadcrumbsContent({required this.path, required this.onTap});

  final List<Category> path;
  final ValueChanged<Category?> onTap;

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          IconButton(
            onPressed: () => onTap(null),
            icon: Icon(AppIcons.houseFill),
          ),
          ...path.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final isLast = index == path.length - 1;

            return Padding(
              padding: const EdgeInsetsDirectional.only(end: 5),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                  fixedSize: const Size.fromHeight(30),
                  iconSize: 20,
                  overlayColor: Colors.transparent,
                ),
                onPressed: isLast ? null : () => onTap(category),
                icon: Icon(
                  AppIcons.caretRight,
                  color: context.colorScheme.primary,
                  size: 20,
                ),
                label: Text(
                  category.name.localized,
                  style: context.labelLarge.copyWith(
                    color: isLast ? context.colorScheme.primary : null,
                    fontWeight: isLast ? FontWeight.bold : null,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
