import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/item/item_filter.dart';
import 'package:eClassify/data/model/item/item_list.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:eClassify/utils/app_icons.dart';

class ItemListBottomBar extends StatelessWidget {
  const ItemListBottomBar({
    required this.metadata,
    required this.onSortChanged,
    required this.onFilterChanged,
    super.key,
  });

  final ItemMetaData metadata;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<ItemFilter?> onFilterChanged;

  void _showSortByBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: context.color.secondaryColor,
      builder: (context) {
        return Padding(
          padding: MediaQuery.paddingOf(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: Sort.values
                .map(
                  (sort) => ListTile(
                    onTap: () {
                      onSortChanged(sort.value);
                      Navigator.of(context).pop();
                    },
                    title: Text(sort.label.translate(context)),
                    trailing: metadata.sortBy == sort.value
                        ? Icon(
                            AppIcons.check,
                            color: context.color.territoryColor,
                          )
                        : null,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double bottomNavHeight = kBottomNavigationBarHeight;
    bottomNavHeight += MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: bottomNavHeight,
      child: ColoredBox(
        color: context.color.secondaryColor,
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    overlayColor: Colors.transparent,
                    foregroundColor: context.color.textDefaultColor,
                  ),
                  onPressed: () async {
                    final filter =
                        await Navigator.of(context).pushNamed(
                              Routes.filterScreen,
                              arguments: {
                                'filter': metadata.filter,
                                'show_category_filter':
                                    metadata is! CategoryMetaData,
                              },
                            )
                            as ItemFilter?;
                    onFilterChanged(filter);
                  },
                  icon: Icon(AppIcons.sliders),
                  label: Text('filterTitle'.translate(context)),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    overlayColor: Colors.transparent,
                    foregroundColor: context.color.textDefaultColor,
                  ),
                  onPressed: () => _showSortByBottomSheet(context),
                  icon: Icon(AppIcons.funnelSimple),
                  label: Text('sortBy'.translate(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
