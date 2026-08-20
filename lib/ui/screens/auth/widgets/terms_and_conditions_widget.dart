import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/company_details.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class TermsAndConditionsWidget extends StatelessWidget {
  /// If true, a checkbox is shown before the text.
  final bool showCheckbox;

  /// The current checked state for the checkbox. Only used when [showCheckbox] is true.
  final bool? isChecked;

  /// Called whenever the checkbox value changes. Must be provided when [showCheckbox] is true.
  final ValueChanged<bool?>? onCheckboxChanged;

  const TermsAndConditionsWidget({
    super.key,
    this.showCheckbox = false,
    this.isChecked,
    this.onCheckboxChanged,
  }) : assert(
         !showCheckbox || onCheckboxChanged != null,
         'onCheckboxChanged must not be null if showCheckbox is true',
       );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: Constant.safeAreaMinimumPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showCheckbox)
            _buildCheckboxRow(context)
          else
            _buildTextBlock(context),
        ],
      ),
    );
  }

  /// Builds the checkbox + text row for the signup screen.
  Widget _buildCheckboxRow(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: isChecked ?? false,
            activeColor: context.color.territoryColor,
            onChanged: onCheckboxChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          _buildTextBlock(context),
        ],
      ),
    );
  }

  /// The terms text with tappable links.
  Widget _buildTextBlock(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomText(
          "bySigningUpLoggingIn".translate(context),
          color: context.color.textLightColor.withValues(alpha: 0.8),
          fontSize: context.font.small,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              child: CustomText(
                "termsOfService".translate(context),
                showUnderline: true,
                color: context.color.territoryColor,
                fontSize: context.font.small,
              ),
              onTap: () => Navigator.pushNamed(
                context,
                Routes.companyPage,
                arguments: CompanyPage.termsAndConditions,
              ),
            ),
            const SizedBox(width: 5.0),
            CustomText(
              "andTxt".translate(context),
              color: context.color.textLightColor.withValues(alpha: 0.8),
              fontSize: context.font.small,
            ),
            const SizedBox(width: 5.0),
            GestureDetector(
              child: CustomText(
                "privacyPolicy".translate(context),
                showUnderline: true,
                color: context.color.territoryColor,
                fontSize: context.font.small,
              ),
              onTap: () => Navigator.pushNamed(
                context,
                Routes.companyPage,
                arguments: CompanyPage.privacyPolicy,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
