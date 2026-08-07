import 'package:eClassify/data/cubits/item/ad_posting_cubit.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdPostingStepHeader extends StatelessWidget {
  const AdPostingStepHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdPostingCubit, AdPostingState>(
      builder: (context, state) {
        final index = state.steps.indexOf(state.activeStep) + 1;
        final total = state.steps.length;
        final step = state.activeStep;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: context.color.secondaryColor,
            border: Border(
              top: BorderSide(
                color: context.color.borderColor.withValues(alpha: 0.4),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      context.color.territoryColor.withValues(alpha: 0.12),
                  child: CustomText(
                    '$index/$total',
                    fontWeight: FontWeight.w600,
                    fontSize: context.font.small,
                    color: context.color.territoryColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        step.titleKey.translate(context),
                        fontWeight: FontWeight.w600,
                        color: context.color.textDefaultColor,
                      ),
                      CustomText(
                        step.subtitleKey.translate(context),
                        fontSize: context.font.small,
                        color: context.color.textLightColor,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
