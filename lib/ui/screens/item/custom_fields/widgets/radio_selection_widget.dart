import 'package:eClassify/data/model/item/custom_field_v2.dart';
import 'package:eClassify/ui/screens/item/custom_fields/custom_fields_controller.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class RadioSelectionWidget extends StatefulWidget {
  const RadioSelectionWidget({required this.field, super.key});

  final RadioField field;

  @override
  State<RadioSelectionWidget> createState() => _RadioSelectionWidgetState();
}

class _RadioSelectionWidgetState extends State<RadioSelectionWidget> {
  String? _selected;

  CustomFieldsController? _controller;

  @override
  Widget build(BuildContext context) {
    _controller ??= CustomFieldsControllerProvider.maybeOf(context)?.controller;
    _selected = _controller?.data[widget.field.id]?.value as String?;
    return Wrap(
      spacing: 6,
      children: List.generate(widget.field.values.length, (index) {
        final value = widget.field.values[index];
        final selected = _selected == value.canonical;
        return ChoiceChip(
          onSelected: (isSelected) {
            _selected = isSelected ? value.canonical : null;
            setState(() {});
            _controller?.updateValue(widget.field.id, _selected);
          },
          pressElevation: 0,
          showCheckmark: false,
          backgroundColor: context.colorScheme.secondary,
          selectedColor: context.colorScheme.primary.withValues(alpha: .05),
          chipAnimationStyle: ChipAnimationStyle(
            selectAnimation: AnimationStyle.noAnimation,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: selected
                  ? context.colorScheme.primary
                  : context.theme.dividerColor,
            ),
          ),
          label: Text(value.localized),
          labelStyle: context.bodyLarge.withColor(
            selected
                ? context.colorScheme.primary
                : context.colorScheme.onSurface,
          ),
          selected: selected,
        );
      }),
    );
  }
}
