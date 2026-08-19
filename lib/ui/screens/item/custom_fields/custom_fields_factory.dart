import 'package:eClassify/data/model/item/custom_field_v2.dart';
import 'package:eClassify/ui/screens/item/custom_fields/widgets/checkbox_selection_widget.dart';
import 'package:eClassify/ui/screens/item/custom_fields/widgets/custom_field_skeleton.dart';
import 'package:eClassify/ui/screens/item/custom_fields/widgets/dropdown_selection_widget.dart';
import 'package:eClassify/ui/screens/item/custom_fields/widgets/file_input_widget.dart';
import 'package:eClassify/ui/screens/item/custom_fields/widgets/radio_selection_widget.dart';
import 'package:eClassify/ui/screens/item/custom_fields/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';

class CustomFieldsWidgetFactory {
  static Widget createField(CustomFieldV2 field) {
    final child = switch (field) {
      final RadioField field => RadioSelectionWidget(field: field),
      final TextInputField field => TextFieldWidget(field: field),
      final NumberInputField field => TextFieldWidget(field: field),
      final CheckboxField field => CheckboxSelectionWidget(field: field),
      final DropdownField field => DropdownSelectionWidget(field: field),
      final FileInputField field => FileInputWidget(field: field),
      _ => throw UnimplementedError('Unknown custom field type: $field'),
    };

    return CustomFieldSkeleton(field: field, child: child);
  }
}
