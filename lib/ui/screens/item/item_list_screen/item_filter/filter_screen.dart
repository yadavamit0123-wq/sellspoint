import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/custom_field/custom_fields_cubit.dart';
import 'package:eClassify/data/enums.dart';
import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/data/model/item/item_filter.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/ui/screens/item/item_list_screen/item_filter/budget_filter_widget.dart';
import 'package:eClassify/ui/screens/item/item_list_screen/item_filter/custom_field_filter_widget.dart';
import 'package:eClassify/ui/screens/item/item_list_screen/item_filter/filter_field.dart';
import 'package:eClassify/ui/screens/item/item_list_screen/item_filter/time_filter_bottom_sheet.dart';
import 'package:eClassify/ui/screens/item/custom_fields/custom_fields_controller.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eClassify/utils/app_icons.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({
    required this.filter,
    required this.showCategoryFilter,
    super.key,
  });

  final ItemFilter? filter;
  final bool showCategoryFilter;

  @override
  State<FilterScreen> createState() => _FilterScreenState();

  static Route route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>?;
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => CustomFieldsCubit(),
        child: FilterScreen(
          filter: args?['filter'] as ItemFilter?,
          showCategoryFilter: args?['show_category_filter'] ?? true,
        ),
      ),
    );
  }
}

class _FilterScreenState extends State<FilterScreen> {
  late final ValueNotifier<LeafLocation?> _locationFilter = ValueNotifier(
    widget.filter?.location,
  );

  late final ValueNotifier<Category?> _categoryFilter = ValueNotifier(
    widget.filter?.category,
  );

  late final TextEditingController _minController = TextEditingController(
    text: widget.filter?.minPrice?.toString(),
  );
  late final TextEditingController _maxController = TextEditingController(
    text: widget.filter?.maxPrice?.toString(),
  );
  final ValueNotifier<bool> _isBudgetValid = ValueNotifier(true);

  late final ValueNotifier<PostedSince> _timeFilter = ValueNotifier(
    widget.filter?.postedSince ?? PostedSince.allTime,
  );

  late final ValueNotifier<int?> _selectedCategory = ValueNotifier(
    widget.filter?.category?.id,
  );

  late final ValueNotifier<Map<String, dynamic>?> _customFields = ValueNotifier(
    widget.filter?.customFields,
  );

  late final CustomFieldsController _customFieldsController =
      CustomFieldsController();

  // The _customFieldsResetToken is used to force a remount of the CustomFieldFilterWidget 
  // and its children when the user presses "Reset". 
  // The new custom field widgets (e.g., DropdownSelectionWidget, CheckboxSelectionWidget) 
  // initialize their state from the CustomFieldsController, but do not automatically 
  // listen to clear() events to rebuild and clear their UI visually. 
  // By changing the key with this token, we discard their old state and force a fresh build.
  late final ValueNotifier<int> _customFieldsResetToken = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _locationFilter.dispose();
    _categoryFilter.dispose();
    _minController.dispose();
    _maxController.dispose();
    _isBudgetValid.dispose();
    _timeFilter.dispose();
    _selectedCategory.dispose();
    _customFields.dispose();
    _customFieldsResetToken.dispose();
    _customFieldsController.clear();
    super.dispose();
  }

  void _resetValues() {
    _locationFilter.value = null;
    _categoryFilter.value = widget.showCategoryFilter
        ? null
        : widget.filter?.category;
    _minController.clear();
    _maxController.clear();
    _timeFilter.value = PostedSince.allTime;
    _selectedCategory.value = widget.showCategoryFilter
        ? null
        : widget.filter?.category?.id;
    _customFieldsController.clear();
    _customFields.value = null;
    _customFieldsResetToken.value++;
  }

  ({int? min, int? max}) _parseValues() {
    final min = int.tryParse(_minController.text.trim());
    final max = int.tryParse(_maxController.text.trim());
    return (min: min, max: max);
  }

  bool get _isRangeValid {
    final values = _parseValues();
    if (values.min == null || values.max == null) {
      return true;
    }

    return values.min! <= values.max!;
  }

  Map<String, dynamic> getCustomFields() {
    final customFields = <String, dynamic>{};
    for (final element in _customFieldsController.data.values) {
      if (element.value != null && element.value.toString().isNotEmpty) {
        customFields['custom_fields[${element.field.id}]'] = element.value;
      }
    }
    return customFields;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('filterTitle'.translate(context)),
        actions: [
          TextButton(
            onPressed: _resetValues,
            child: Text('reset'.translate(context)),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: Constant.appContentPadding,
          child: FilledButton(
            style: FilledButton.styleFrom(minimumSize: Size.fromHeight(48)),
            onPressed: () {
              final budget = _parseValues();
              if (!_isRangeValid) {
                HelperUtils.showSnackBarMessage(
                  context,
                  'invalidMinMaxRange'.translate(context),
                );
                return;
              }

              final customFields = getCustomFields();

              final itemFilter = ItemFilter(
                location: _locationFilter.value,
                category: _categoryFilter.value,
                minPrice: budget.min,
                maxPrice: budget.max,
                postedSince: _timeFilter.value,
                customFields: customFields,
              );

              Navigator.of(context).pop(itemFilter);
            },
            child: Text('applyFilter'.translate(context)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: Constant.appContentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 20,
          children: [
            ValueListenableBuilder(
              valueListenable: _locationFilter,
              builder: (context, value, child) {
                return FilterField(
                  onTap: () async {
                    final selectedLocation = await Navigator.pushNamed(
                      context,
                      Routes.locationScreen,
                    );
                    if (selectedLocation != null) {
                      _locationFilter.value = selectedLocation as LeafLocation?;
                    }
                  },
                  title: 'location'.translate(context),
                  icon: AppIcons.mapPinFill,
                  value: (value?.localizedPath).isNullOrEmpty
                      ? 'global'.translate(context)
                      : value!.localizedPath,
                );
              },
            ),
            if (widget.showCategoryFilter)
              ValueListenableBuilder(
                valueListenable: _categoryFilter,
                builder: (context, value, child) {
                  return FilterField(
                    onTap: () async {
                      final selectedCategory =
                          await Navigator.pushNamed(
                                context,
                                Routes.categoryFilterScreen,
                              )
                              as Category?;
                      if (selectedCategory != null) {
                        _categoryFilter.value = selectedCategory;
                        _selectedCategory.value = selectedCategory.id;
                      }
                    },
                    title: 'category'.translate(context),
                    icon: AppIcons.squaresFourFill,
                    value: (value?.name.localized).isNullOrEmpty
                        ? 'allCategories'.translate(context)
                        : value!.name.localized,
                  );
                },
              ),
            BudgetFilterWidget(
              minController: _minController,
              maxController: _maxController,
            ),
            ValueListenableBuilder(
              valueListenable: _timeFilter,
              builder: (context, value, child) {
                return FilterField(
                  title: 'postedSince'.translate(context),
                  value: value.label.translate(context),
                  icon: AppIcons.calendarDotsFill,
                  onTap: () async {
                    final selectedTime =
                        await showModalBottomSheet(
                              context: context,
                              builder: (context) =>
                                  const TimeFilterBottomSheet(),
                            )
                            as PostedSince?;
                    if (selectedTime != null) {
                      _timeFilter.value = selectedTime;
                    }
                  },
                );
              },
            ),
            ListenableBuilder(
              listenable: Listenable.merge([
                _customFields,
                _selectedCategory,
                _customFieldsResetToken,
              ]),
              builder: (context, child) {
                final categoryId = _selectedCategory.value;
                if (categoryId == null) return const SizedBox.shrink();
                return CustomFieldFilterWidget(
                  key: ValueKey(
                    '${categoryId}_${_customFieldsResetToken.value}',
                  ),
                  categoryId: categoryId,
                  controller: _customFieldsController,
                  initialData: _customFields.value,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
