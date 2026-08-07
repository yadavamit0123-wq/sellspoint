import 'dart:convert';

import 'package:eClassify/data/cubits/custom_field/fetch_custom_fields_cubit.dart';
import 'package:eClassify/data/cubits/item/ad_posting_cubit.dart';
import 'package:eClassify/data/model/custom_field/custom_field_model.dart';
import 'package:eClassify/ui/screens/item/add_item_screen/custom_filed_structure/custom_field.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/ad_posting_step_controller.dart';
import 'package:eClassify/ui/screens/widgets/dynamic_field.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/ad_posting_legacy_handoff.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdPostingCustomFieldsStep extends StatefulWidget {
  const AdPostingCustomFieldsStep({super.key, this.extraArguments});

  final Map<String, dynamic>? extraArguments;

  @override
  State<AdPostingCustomFieldsStep> createState() =>
      _AdPostingCustomFieldsStepState();
}

class _AdPostingCustomFieldsStepState extends State<AdPostingCustomFieldsStep> {
  final _formKey = GlobalKey<FormState>();
  List<CustomFieldBuilder> _builders = [];
  var _built = false;

  @override
  void initState() {
    super.initState();
    AbstractField.fieldsData.clear();
    AbstractField.files.clear();
  }

  void _buildFields() {
    if (_built) return;
    final fields = context.read<FetchCustomFieldsCubit>().getFields();
    if (fields.isEmpty) return;
    _built = true;
    _builders = fields.map((CustomFieldModel field) {
      final fieldData = field.toMap();
      final builder = CustomFieldBuilder(fieldData);
      builder.init();
      return builder;
    }).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _buildFields();
    AdPostingStepController.of(context).register(
      onPrevious: () => context.read<AdPostingCubit>().previousStep(),
      onNext: _onNext,
      showNext: true,
    );
  }

  void _onNext() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final encoded = json.encode(AbstractField.fieldsData);
    final files = Map<String, dynamic>.from(AbstractField.files);

    context.read<AdPostingCubit>().updateData(
          (d) => d.copyWith(
            customFieldsJson: encoded,
            customFieldFiles: files,
          ),
        );

    final data = context.read<AdPostingCubit>().state.adPostingData;
    AdPostingLegacyHandoff.openDetails(
      context,
      categoryPath: data.categoryPath,
      wizardDraft: data.wizardDraft,
      inAppWizardHandoff: true,
      extraArguments: widget.extraArguments,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchCustomFieldsCubit, FetchCustomFieldState>(
      builder: (context, state) {
        if (state is FetchCustomFieldInProgress) {
          return UiUtils.progress();
        }
        if (state is FetchCustomFieldFail) {
          return Center(child: CustomText(state.error.toString()));
        }
        if (state is! FetchCustomFieldSuccess || state.fields.isEmpty) {
          return Center(
            child: CustomText('noDataFound'.translate(context)),
          );
        }

        _buildFields();

        return Form(
          key: _formKey,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: _builders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final builder = _builders[index];
              return StatefulBuilder(
                builder: (context, setState) {
                  builder.stateUpdater(setState);
                  return builder.build(context);
                },
              );
            },
          ),
        );
      },
    );
  }
}
