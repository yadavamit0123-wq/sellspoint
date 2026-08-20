import 'package:eClassify/ui/screens/profile_tab_screen/models/menu_section.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/menu_item_widget.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:flutter/material.dart';

class MenuSectionWidget extends StatelessWidget {
  const MenuSectionWidget({required this.section, super.key});

  final MenuSection section;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: section.items.length,
          padding: EdgeInsets.all(12),
          separatorBuilder: (context, index) => Divider(height: 12),
          itemBuilder: (context, index) {
            final item = section.items[index];
            return MenuItemWidget(item: item);
          },
        ),
      ),
    );
  }
}
