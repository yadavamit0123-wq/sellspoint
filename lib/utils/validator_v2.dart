import 'package:eClassify/utils/extensions/lib/extensions.dart';

///Base class for Custom Validation rules
abstract class ValidatorV2<T> {
  ValidatorV2({required this.errorText});

  final String errorText;

  bool validate(T value);
}

class EmptyFieldValidator extends ValidatorV2<String?> {
  EmptyFieldValidator({super.errorText = 'fieldMustNotBeEmpty'});

  @override
  bool validate(String? value) {
    return value.isNotNullAndNotEmpty;
  }
}

class AdSlugValidator extends ValidatorV2<String?> {
  AdSlugValidator({super.errorText = 'invalidSlug'});

  final slugRegex = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

  @override
  bool validate(String? value) {
    if (value.isNullOrEmpty) return true;
    return slugRegex.hasMatch(value!);
  }
}

enum ComparisonOperator {
  lessThan,
  lessThanOrEqualTo,
  greaterThan,
  greaterThanOrEqualTo,
}

class NumericComparisonValidator extends ValidatorV2<String?> {
  NumericComparisonValidator({
    required this.getCompareValue,
    required this.operator,
    required super.errorText,
  });

  final String Function() getCompareValue;
  final ComparisonOperator operator;

  @override
  bool validate(String? value) {
    if (value.isNullOrEmpty) return true;
    final val = double.tryParse(value!);
    final compareVal = double.tryParse(getCompareValue());

    // Let EmptyFieldValidator handle empty states; don't fail comparison on nulls
    if (val == null || compareVal == null) return true;

    switch (operator) {
      case ComparisonOperator.lessThan:
        return val < compareVal;
      case ComparisonOperator.lessThanOrEqualTo:
        return val <= compareVal;
      case ComparisonOperator.greaterThan:
        return val > compareVal;
      case ComparisonOperator.greaterThanOrEqualTo:
        return val >= compareVal;
    }
  }
}

class TextLengthValidator extends ValidatorV2<String?> {
  TextLengthValidator({
    required this.min,
    required this.max,
    super.errorText = 'invalidLength',
  });

  final int? min;
  final int? max;

  @override
  bool validate(String? value) {
    if (value.isNullOrEmpty) return true;
    if (min != null && value!.length < min!) return false;
    if (max != null && value!.length > max!) return false;
    return true;
  }
}

class CallbackValidator<T> extends ValidatorV2<T> {
  CallbackValidator({
    super.errorText = 'fieldMustNotBeEmpty',
    required this.predicate,
  });

  final bool Function(T value) predicate;

  @override
  bool validate(T value) => predicate(value);
}
