import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class FilterField extends StatelessWidget {
  const FilterField({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: context.labelLarge),
        ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: context.mutedColor.withValues(alpha: .2)),
          ),
          leading: Icon(icon, size: 24),
          title: Text(value, style: context.labelLarge,),
        ),
      ],
    );
  }
}
