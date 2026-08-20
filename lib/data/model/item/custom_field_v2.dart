import 'package:eClassify/data/model/localized_string.dart';
import 'package:eClassify/utils/json_helper.dart';
import 'package:flutter/foundation.dart';

@immutable
base class CustomFieldV2 {
  factory CustomFieldV2.parse(Json json) {
    final type = json['type'] as String;
    return switch (type) {
      'radio' => RadioField.fromJson(json),
      'textbox' => TextInputField.fromJson(json),
      'number' => NumberInputField.fromJson(json),
      'checkbox' => CheckboxField.fromJson(json),
      'dropdown' => DropdownField.fromJson(json),
      'fileinput' => FileInputField.fromJson(json),
      _ => throw UnimplementedError('Unknown custom field type: $type'),
    };
  }

  CustomFieldV2._fromJson(Json json)
    : id = json['id'] as int,
      name = LocalizedString(
        canonical: json['name'] as String,
        translated: json['translated_name'] as String?,
      ),
      image = json['image'] as String,
      isRequired = (json['required'] as int?) == 1;

  final int id;
  final LocalizedString name;
  final String image;
  final bool isRequired;

  @override
  bool operator ==(Object other) => other is CustomFieldV2 && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

base class TextboxField extends CustomFieldV2 {
  TextboxField.fromJson(super.json)
    : minLength = json['min_length'] as int?,
      maxLength = json['max_length'] as int?,
      super._fromJson();

  final int? minLength;
  final int? maxLength;
}

final class TextInputField extends TextboxField {
  TextInputField.fromJson(super.json) : super.fromJson();
}

final class NumberInputField extends TextboxField {
  NumberInputField.fromJson(super.json) : super.fromJson();
}

base class SelectionField extends CustomFieldV2 {
  SelectionField.fromJson(super.json)
    : values = _getValues(json['values'], json['translated_value']),
      super._fromJson();

  final List<LocalizedString> values;

  static List<LocalizedString> _getValues(
    List<dynamic> values,
    List<dynamic> translatedValues,
  ) {
    assert(
      values.length == translatedValues.length,
      'Values and translated values must be of the same length',
    );
    final List<LocalizedString> localizedValues = [];
    values = values.cast<String>();
    translatedValues = translatedValues.cast<String>();
    for (int i = 0; i < values.length; i++) {
      localizedValues.add(
        LocalizedString(canonical: values[i], translated: translatedValues[i]),
      );
    }
    return localizedValues;
  }
}

final class CheckboxField extends SelectionField {
  CheckboxField.fromJson(super.json) : super.fromJson();
}

final class RadioField extends SelectionField {
  RadioField.fromJson(super.json) : super.fromJson();
}

final class DropdownField extends SelectionField {
  DropdownField.fromJson(super.json) : super.fromJson();
}

final class FileInputField extends CustomFieldV2 {
  FileInputField.fromJson(super.json) : super._fromJson();
}
