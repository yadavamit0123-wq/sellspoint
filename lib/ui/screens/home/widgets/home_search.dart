import 'dart:async';
import 'dart:convert';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/category/main_category_cubit.dart';
import 'package:eClassify/data/model/item/item_list.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/hive_keys.dart' show HiveKeys;
import 'package:eClassify/utils/json_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

/// Home search bar with rotating category names (Sells Point live app behavior).
class HomeSearchField extends StatefulWidget {
  const HomeSearchField({super.key});

  @override
  State<HomeSearchField> createState() => _HomeSearchFieldState();
}

class _HomeSearchFieldState extends State<HomeSearchField> {
  static const _fallbackSuggestions = [
    'Bikes',
    'Jobs',
    'Cars',
    'Mobile',
    'Properties',
    'Toys',
    'Electronics',
  ];

  List<String> _suggestions = List<String>.from(_fallbackSuggestions);
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _startAnimation();
  }

  void _loadCategories() {
    final state = context.read<MainCategoryCubit>().state;
    if (state is MainCategorySuccess && state.categories.isNotEmpty) {
      _suggestions = state.categories
          .map((category) => category.name.localized)
          .where((name) => name.trim().isNotEmpty)
          .toList();
    } else {
      _suggestions = List<String>.from(_fallbackSuggestions);
    }
    if (_suggestions.isEmpty) {
      _suggestions = List<String>.from(_fallbackSuggestions);
    }
    _currentIndex = 0;
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || _suggestions.isEmpty) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _suggestions.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _openSearch() {
    final history = Hive.box(HiveKeys.historyBox).values.map((jsonString) {
      final json = (jsonDecode(jsonString) as Map).cast<String, dynamic>();
      return JsonHelper.parseObject(json, ItemModel.fromJson);
    }).toList();

    Navigator.pushNamed(
      context,
      Routes.itemsList,
      arguments: SearchMetaData(
        title: 'search'.translate(context),
        searchHistory: history,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MainCategoryCubit, MainCategoryState>(
      listener: (context, state) {
        if (state is MainCategorySuccess) {
          setState(_loadCategories);
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Constant.horizontalPadding,
          vertical: 15,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _openSearch,
          child: AbsorbPointer(
            child: Container(
              width: context.screenWidth,
              height: 56,
              alignment: AlignmentDirectional.center,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: context.color.borderColor.darken(30),
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: context.color.secondaryColor,
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: context.color.secondaryColor,
                      hintText: '',
                      prefixIcon: Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 16,
                          end: 16,
                        ),
                        child: Icon(
                          AppIcons.magnifyingGlass,
                          color: context.color.territoryColor,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minHeight: 5,
                        minWidth: 5,
                      ),
                    ),
                    style: TextStyle(color: context.color.textDefaultColor),
                  ),
                  Positioned(
                    left: 50,
                    top: 0,
                    bottom: 0,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'search'.translate(context),
                            style: TextStyle(
                              color: context.color.textDefaultColor.withValues(
                                alpha: 0.5,
                              ),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 5),
                          TweenAnimationBuilder<double>(
                            key: ValueKey('suggestion_$_currentIndex'),
                            duration: const Duration(milliseconds: 600),
                            tween: Tween<double>(begin: 0, end: 1),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, (1 - value) * 20),
                                child: Opacity(
                                  opacity: value,
                                  child: Text(
                                    '"${_suggestions[_currentIndex]}"',
                                    style: TextStyle(
                                      color: context.color.textDefaultColor
                                          .withValues(alpha: 0.5),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
