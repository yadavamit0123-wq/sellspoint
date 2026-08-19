import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CustomTextFieldValidator {
  nullCheck,
  phoneNumber,
  email,
  password,
  maxFifty,
  otpSix,
  minAndMaxLen,
  url,
  slug,
}

@Deprecated('Use CustomTextField instead')
class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final int? minLine;
  final int? maxLine;
  final bool? isReadOnly;
  final List<TextInputFormatter>? formaters;
  final CustomTextFieldValidator? validator;
  final String? Function(String?)? validatorFunction;
  final Color? fillColor;
  final ValueChanged<String>? onChange;
  final Widget? prefix;
  final TextInputAction? action;
  final TextInputType? keyboard;
  final Widget? suffix;
  final bool? dense;
  final Color? borderColor;
  final Widget? fixedPrefix;
  final bool? obscureText;
  final int? maxLength;
  final int? minLength;
  final TextStyle? hintTextStyle;
  final TextCapitalization? capitalization;
  final bool? isRequired;
  final bool? isMobileRequired;
  final InputDecoration? decoration;

  const CustomTextFormField({
    super.key,
    this.hintText,
    this.controller,
    this.focusNode,
    this.minLine,
    this.maxLine,
    this.formaters,
    this.isReadOnly,
    this.validator,
    this.validatorFunction,
    this.fillColor,
    this.onChange,
    this.prefix,
    this.keyboard,
    this.action,
    this.suffix,
    this.dense,
    this.borderColor,
    this.fixedPrefix,
    this.obscureText,
    this.maxLength,
    this.hintTextStyle,
    this.minLength,
    this.capitalization,
    this.isRequired,
    this.isMobileRequired = true,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      autofocus: false,
      controller: controller,
      inputFormatters: formaters,
      obscureText: obscureText ?? false,
      textInputAction: action,
      onTapOutside: (PointerDownEvent event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      textCapitalization: capitalization ?? TextCapitalization.none,
      readOnly: isReadOnly ?? false,
      style: context.textTheme.titleMedium,
      minLines: minLine ?? 1,
      maxLines: maxLine ?? 1,
      onChanged: onChange,
      validator: (String? value) {
        if (validatorFunction != null) {
          return validatorFunction!(value);
        }
        if (validator == CustomTextFieldValidator.nullCheck) {
          return Validator.nullCheckValidator(value, context: context);
        }

        if (validator == CustomTextFieldValidator.maxFifty) {
          if ((value ??= "").length > 50) {
            return "youCanEnter50LettersMax".translate(context);
          } else {
            return null;
          }
        }

        // Check if maxLength is not null and value length exceeds maxLength
        if (validator == CustomTextFieldValidator.minAndMaxLen) {
          // Check if the value is empty
          if (isRequired == true && value == "") {
            return Validator.nullCheckValidator(value, context: context);
          }

          if (isRequired == true &&
              (maxLength != null && value!.length > maxLength!)) {
            return "${"youCanAdd".translate(context)} \t $maxLength \t ${"maximumNumbersOnly".translate(context)}";
          }

          // Check if minLength is not null and value length is less than minLength
          if (isRequired == true &&
              (minLength != null && value!.length < minLength!)) {
            return "$minLength \t ${"numMinRequired".translate(context)}";
          }
          return null;
        }

        if (validator == CustomTextFieldValidator.otpSix) {
          if ((value ??= "").length != 6) {
            return 'pleaseEnterSixDigits'.translate(context);
          }
          return null;
        }
        if (validator == CustomTextFieldValidator.email) {
          return Validator.validateEmail(email: value, context: context);
        }
        if (validator == CustomTextFieldValidator.slug) {
          return Validator.validateSlug(value, context: context);
        }
        if (validator == CustomTextFieldValidator.phoneNumber) {
          return Validator.validatePhoneNumber(
            value: value,
            context: context,
            isRequired: isMobileRequired!,
          );
        }
        if (validator == CustomTextFieldValidator.url) {
          return Validator.urlValidation(value: value, context: context);
        }
        if (validator == CustomTextFieldValidator.password) {
          return Validator.validatePassword(value, context: context);
        }
        return null;
      },
      keyboardType: keyboard,
      maxLength: maxLength,
      decoration:
          decoration ??
          InputDecoration(
            prefix: prefix,
            prefixIcon: fixedPrefix,
            suffixIcon: suffix,
            hintText: hintText,
            hintStyle: hintTextStyle,
            fillColor: fillColor,
          ),
    );
  }
}
