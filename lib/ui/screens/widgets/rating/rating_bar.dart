import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:eClassify/utils/app_icons.dart';

class RatingBar extends StatefulWidget {
  const RatingBar({
    this.initialRating,
    int count = 5,
    this.defaultIconSize = 24.0,
    this.unselectedIcon,
    this.selectedIcon,
    this.onChanged,
    super.key,
  }) : _length = count;
  final num? initialRating;
  final double defaultIconSize;
  final Icon? unselectedIcon;
  final Icon? selectedIcon;
  final ValueChanged<int>? onChanged;

  final int _length;

  @override
  State<RatingBar> createState() => _RatingBarState();
}

class _RatingBarState extends State<RatingBar>
    with SingleTickerProviderStateMixin {
  late num currentRating = widget.initialRating == null
      ? -1
      : widget.initialRating! - 1;

  late final AnimationController? _controller;

  late final TweenSequence<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.onChanged != null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );

      _scaleAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1, end: .8), weight: 40),
        TweenSequenceItem(tween: Tween(begin: .8, end: 1), weight: 60),
      ]);
    } else {
      _controller = null;
      _scaleAnimation = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RatingBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    currentRating = widget.initialRating == null
        ? -1
        : widget.initialRating! - 1;
  }

  Icon _resolveIcon(int index) {
    final isDouble = currentRating % 1 != 0;
    final effectiveRating = currentRating.toInt();
    if (index <= effectiveRating) {
      return widget.selectedIcon ??
          Icon(
            AppIcons.starFill,
            color: Colors.amber,
            size: widget.defaultIconSize,
          );
    } else if (isDouble && index == effectiveRating + 1) {
      return Icon(
        AppIcons.starHalfFill,
        color: Colors.amber,
        size: widget.defaultIconSize,
      );
    } else {
      return widget.unselectedIcon ??
          Icon(
            AppIcons.starFill,
            color: context.colorScheme.surfaceContainerHighest,
            size: widget.defaultIconSize,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget._length, (index) {
        final isSelected = index <= currentRating;
        final icon = _resolveIcon(index);

        if (widget.onChanged == null) {
          return _Star(icon: icon, size: widget.defaultIconSize);
        } else {
          return AnimatedBuilder(
            animation: _controller!,
            builder: (context, child) {
              return ScaleTransition(
                scale: isSelected
                    ? _scaleAnimation!.animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Curves.bounceOut,
                        ),
                      )
                    : const AlwaysStoppedAnimation(1),
                child: _Star(
                  icon: icon,
                  size: widget.defaultIconSize,
                  onPressed: () {
                    if (currentRating == index) return;
                    widget.onChanged!(index + 1);
                    setState(() {
                      currentRating = index;
                    });
                    _controller.forward(from: 0);
                  },
                ),
              );
            },
          );
        }
      }),
    );
  }
}

class _Star extends StatelessWidget {
  const _Star({required this.icon, required this.size, this.onPressed});

  final Icon icon;
  final double size;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        overlayColor: icon.color,
        iconSize: size,
        minimumSize: Size.square(size),
      ),
      onPressed: onPressed,
      icon: icon,
    );
  }
}
