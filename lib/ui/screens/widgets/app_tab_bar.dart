import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:flutter/material.dart';

class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTabBar({
    required this.controller,
    required this.tabs,
    this.onChanged,
    this.height,
    this.decoration,
    this.padding,
    this.tabPadding,
    this.innerTabPadding,
    this.tabBorderRadius,
    this.selectedTabColor,
    this.unselectedTabColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.selectedBorderColor,
    this.unselectedBorderColor,
    this.isScrollable = true,
    this.tabAlignment = TabAlignment.start,
    this.applyDesignStyle = true,
    super.key,
  });

  final TabController controller;
  final List<String> tabs;
  final ValueChanged<int>? onChanged;
  final double? height;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? tabPadding;
  final EdgeInsetsGeometry? innerTabPadding;
  final BorderRadius? tabBorderRadius;
  final Color? selectedTabColor;
  final Color? unselectedTabColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final Color? selectedBorderColor;
  final Color? unselectedBorderColor;
  final bool isScrollable;
  final TabAlignment tabAlignment;
  final bool applyDesignStyle;

  @override
  Widget build(BuildContext context) {
    var child = TabBar(
      controller: controller,
      isScrollable: isScrollable,
      tabAlignment: tabAlignment,
      splashFactory: NoSplash.splashFactory,
      padding: padding,
      labelPadding: tabPadding ?? const EdgeInsets.symmetric(horizontal: 4),
      indicatorColor: Colors.transparent,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      onTap: onChanged,
      tabs: tabs.indexed
          .map(
            (tab) => ListenableBuilder(
              listenable: controller.animation!,
              builder: (context, child) {
                final index = tab.$1;
                final animationValue = controller.animation!.value;
                double progress = 0.0;

                if (controller.indexIsChanging) {
                  final int targetIndex = controller.index;
                  final int prevIndex = controller.previousIndex;
                  if (targetIndex != prevIndex) {
                    final double fraction =
                        (animationValue - prevIndex).abs() /
                        (targetIndex - prevIndex).abs();
                    if (index == targetIndex) {
                      progress = fraction.clamp(0.0, 1.0);
                    } else if (index == prevIndex) {
                      progress = (1.0 - fraction).clamp(0.0, 1.0);
                    } else {
                      progress = 0.0;
                    }
                  } else {
                    progress = (index == targetIndex) ? 1.0 : 0.0;
                  }
                } else {
                  progress = (1.0 - (animationValue - index).abs()).clamp(
                    0.0,
                    1.0,
                  );
                }

                return _CustomAppTab(
                  label: tab.$2,
                  progress: progress,
                  innerPadding: innerTabPadding,
                  borderRadius: tabBorderRadius,
                  selectedTabColor: selectedTabColor,
                  unselectedTabColor: unselectedTabColor,
                  selectedTextColor: selectedTextColor,
                  unselectedTextColor: unselectedTextColor,
                  selectedBorderColor: selectedBorderColor,
                  unselectedBorderColor: unselectedBorderColor,
                );
              },
            ),
          )
          .toList(),
    );

    if (applyDesignStyle) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: height ?? kToolbarHeight * 1.5,
          minWidth: double.infinity,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: context.theme.dividerColor)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: Constant.horizontalPadding,
            ),
            child: child,
          ),
        ),
      );
    }
    return child;
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? (kToolbarHeight * 1.5));
}

class _CustomAppTab extends StatelessWidget {
  const _CustomAppTab({
    required this.label,
    required this.progress,
    this.innerPadding,
    this.borderRadius,
    this.selectedTabColor,
    this.unselectedTabColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.selectedBorderColor,
    this.unselectedBorderColor,
  });

  final String label;
  final double progress;
  final EdgeInsetsGeometry? innerPadding;
  final BorderRadius? borderRadius;
  final Color? selectedTabColor;
  final Color? unselectedTabColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final Color? selectedBorderColor;
  final Color? unselectedBorderColor;

  @override
  Widget build(BuildContext context) {
    final Color? backgroundColor = Color.lerp(
      unselectedTabColor ?? Colors.transparent,
      selectedTabColor ?? context.colorScheme.primary,
      progress,
    );

    final Border border = Border.all(
      color:
          Color.lerp(
            unselectedBorderColor ?? context.colorScheme.outline,
            selectedBorderColor ?? Colors.transparent,
            progress,
          ) ??
          unselectedBorderColor ??
          context.colorScheme.outline,
    );

    final Color? textColor = Color.lerp(
      unselectedTextColor ?? context.colorScheme.onSurface,
      selectedTextColor ?? context.colorScheme.onPrimary,
      progress,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 80),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          border: border,
        ),
        child: Padding(
          padding:
              innerPadding ??
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Center(
            child: Text(
              label.translate(context),
              style: context.bodyMedium.withColor(
                textColor ?? context.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
