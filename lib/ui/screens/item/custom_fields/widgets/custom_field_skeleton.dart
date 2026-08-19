import 'package:eClassify/data/model/item/custom_field_v2.dart';
import 'package:eClassify/ui/screens/item/custom_fields/custom_fields_controller.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class CustomFieldSkeleton extends StatelessWidget {
  const CustomFieldSkeleton({
    super.key,
    required this.field,
    required this.child,
  });

  final CustomFieldV2 field;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final provider = CustomFieldsControllerProvider.maybeOf(context);
    final controller = provider?.controller;
    final isDefaultLanguage = provider?.isDefaultLanguage ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Row(
          spacing: 4,
          children: [
            SizedBox.square(
              dimension: 28,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: CustomImage(
                    src: field.image,
                    size: Size.square(20),
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
            ),
            Text(field.name.localized, style: context.labelLarge),
            if (field.isRequired && isDefaultLanguage)
              Text('*', style: context.labelLarge.withColor(Colors.red)),
          ],
        ),

        child,
        // If the field is not a text field, show the error message
        // Because the TextboxField displays the error UI using TextField's property
        // we avoid showing it here
        if (controller != null && field is! TextboxField)
          ListenableBuilder(
            listenable: controller.errorNotifier,
            builder: (context, child) {
              if (!controller.errorNotifier.containsKey(field.id)) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsetsDirectional.only(start: 12),
                child: Text(
                  controller.errorNotifier[field.id]?.translate(context) ?? '',
                  style: context.labelSmall.withColor(
                    context.colorScheme.error,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
