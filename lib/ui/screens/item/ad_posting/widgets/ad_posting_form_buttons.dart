import 'package:eClassify/ui/screens/item/ad_posting/widgets/ad_posting_step_controller.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class AdPostingFormButtons extends StatelessWidget {
  const AdPostingFormButtons({
    this.onPrevious,
    this.onNext,
    this.onSubmit,
    super.key,
  });

  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final stepController = AdPostingStepController.of(context);

    return ListenableBuilder(
      listenable: stepController,
      builder: (context, _) {
        final prev = onPrevious ?? stepController.onPrevious;
        final next = onNext ?? stepController.onNext;
        final submit = onSubmit ?? stepController.onSubmit;

        if (prev == null &&
            next == null &&
            submit == null &&
            !stepController.showNext) {
          return const SizedBox.shrink();
        }

        return ColoredBox(
          color: context.color.secondaryColor,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.paddingOf(context).bottom + 8,
            ),
            child: Row(
              children: [
                if (prev != null)
                  Expanded(
                    child: UiUtils.buildButton(
                      context,
                      height: 48,
                      radius: 10,
                      buttonTitle: 'previouslbl'.translate(context),
                      buttonColor: context.color.secondaryColor,
                      textColor: context.color.textDefaultColor,
                      border: BorderSide(color: context.color.borderColor),
                      onPressed: prev,
                    ),
                  ),
                if (prev != null && (next != null || stepController.showNext))
                  const SizedBox(width: 12),
                if (next != null || stepController.showNext)
                  Expanded(
                    child: UiUtils.buildButton(
                      context,
                      height: 48,
                      radius: 10,
                      buttonTitle: 'next'.translate(context),
                      buttonColor: context.color.territoryColor,
                      textColor: context.color.secondaryColor,
                      onPressed: next,
                    ),
                  ),
                if (submit != null)
                  Expanded(
                    child: UiUtils.buildButton(
                      context,
                      height: 48,
                      radius: 10,
                      buttonTitle: 'submit'.translate(context),
                      buttonColor: context.color.territoryColor,
                      textColor: context.color.secondaryColor,
                      onPressed: submit,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
