import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Apply color to the full svg image
class SvgColorMapper extends ColorMapper {
  SvgColorMapper({this.color});

  final Color? color;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    return this.color ?? ThemeColors.primaryColor;
  }
}
