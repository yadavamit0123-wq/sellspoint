import 'package:eClassify/data/model/item/custom_field_v2.dart';
import 'package:eClassify/ui/screens/item/custom_fields/custom_fields_controller.dart';
import 'package:eClassify/ui/screens/widgets/custom_text_field.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({required this.field, super.key});

  final TextboxField field;

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  final TextController _controller = TextController();

  CustomFieldsController? _customFieldsController;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _customFieldsController ??= CustomFieldsControllerProvider.maybeOf(
      context,
    )?.controller;
    _controller.text =
        _customFieldsController?.data[widget.field.id]?.value as String? ?? '';
    final isNumeric = widget.field is NumberInputField;
    final errorLabel = switch ((
      widget.field.minLength,
      widget.field.maxLength,
    )) {
      (null, null) => null,
      (final min, null) => 'lengthGreaterThanMin'.translate(context, {
        'min': min.toString(),
      }),
      (null, final max) => 'lengthLessThanMax'.translate(context, {
        'max': max.toString(),
      }),
      (final min, final max) => 'invalidLength'.translate(context, {
        'min': min.toString(),
        'max': max.toString(),
      }),
    };
    return ListenableBuilder(
      listenable: _customFieldsController?.errorNotifier ?? ValueNotifier(true),
      builder: (context, child) {
        final hasError =
            _customFieldsController?.errorNotifier.containsKey(
              widget.field.id,
            ) ??
            false;
        return TextField(
          controller: _controller,
          maxLength: widget.field.maxLength,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          textInputAction: TextInputAction.next,
          onChanged: (value) =>
              _customFieldsController?.updateValue(widget.field.id, value),
          inputFormatters: [
            if (isNumeric) FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            hintText: widget.field.name.localized,
            errorText: hasError ? errorLabel : null,
            errorBorder: context.theme.inputDecorationTheme.enabledBorder,
            errorStyle: context.labelSmall.withColor(context.colorScheme.error),
          ),
          onTapOutside: (_) {
            FocusScope.of(context).unfocus();
          },
        );
      },
    );
  }
}
