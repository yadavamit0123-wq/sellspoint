import 'package:country_picker/country_picker.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/ui/screens/widgets/custom_text_field.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/log.dart';
import 'package:eClassify/utils/validator_v2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';

class PhoneInput extends StatefulWidget {
  const PhoneInput({
    required this.controller,
    this.focusNode,
    this.readOnly = false,
    this.required = true,
    this.hintKey,
    super.key,
  });

  final PhoneInputController controller;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool required;
  final String? hintKey;

  @override
  State<PhoneInput> createState() => _PhoneInputState();
}

class _PhoneInputState extends State<PhoneInput> {
  String _phoneCode = AppConfig.defaultPhoneCode;
  late CountryWithPhoneCode _country;
  final _countries = CountryManager().countries;

  late String _countryFlag;

  @override
  void initState() {
    super.initState();
    setCountry(widget.controller.regionCode);
    _phoneCode = _country.phoneCode;
    _countryFlag =
        CountryService().findByCode(_country.countryCode)?.flagEmoji ?? '';
    final formatted = formatNumberSync(
      widget.controller.phoneNumber,
      country: _country,
      inputContainsCountryCode: false,
    );
    widget.controller.text = formatted;

    // Perform initial validation on the existing number
    if (widget.controller.text.isNotEmpty) {
      widget.controller.validateAsync();
    }
  }

  void setCountry(String countryCode) {
    Log.info('$countryCode');
    _country = _countries.firstWhere(
      (element) =>
          element.countryCode.toLowerCase() == countryCode.toLowerCase(),
      orElse: () => CountryWithPhoneCode.us(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: CustomTextField(
        focusNode: widget.focusNode,
        controller: widget.controller,
        textInputType: TextInputType.number,
        readOnly: widget.readOnly,
        hintKey:
            widget.hintKey ??
            _country.exampleNumberMobileInternational.substring(
              _country.phoneCode.length + 1,
            ),
        onChanged: (value) {
          // Invalidate previous validation status when the user modifies input
          // to prevent form submission with a stale validation state.
          widget.controller._isValidPhone = false;
        },
        validators: [
          if (widget.required) EmptyFieldValidator(),
          // Custom validator checking the cached async state on the controller.
          // This allows synchronous check execution at form-submission time.
          CallbackValidator(
            predicate: (value) {
              if (value == null || value.isEmpty)
                return true; // Let EmptyFieldValidator handle empty states
              return widget.controller._isValidPhone;
            },
            errorText: 'pleaseEnterValidPhoneNumber',
          ),
        ],
        formatters: [
          LibPhonenumberTextFormatter(
            country: _country,
            shouldKeepCursorAtEndOfInput: false,
          ),
        ],
        prefixIcon: GestureDetector(
          onTap: () {
            if (widget.readOnly) return;
            showCountryPicker(
              context: context,
              showPhoneCode: true,
              countryListTheme: CountryListThemeData(
                bottomSheetHeight: MediaQuery.sizeOf(context).height * .9,
              ),
              onSelect: (country) {
                setState(() {
                  _phoneCode = country.phoneCode;
                  _countryFlag = country.flagEmoji;
                  setCountry(country.countryCode);
                });
                widget.controller.clear();
                widget.controller.phoneCode = country.phoneCode;
                widget.controller.regionCode = country.countryCode;
              },
            );
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 100, minWidth: 50),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                16.hGap,
                Text(_countryFlag, style: context.titleMedium, maxLines: 1),
                Text(
                  '${_phoneCode.startsWith('+') ? _phoneCode : '+$_phoneCode'}',
                  style: context.titleSmall.bold,
                  maxLines: 1,
                ),
                5.hGap,
                SizedBox(height: 15, child: VerticalDivider(width: 10)),
              ],
            ),
          ),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}

class PhoneInputController extends TextController {
  PhoneInputController({String? number, String? phoneCode, String? regionCode})
    : _phoneNumber = number ?? '',
      _phoneCode = phoneCode ?? AppConfig.defaultPhoneCode,
      _regionCode = regionCode ?? AppConfig.defaultCountryCode;

  factory PhoneInputController.empty() => PhoneInputController()..clear();

  bool _isValidPhone = false;

  String _phoneCode = AppConfig.defaultPhoneCode;

  String get phoneCode => _phoneCode;

  set phoneCode(String? value) {
    if (value == null) return;
    _phoneCode = value;
  }

  String _phoneNumber = '';

  String get phoneNumber => _phoneNumber;

  set phoneNumber(String? value) {
    if (value == null) return;
    _phoneNumber = value;
    notifyListeners();
  }

  String _regionCode = AppConfig.defaultCountryCode;

  String get regionCode => _regionCode;

  set regionCode(String? value) {
    if (value == null) return;
    _regionCode = value;
  }

  String _formattedNumber = '';

  String get formattedNumber => _formattedNumber;

  set formattedNumber(String? value) {
    if (value == null) return;
    _formattedNumber = value;
  }

  void clear() {
    super.clear();
    _phoneNumber = '';
    _phoneCode = AppConfig.defaultPhoneCode;
    _regionCode = AppConfig.defaultCountryCode;
    _isValidPhone = false;
    notifyListeners();
  }

  /// Performs asynchronous validation of the phone number and runs the validator chain.
  ///
  /// Because phone validation via native libraries (like flutter_libphonenumber) is
  /// asynchronous, and the core [TextController.validate] framework is synchronous:
  /// 1. This method runs the async phone parsing logic first and caches the result in [_isValidPhone].
  /// 2. It then triggers [validate], executing the registered synchronous validators.
  /// 3. The [CallbackValidator] registered in the UI retrieves the cached [_isValidPhone] value.
  ///
  /// NOTE: We DO NOT override `get value` or `get text` on this controller. Overriding
  /// those properties breaks the text field cursor positioning/selection and makes
  /// input feel read-only.
  Future<bool> validateAsync() async {
    if (text.isEmpty) {
      _isValidPhone = false;
      return validate();
    }

    try {
      final countries = CountryManager().countries;
      final country = countries.firstWhere(
        (element) =>
            element.countryCode.toLowerCase() == regionCode.toLowerCase(),
        orElse: () => CountryWithPhoneCode.us(),
      );

      final result = await getFormattedParseResult(text, country);
      if (result == null) {
        _isValidPhone = false;
      } else {
        final phoneCode = country.phoneCode;
        _phoneCode = phoneCode;
        _phoneNumber = result.e164.substring(phoneCode.length + 1);
        _regionCode = country.countryCode;
        _formattedNumber = result.formattedNumber;
        _isValidPhone = true;
      }
    } catch (e) {
      _isValidPhone = false;
    }

    return validate();
  }

  @override
  String toString() {
    return 'PhoneInputController{_phoneCode: $_phoneCode, _phoneNumber: $_phoneNumber}';
  }
}
