import 'dart:math';

import 'package:eClassify/data/model/subscription/subscription_package.dart';
import 'package:eClassify/ui/screens/subscription/widgets/active_package_widget.dart';
import 'package:eClassify/ui/screens/subscription/widgets/features_animated_list.dart';
import 'package:eClassify/ui/screens/subscription/widgets/inactive_package_widget.dart';
import 'package:eClassify/ui/screens/subscription/widgets/label_border.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/screens/widgets/hexagon_shape_border.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PackageWidget extends StatefulWidget {
  const PackageWidget({
    required this.package,
    required this.activePlanCapLabel,
    this.isSelected = false,
    super.key,
  });

  final SubscriptionPackage package;
  final bool isSelected;
  final String activePlanCapLabel;

  @override
  State<PackageWidget> createState() => _PackageWidgetState();
}

class _PackageWidgetState extends State<PackageWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  Widget _buildCardFrame({required Widget child}) {
    return Padding(
      padding: widget.package.isActive
          ? const EdgeInsets.only(top: 20)
          : EdgeInsets.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.package.isPurchasable || widget.package.isActive
              ? context.colorScheme.secondary
              : context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: switch ((widget.package.isActive, widget.isSelected)) {
            (true, _) => LabeledBorder(
              label: widget.activePlanCapLabel,
              textStyle: context.labelMedium.copyWith(
                color: context.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
              color: context.colorScheme.primary,
            ),
            (false, true) => Border.all(color: context.colorScheme.primary),
            (_, _) => null,
          },
        ),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }

  Widget _buildFrontCard(BuildContext context) {
    return _buildCardFrame(
      child: Column(
        spacing: 10,
        children: [
          Row(
            spacing: 10,
            children: [
              DecoratedBox(
                decoration: ShapeDecoration(
                  color: context.colorScheme.outline,
                  shape: HexagonBorderShape(cornerRadius: 5),
                ),
                child: SizedBox.square(
                  dimension: 45,
                  child: Center(
                    child: CustomImage(
                      src: widget.package.icon,
                      size: Size.square(20),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      widget.package.name.localized,
                      maxLines: 3,
                      style: context.titleMedium.bold,
                    ),
                    if (widget.package.isVideoAdAllowed)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: context.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 4,
                            children: [
                              Icon(AppIcons.playCircle, size: 16),
                              Flexible(
                                child: Text(
                                  'videoAdSupported'.translate(context),
                                  style: context.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!widget.package.isActive)
                Radio<SubscriptionPackage>(value: widget.package),
            ],
          ),
          if (widget.package.isActive)
            ActivePackageWidget(package: widget.package.activePackages.first)
          else ...[
            const Divider(),
            InactivePackageWidget(package: widget.package),
          ],
          if (widget.package.keyPoints.isNotEmpty) ...[
            const Divider(),
            FeaturesAnimatedList(
              points: widget.package.keyPoints,
              title: 'featuresList'.translate(context),
            ),
          ],
          if (widget.package.categories.isNotEmpty)
            _buildCategoriesPreview(context),
        ],
      ),
    );
  }

  Widget _buildCategoriesPreview(BuildContext context) {
    final totalCategories = widget.package.categories.length;
    final totalCategoriesToShow = min(3, totalCategories);
    final hasMore = totalCategories > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Text(
          'categoriesIncluded'.translate(context),
          style: context.labelMedium.withColor(context.mutedColor),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(totalCategoriesToShow, (index) {
            return RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      AppIcons.checkCircleFill,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
                  const TextSpan(text: '\t\t'),
                  TextSpan(
                    text: widget.package.categories[index],
                    style: context.labelLarge,
                  ),
                  if (index == totalCategoriesToShow - 1 && hasMore) ...[
                    const TextSpan(text: '\t'),
                    TextSpan(
                      text: 'viewMore'.translate(context),
                      style: context.labelLarge.copyWith(
                        color: context.colorScheme.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: context.colorScheme.primary,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = _toggleFlip,
                    ),
                  ],
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBackCard(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFlip,
      behavior: HitTestBehavior.opaque,
      child: _buildCardFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'categoriesIncluded'.translate(context),
              style: context.labelMedium.withColor(context.mutedColor),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Scrollbar(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: widget.package.categories.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Icon(
                                AppIcons.checkCircleFill,
                                color: Colors.green,
                                size: 16,
                              ),
                            ),
                            const TextSpan(text: '\t\t'),
                            TextSpan(
                              text: widget.package.categories[index],
                              style: context.labelLarge,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Stack(
        children: [
          IgnorePointer(
            ignoring: _isFlipped,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final angle = _animation.value;
                final isFront = angle < pi / 2;
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  alignment: Alignment.center,
                  child: Visibility(
                    visible: isFront,
                    maintainState: true,
                    maintainAnimation: true,
                    maintainSize: true,
                    child: _buildFrontCard(context),
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_isFlipped,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final angle = _animation.value;
                  final isBack = angle >= pi / 2;
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    alignment: Alignment.center,
                    child: Visibility(
                      visible: isBack,
                      maintainState: true,
                      child: Transform(
                        transform: Matrix4.identity()..rotateY(pi),
                        alignment: Alignment.center,
                        child: _buildBackCard(context),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
