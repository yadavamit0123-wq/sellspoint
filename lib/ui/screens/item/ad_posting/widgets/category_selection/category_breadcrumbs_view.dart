import 'package:eClassify/data/cubits/category/category_browsing_cubit.dart';
import 'package:eClassify/data/cubits/item/ad_posting_cubit.dart';
import 'package:eClassify/data/model/item/ad_posting_step.dart';
import 'package:eClassify/ui/screens/widgets/category/category_breadcrumbs_widget.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryBreadcrumbsView extends StatelessWidget {
  const CategoryBreadcrumbsView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentStep = context.read<AdPostingCubit>().state.activeStep;
    final isCategoryStep = currentStep == AdPostingStep.category;
    final pathNotifier = context.read<CategoryBrowsingCubit>().pathNotifier;
    return ListenableBuilder(
      listenable: pathNotifier,
      builder: (context, child) {
        if (pathNotifier.isEmpty) return const SizedBox.shrink();
        return DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorScheme.secondary,
            border: Border(top: BorderSide(color: context.theme.dividerColor)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Constant.horizontalPadding,
              vertical: 8,
            ),
            child: isCategoryStep
                ? CategoryBreadcrumbs.dynamic(notifier: pathNotifier)
                : CategoryBreadcrumbs.static(
                    path: pathNotifier.value,
                    onTap: (category) async {
                      context.read<CategoryBrowsingCubit>().navigateBackTo(
                        category,
                      );
                      context.read<AdPostingCubit>()
                        ..clearDataExceptAdType()
                        ..jumpToStep(AdPostingStep.category);
                    },
                  ),
          ),
        );
      },
    );
  }
}
