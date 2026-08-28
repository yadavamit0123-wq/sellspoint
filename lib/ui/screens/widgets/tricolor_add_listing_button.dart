import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

/// Sells Point tricolor-ring add listing button (home header + FAB).
class TricolorAddListingButton extends StatelessWidget {
  const TricolorAddListingButton({
    required this.onTap,
    this.size = 52,
    this.iconSize = 28,
    this.showLabel = true,
    super.key,
  });

  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final bool showLabel;

  static const _plusBlue = Color(0xFF0D47A1);
  static const _saffron = Color(0xFFFF9933);
  static const _green = Color(0xFF138808);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
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
              child: Icon(Icons.add, color: _plusBlue, size: iconSize),
            ),
          ),
          if (showLabel) ...[
            const SizedBox(height: 2),
            Text(
              'adListing'.translate(context),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
