import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Replace the default primary color with the given color to dynamically change
/// the svg color.
class PrimaryColorMapper extends ColorMapper {
  PrimaryColorMapper(this.color);

  final Color color;

  // DO NOT CHANGE THIS COLOR
  static const _primaryColor = Color(0xff00b2ca);

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (color.toARGB32() == _primaryColor.toARGB32()) {
      return this.color;
    }
    return color;
  }
}
