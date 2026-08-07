import 'package:eClassify/data/cubits/custom_field/fetch_custom_fields_cubit.dart';
import 'package:eClassify/data/cubits/category/category_browsing_cubit.dart';
import 'package:eClassify/data/cubits/item/ad_posting_cubit.dart';
import 'package:eClassify/data/model/item/ad_posting_step.dart';
import 'package:eClassify/data/model/category_model.dart';
import 'package:eClassify/ui/screens/item/add_item_screen/widgets/category.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/ad_posting_step_controller.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_silver_grid_delegate.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdPostingCategoryStep extends StatefulWidget {
  const AdPostingCategoryStep({super.key, this.extraArguments});

  final Map<String, dynamic>? extraArguments;

  @override
  State<AdPostingCategoryStep> createState() => _AdPostingCategoryStepState();
}

class _AdPostingCategoryStepState extends State<AdPostingCategoryStep> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.isEndReached()) return;
    context.read<CategoryBrowsingCubit>().fetchMore();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cubit = context.read<AdPostingCubit>();
    AdPostingStepController.of(context).register(
      onPrevious: () {
        context.read<CategoryBrowsingCubit>().navigateToRoot();
        cubit.previousStep();
      },
    );
  }

  void _onCategoryTap(CategoryModel category, List<CategoryModel> path) {
    final browsing = context.read<CategoryBrowsingCubit>();
    final posting = context.read<AdPostingCubit>();
    final fullPath = [...path, category];

    if (CategoryBrowsingCubit.hasSubCategories(category)) {
      browsing.openCategory(category);
      return;
    }

    final posting = context.read<AdPostingCubit>();
    posting.removeStep(AdPostingStep.customFields);
    posting.updateData((d) => d.copyWith(categoryPath: fullPath));

    final ids = fullPath.map((c) => c.id.toString()).join(',');
    context.read<FetchCustomFieldsCubit>().fetchCustomFields(categoryIds: ids);
    posting.nextStep();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBrowsingCubit, CategoryBrowsingState>(
      builder: (context, state) {
        if (state is CategoryBrowsingInProgress ||
            state is CategoryBrowsingInitial) {
          return UiUtils.progress();
        }
        if (state is CategoryBrowsingFailure) {
          return Center(child: CustomText(state.message));
        }
        if (state is! CategoryBrowsingSuccess) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.path.isNotEmpty) _BreadcrumbBar(path: state.path),
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                  crossAxisCount: 3,
                  height: MediaQuery.of(context).size.height * 0.16,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  return CategoryCard(
                    title: category.name ?? '',
                    url: category.url ?? '',
                    onTap: () => _onCategoryTap(category, state.path),
                  );
                },
              ),
            ),
            if (state.isLoadingMore) UiUtils.progress(),
          ],
        );
      },
    );
  }
}

class _BreadcrumbBar extends StatelessWidget {
  const _BreadcrumbBar({required this.path});

  final List<CategoryModel> path;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(15, 4, 15, 0),
      child: Row(
        children: [
          _Crumb(
            label: 'allCategories'.translate(context),
            onTap: () => context.read<CategoryBrowsingCubit>().navigateToRoot(),
          ),
          for (var i = 0; i < path.length; i++) ...[
            Icon(Icons.chevron_right,
                size: 18, color: context.color.textLightColor),
            _Crumb(
              label: path[i].name ?? '',
              onTap: () =>
                  context.read<CategoryBrowsingCubit>().navigateToIndex(i),
              isLast: i == path.length - 1,
            ),
          ],
        ],
      ),
    );
  }
}

class _Crumb extends StatelessWidget {
  const _Crumb({
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: CustomText(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
          color: isLast
              ? context.color.territoryColor
              : context.color.textDefaultColor,
        ),
      ),
    );
  }
}
