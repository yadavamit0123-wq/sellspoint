import 'package:eClassify/data/model/custom_field/custom_field_value.dart';
import 'package:eClassify/data/model/custom_field/file_resource.dart';
import 'package:eClassify/data/model/item/custom_field_v2.dart';
import 'package:eClassify/utils/collection_notifiers.dart';
import 'package:eClassify/utils/validator_v2.dart';
import 'package:flutter/material.dart';

class CustomFieldsController {
  final MapNotifier<int, String> _errors = MapNotifier();

  MapNotifier<int, String> get errorNotifier => _errors;

  final Map<int, CustomFieldValue> _values = Map();

  Map<int, CustomFieldValue> get data => _values;

  void registerFields(
    List<CustomFieldV2> fields, [
    Map<String, dynamic>? initialValues,
    bool assignValidators = true,
  ]) {
    for (final field in fields) {
      final validators = assignValidators
          ? [
              if (field.isRequired) EmptyFieldValidator(),
              if (field case final TextboxField field)
                TextLengthValidator(min: field.minLength, max: field.maxLength),
            ]
          : <ValidatorV2>[];
      _values[field.id] = CustomFieldValue(
        field: field,
        value: initialValues?[field.id.toString()],
        validators: validators,
      );
    }
  }

  void updateValue(int id, dynamic value) {
    _values[id] = _values[id]!.updateValue(value: value);
  }

  bool validate() {
    bool isValid = true;
    for (final value in _values.values) {
      _errors.remove(value.field.id);
      isValid &= _validateField(value);
    }
    return isValid;
  }

  bool _validateField(CustomFieldValue value) {
    for (final validator in value.validators) {
      final stringValue = switch (value.value) {
        final String s => s,
        final List l => l.join(','),
        final FileResource r => r.filePath,
        _ => null,
      };
      if (!validator.validate(stringValue)) {
        _errors.put(value.field.id, validator.errorText);
        return false;
      }
    }
    return true;
  }

  void clear() {
    _values.clear();
    _errors.clear();
  }
}

///A provider class to inject the [CustomFieldsController] instance
///to all the field widgets inside the [DynamicForm] widget so that all the field widgets
///can update their values when user interacts with it.

class CustomFieldsControllerProvider extends InheritedWidget {
  const CustomFieldsControllerProvider({
    required this.controller,
    this.isDefaultLanguage = true,
    required super.child,
    super.key,
  });

  final CustomFieldsController controller;
  final bool isDefaultLanguage;

  static CustomFieldsControllerProvider? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CustomFieldsControllerProvider>();
  }

  @override
  bool updateShouldNotify(covariant CustomFieldsControllerProvider oldWidget) =>
      oldWidget.controller != controller ||
      oldWidget.isDefaultLanguage != isDefaultLanguage;
}
