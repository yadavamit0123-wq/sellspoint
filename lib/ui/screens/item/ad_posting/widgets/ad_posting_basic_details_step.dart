import 'package:eClassify/data/cubits/ai/generate_description_cubit.dart';
import 'package:eClassify/data/cubits/item/ad_posting_cubit.dart';
import 'package:eClassify/data/model/item/ad_posting_step.dart';
import 'package:eClassify/ui/screens/item/add_item_screen/widgets/ai_generate_button.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/ad_posting_step_controller.dart';
import 'package:eClassify/ui/screens/widgets/custom_text_form_field.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/ad_posting_legacy_handoff.dart';
import 'package:eClassify/utils/ad_posting_wizard_utils.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// In-wizard title, slug, description (+ AI), price, phone.
class AdPostingBasicDetailsStep extends StatefulWidget {
  const AdPostingBasicDetailsStep({super.key, this.extraArguments});

  final Map<String, dynamic>? extraArguments;

  @override
  State<AdPostingBasicDetailsStep> createState() =>
      _AdPostingBasicDetailsStepState();
}

class _AdPostingBasicDetailsStepState extends State<AdPostingBasicDetailsStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _slugController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _phoneController;
  var _controllersReady = false;

  @override
  void dispose() {
    if (_controllersReady) {
      _titleController.removeListener(_onTitleChanged);
      _titleController.dispose();
      _slugController.dispose();
      _descriptionController.dispose();
      _priceController.dispose();
      _phoneController.dispose();
    }
    super.dispose();
  }

  void _ensureControllers() {
    if (_controllersReady) return;
    _controllersReady = true;
    final data = context.read<AdPostingCubit>().state.adPostingData;
    _titleController = TextEditingController(text: data.title ?? '');
    _slugController = TextEditingController(text: data.slug ?? '');
    _descriptionController =
        TextEditingController(text: data.description ?? '');
    _priceController = TextEditingController(text: data.price ?? '');
    _phoneController = TextEditingController(
      text: data.phone ?? HiveUtils.getUserDetails().mobile ?? '',
    );
    _titleController.addListener(_onTitleChanged);
    if (_slugController.text.isEmpty && _titleController.text.isNotEmpty) {
      _slugController.text =
          AdPostingWizardUtils.generateSlug(_titleController.text);
    }
  }

  void _onTitleChanged() {
    if (!AdPostingWizardUtils.autoSlugFromTitle) return;
    _slugController.text =
        AdPostingWizardUtils.generateSlug(_titleController.text);
  }

  String _languageIdForAi() {
    final lang = HiveUtils.getLanguage();
    if (lang is Map) {
      return (lang['id'] ?? lang['code'] ?? '1').toString();
    }
    return '1';
  }

  String _categoryNameForAi() {
    return context
            .read<AdPostingCubit>()
            .state
            .adPostingData
            .leafCategory
            ?.name ??
        '';
  }

  void _generateDescriptionWithAi() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      HelperUtils.showSnackBarMessage(
        context,
        'titleIsRequiredForAIGeneration'.translate(context),
      );
      return;
    }
    context.read<GenerateDescriptionCubit>().generate(
          title: title,
          price: _priceController.text.trim(),
          languageId: _languageIdForAi(),
          category: _categoryNameForAi(),
          currencyISOCode: Constant.currencyIsoCode,
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureControllers();
    AdPostingStepController.of(context).register(
      onPrevious: () => context.read<AdPostingCubit>().previousStep(),
      onNext: _onNext,
      showNext: true,
    );
  }

  void _onNext() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final cubit = context.read<AdPostingCubit>();
    cubit.updateData(
      (d) => d.copyWith(
        title: _titleController.text.trim(),
        slug: _slugController.text.trim(),
        description: _descriptionController.text.trim(),
        price: _priceController.text.trim(),
        phone: _phoneController.text.trim(),
      ),
    );

    final steps = cubit.state.steps;
    final baseIndex = steps.indexOf(AdPostingStep.baseDetails);
    if (baseIndex >= 0 && baseIndex + 1 < steps.length) {
      cubit.nextStep();
      return;
    }

    final data = cubit.state.adPostingData;
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
    _ensureControllers();
    final leaf =
        context.watch<AdPostingCubit>().state.adPostingData.leafCategory;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leaf?.name != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CustomText(
                  leaf!.name!,
                  fontWeight: FontWeight.w600,
                  color: context.color.territoryColor,
                ),
              ),
            CustomTextFormField(
              controller: _titleController,
              hintText: 'adTitle'.translate(context),
              validator: CustomTextFieldValidator.nullCheck,
              capitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            CustomTextFormField(
              controller: _slugController,
              hintText: 'adSlugHere'.translate(context),
              validator: CustomTextFieldValidator.slug,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: BlocConsumer<GenerateDescriptionCubit,
                  GenerateDescriptionState>(
                listener: (context, state) {
                  if (state is GenerateDescriptionSuccess) {
                    _descriptionController.text = state.description;
                  }
                  if (state is GenerateDescriptionFailure) {
                    HelperUtils.showSnackBarMessage(
                      context,
                      state.errorMessage,
                    );
                  }
                },
                builder: (context, state) {
                  return AiGenerateButton(
                    isLoading: state is GenerateDescriptionInProgress,
                    onPressed: _generateDescriptionWithAi,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            CustomTextFormField(
              controller: _descriptionController,
              hintText: 'description'.translate(context),
              maxLine: 5,
              validator: CustomTextFieldValidator.nullCheck,
              capitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            CustomTextFormField(
              controller: _priceController,
              hintText: 'price'.translate(context),
              keyboard: TextInputType.number,
              prefix: CustomText('${Constant.currencySymbol} '),
              validator: CustomTextFieldValidator.nullCheck,
            ),
            const SizedBox(height: 12),
            CustomTextFormField(
              controller: _phoneController,
              hintText: 'phoneNumber'.translate(context),
              keyboard: TextInputType.phone,
              validator: CustomTextFieldValidator.phoneNumber,
            ),
          ],
        ),
      ),
    );
  }
}
