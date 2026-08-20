import 'package:eClassify/data/cubits/custom_field/custom_fields_cubit.dart';
import 'package:eClassify/data/cubits/item/ad_posting_cubit.dart';
import 'package:eClassify/data/model/core/language.dart';
import 'package:eClassify/data/model/item/custom_field_v2.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/ad_posting_step_controller.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/language_tab_bar.dart';
import 'package:eClassify/ui/screens/item/custom_fields/custom_fields_controller.dart';
import 'package:eClassify/ui/screens/item/custom_fields/custom_fields_factory.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomFieldsForm extends StatefulWidget {
  const CustomFieldsForm({super.key});

  @override
  State<CustomFieldsForm> createState() => _CustomFieldsFormState();
}

class _CustomFieldsFormState extends State<CustomFieldsForm> {
  /// Complete list of custom fields.
  late final List<CustomFieldV2> _originalFields;
  late final bool _hasTextField;
  final CustomFieldsController _controller = CustomFieldsController();

  late final ValueNotifier<Language> _languageNotifier;

  /// List of custom fields for the current language.
  late List<CustomFieldV2> _languageFilteredFields;

  @override
  void initState() {
    super.initState();
    _originalFields =
        (context.read<CustomFieldsCubit>().state as CustomFieldsSuccess).fields;
    _languageFilteredFields = List.from(_originalFields);
    _hasTextField = _originalFields.any((field) => field is TextInputField);

    // Initialize Language Notifier
    final languages = Constant.systemSettings.languages;
    final defaultLanguage = languages.firstWhere((l) => l.isDefault);
    _languageNotifier = ValueNotifier(defaultLanguage);

    _loadLanguageData(_languageNotifier.value);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AdPostingStepController.of(context).register(
      onPrevious: () {
        context.read<AdPostingCubit>().previousStep();
      },
      onNext: () {
        if (!_controller.validate()) return;
        _updateCustomFieldsData();
        context.read<AdPostingCubit>().nextStep();
      },
    );
  }

  void _updateCustomFieldsData() {
    final values = {
      for (final element in _controller.data.values)
        element.field.id.toString(): ?element.value,
    };
    context.read<AdPostingCubit>().updateData(
      (data) => data.copyWith(
        customFieldsEntry: MapEntry(_languageNotifier.value.id, values),
      ),
    );
  }

  void _loadLanguageData(Language language) {
    final data = context.read<AdPostingCubit>().state.adPostingData;
    final values = data.customFields?[language.id.toString()];

    if (language.isDefault) {
      _languageFilteredFields = List.from(_originalFields);
    } else {
      _languageFilteredFields = List.from(_originalFields)
        ..removeWhere((field) => field is! TextInputField);
    }

    _controller
      ..clear()
      ..registerFields(_languageFilteredFields, values);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_hasTextField)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Constant.horizontalPadding,
              vertical: 20,
            ),
            child: LanguageTabBar(
              onLanguageChanged: (language) async {
                if (_languageNotifier.value.isDefault &&
                    !_controller.validate()) {
                  return false;
                }
                _updateCustomFieldsData();
                _loadLanguageData(language);
                _languageNotifier.value = language;
                return true;
              },
            ),
          ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _languageNotifier,
            builder: (context, language, child) {
              return SingleChildScrollView(
                padding: Constant.safeAreaMinimumPadding,
                child: CustomFieldsControllerProvider(
                  controller: _controller,
                  isDefaultLanguage: language.isDefault,
                  child: Column(
                    spacing: 16,
                    children: [
                      for (final field in _languageFilteredFields)
                        CustomFieldsWidgetFactory.createField(field),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
