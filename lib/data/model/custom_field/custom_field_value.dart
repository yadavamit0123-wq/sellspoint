import 'package:eClassify/data/model/item/custom_field_v2.dart';
import 'package:eClassify/utils/validator_v2.dart';

class CustomFieldValue {
  CustomFieldValue({
    required this.field,
    required this.value,
    required this.validators,
  });

  final CustomFieldV2 field;
  final dynamic value;
  final List<ValidatorV2> validators;

  CustomFieldValue updateValue({required dynamic value}) =>
      CustomFieldValue(field: field, value: value, validators: validators);

  @override
  String toString() {
    return 'CustomFieldValue{field: $field, value: $value, validators: $validators}';
  }
}
