import 'package:dio/dio.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

@Deprecated('Use ValidatorV2 along with CustomTextField instead')
class Validator {
  static String emailPattern =
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';

  static String? validateEmail({String? email, required BuildContext context}) {
    if ((email ??= "").trim().isEmpty) {
      return "pleaseEnterMail".translate(context);
    } else if (!RegExp(emailPattern).hasMatch(email)) {
      return "pleaseEnterValidEmailAddress".translate(context);
    } else {
      return null;
    }
  }

  static String? validatePhoneNumber({
    String? value,
    required BuildContext context,
    required bool isRequired,
  }) {
    final pattern = RegExp(r"^[0-9]{6,15}$");

    // If the field is required and the value is empty
    if (isRequired && (value ??= "").trim().isEmpty) {
      return "pleaseEnterValidPhoneNumber".translate(context);
    }

    // If the value is not empty, check the pattern
    if (value!.isNotEmpty && !pattern.hasMatch(value)) {
      return "pleaseEnterValidPhoneNumber".translate(context);
    }

    // No issues, return null
    return null;
  }

  static String? nullCheckValidator(
    String? value, {
    int? requiredLength,
    required BuildContext context,
  }) {
    if (value!.isEmpty) {
      return "fieldMustNotBeEmpty".translate(context);
    } else if (requiredLength != null) {
      if (value.length < requiredLength) {
        return "${"textMustBe".translate(context)} $requiredLength ${"characterLong".translate(context)}";
      } else {
        return null;
      }
    }

    return null;
  }

  static String? validateSlug(String? slug, {required BuildContext context}) {
    final RegExp slugRegExp = RegExp(
      r'^[a-z0-9]+(-[a-z0-9]+)*$',
      unicode: true,
    );

    // If slug is null or empty, return null (no validation needed)
    if (slug == null || slug.isEmpty) {
      return null; // Slug is optional, no validation
    }

    // If slug is not empty, validate it against the pattern
    if (!slugRegExp.hasMatch(slug)) {
      return "slugWarning".translate(context); // Customize the warning message
    }

    return null; // Slug is valid
  }

  static String? validatePassword(
    String? password, {
    String? secondFieldValue,
    required BuildContext context,
  }) {
    if (password!.isEmpty) {
      return "passwordCanNotBeEmpty".translate(context);
    } else if (password.length < 6) {
      return "passwordWarning".translate(context);
    }
    if (secondFieldValue != null) {
      if (password != secondFieldValue) {
        return "fieldSameWarning".translate(context);
      }
    }

    return null;
  }

  static String? urlValidation({String? value, required BuildContext context}) {
    if (value!.isNotEmpty) {
      validUrl(value).then((result) {
        if (result == false) {
          return 'plzValidUrlLbl'.translate(context);
        } else {
          return result;
        }
      });
    } else {
      return null;
    }
    return null;
  }

  static Future<bool> validUrl(String value) async {
    try {
      Response response = await Dio().head(value);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

class CustomValidator<T> extends FormField<T> {
  CustomValidator({
    super.key,
    required FormFieldValidator<T> super.validator,
    required Widget Function(FormFieldState<T> state) builder,
    super.initialValue,
    bool autovalidate = false,
  }) : super(
         builder: (FormFieldState<T> state) {
           return builder(state);
         },
       );
}
