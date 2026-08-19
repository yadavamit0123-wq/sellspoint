import 'package:eClassify/data/cubits/ai/generate_meta_cubit.dart';
import 'package:eClassify/data/model/item/ad_posting_data.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/ai_generate_button.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SEODetailsController {
  SEODetailsController([Map<int, SeoData>? data]) : _data = data ?? {};

  final Map<int, SeoData> _data;

  Map<int, SeoData> get values => _data;

  void updateField(int languageId, String field, String value) {
    final data = _data[languageId] ??= SeoData();
    switch (field) {
      case 'title':
        data.metaTitle = value;
        break;
      case 'description':
        data.metaDescription = value;
        break;
      case 'keywords':
        data.metaKeywords = value;
        break;
      case 'schema':
        data.schema = value;
        break;
    }
  }

  SeoData getData(int languageId) {
    return _data[languageId] ?? SeoData();
  }
}

class SEODetails extends StatefulWidget {
  const SEODetails({
    super.key,
    required this.languageId,
    required this.controller,
    required this.onAIGenerate,
  });

  final int languageId;
  final SEODetailsController controller;
  final VoidCallback? onAIGenerate;

  @override
  State<SEODetails> createState() => _SEODetailsState();
}

class _SEODetailsState extends State<SEODetails> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();
  final TextEditingController _schemaController = TextEditingController();

  final ExpansibleController _tileController = ExpansibleController();

  final GlobalKey _lastFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadData(widget.languageId);
  }

  @override
  void didUpdateWidget(covariant SEODetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.languageId != widget.languageId) {
      _loadData(widget.languageId);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _keywordsController.dispose();
    _schemaController.dispose();
    super.dispose();
  }

  void _loadData(int langId) {
    final data = widget.controller.getData(langId);
    _titleController.text = data.metaTitle ?? '';
    _descriptionController.text = data.metaDescription ?? '';
    _keywordsController.text = data.metaKeywords ?? '';
    _schemaController.text = data.schema ?? '';
  }

  void _onChanged(String? value, String fieldKey) {
    widget.controller.updateField(widget.languageId, fieldKey, value ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      controller: _tileController,
      title: Text("seoDetails".translate(context), style: context.titleMedium),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      onExpansionChanged: (isExpanded) async {
        if (!isExpanded) return;
        // Wait until the expansion animation is complete
        await Future.delayed(const Duration(milliseconds: 300));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Log.debug('${_lastFieldKey.currentContext}');
          Scrollable.ensureVisible(
            context,
            alignment: 1.0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.decelerate,
          );
        });
      },
      children: [
        const Divider(),
        15.vGap,
        if (Constant.systemSettings.geminiAiEnabled)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: BlocConsumer<GenerateMetaCubit, GenerateMetaState>(
              listener: (context, state) {
                if (state is GenerateMetaSuccess) {
                  final data = state.data;
                  _titleController.text = data['meta_title'] ?? '';
                  _descriptionController.text = data['meta_description'] ?? '';
                  _keywordsController.text = data['meta_keywords'] ?? '';
                  _schemaController.text = data['schema'] ?? '';

                  // Update the controller fields as well
                  widget.controller.updateField(
                    widget.languageId,
                    'title',
                    _titleController.text,
                  );
                  widget.controller.updateField(
                    widget.languageId,
                    'description',
                    _descriptionController.text,
                  );
                  widget.controller.updateField(
                    widget.languageId,
                    'keywords',
                    _keywordsController.text,
                  );
                  widget.controller.updateField(
                    widget.languageId,
                    'schema',
                    _schemaController.text,
                  );
                }
                if (state is GenerateMetaFailure) {
                  HelperUtils.showSnackBarMessage(context, state.errorMessage);
                }
              },
              builder: (context, state) {
                return AIGenerateButton(
                  onPressed: widget.onAIGenerate,
                  isLoading: state is GenerateMetaInProgress,
                );
              },
            ),
          ),
        _SEOField(
          label: 'metaTitle',
          hintText: 'metaTitleHint',
          controller: _titleController,
          onChanged: (value) => _onChanged(value, 'title'),
        ),
        10.vGap,
        _SEOField(
          label: 'metaDescription',
          hintText: 'metaDescriptionHint',
          controller: _descriptionController,
          minLines: 2,
          maxLines: 5,
          onChanged: (value) => _onChanged(value, 'description'),
        ),
        10.vGap,
        _SEOField(
          label: 'metaKeywords',
          hintText: 'metaKeywordsHint',
          controller: _keywordsController,
          note: 'commaSeparatedValuesNote',
          onChanged: (value) => _onChanged(value, 'keywords'),
        ),
        10.vGap,
        _SEOField(
          key: _lastFieldKey,
          label: 'metaSchema',
          hintText: 'metaSchemaHint',
          note: 'metaSchemaNote',
          controller: _schemaController,
          minLines: 2,
          maxLines: 10,
          onChanged: (value) => _onChanged(value, 'schema'),
        ),
        10.vGap,
      ],
    );
  }
}

class _SEOField extends StatelessWidget {
  const _SEOField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.onChanged,
    this.minLines = 1,
    this.maxLines = 1,
    this.note,
    super.key,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final int minLines;
  final int maxLines;
  final ValueChanged<String?> onChanged;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label.translate(context), style: context.titleSmall.semiBold),
        if (note != null)
          Text(
            note!.translate(context),
            style: context.labelSmall.withColor(context.mutedColor),
          ),
        10.vGap,
        TextField(
          controller: controller,
          maxLines: maxLines,
          minLines: minLines,
          style: context.bodyMedium,
          onChanged: onChanged,
          decoration: InputDecoration(hintText: hintText.translate(context)),
        ),
      ],
    );
  }
}
