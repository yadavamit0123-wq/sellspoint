import 'package:eClassify/ui/screens/item/ad_posting/widgets/ad_posting_step_controller.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
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

        if (prev == null && next == null && submit == null && !stepController.showNext) {
          return const SizedBox.shrink();
        }

        return _buildButtons(
          context,
          onPrevious: prev,
          onNext: next,
          onSubmit: submit,
          showNext: stepController.showNext,
        );
      },
    );
  }

  Widget _buildButtons(
    BuildContext context, {
    VoidCallback? onPrevious,
    VoidCallback? onNext,
    VoidCallback? onSubmit,
    bool showNext = false,
  }) {
    return ColoredBox(
      color: context.colorScheme.secondary,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          Constant.horizontalPadding,
          16,
          Constant.horizontalPadding,
          MediaQuery.paddingOf(context).bottom + 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          spacing: 16,
          children: [
            if (onPrevious != null)
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    fixedSize: Size.fromHeight(48),
                  ),
                  onPressed: onPrevious,
                  child: Text('previous'.translate(context)),
                ),
              ),
            if (onNext != null || showNext)
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(fixedSize: Size.fromHeight(48)),
                  onPressed: onNext,
                  child: Text('next'.translate(context)),
                ),
              ),
            if (onSubmit != null)
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(fixedSize: Size.fromHeight(48)),
                  onPressed: onSubmit,
                  child: Text('submit'.translate(context)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
