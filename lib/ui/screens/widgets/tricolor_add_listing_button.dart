import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

enum TricolorAddListingLayout { standard, statusStrip }

/// Sells Point tricolor-ring add listing button (home header + FAB).
class TricolorAddListingButton extends StatelessWidget {
  const TricolorAddListingButton({
    required this.onTap,
    this.size = 52,
    this.iconSize = 28,
    this.showLabel = true,
    this.layout = TricolorAddListingLayout.standard,
    super.key,
  });

  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final bool showLabel;
  final TricolorAddListingLayout layout;

  static const _plusBlue = Color(0xFF0D47A1);
  static const _saffron = Color(0xFFFF9933);
  static const _green = Color(0xFF138808);

  double get _ringSize => layout == TricolorAddListingLayout.statusStrip ? 60 : size;

  double get _iconSize =>
      layout == TricolorAddListingLayout.statusStrip ? 26 : iconSize;

  @override
  Widget build(BuildContext context) {
    final ring = Container(
      width: _ringSize,
      height: _ringSize,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [_saffron, Colors.white, _green, _saffron],
          stops: [0.0, 0.33, 0.66, 1.0],
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Icon(Icons.add, color: _plusBlue, size: _iconSize),
      ),
    );

    final label = showLabel
        ? SizedBox(
            width: layout == TricolorAddListingLayout.statusStrip ? 70 : null,
            child: Center(
              child: Text(
                'adListing'.translate(context),
                style: layout == TricolorAddListingLayout.statusStrip
                    ? const TextStyle(fontWeight: FontWeight.bold)
                    : Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          )
        : null;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (layout == TricolorAddListingLayout.statusStrip)
          SizedBox(
            width: _ringSize + 7,
            height: _ringSize + 6.5,
            child: Center(child: ring),
          )
        else
          ring,
        if (label != null) ...[
          if (layout == TricolorAddListingLayout.standard)
            const SizedBox(height: 2),
          label,
        ],
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: layout == TricolorAddListingLayout.statusStrip
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: content,
            )
          : content,
    );
  }
}
