import 'dart:async';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/category/fetch_category_cubit.dart';
import 'package:eClassify/ui/screens/home/home_screen.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeSearchField extends StatefulWidget {
  const HomeSearchField({super.key});

  @override
  State<HomeSearchField> createState() => _HomeSearchFieldState();
}

class _HomeSearchFieldState extends State<HomeSearchField> {
  List<String> suggestions = ["Bikes", "Jobs", "Cars", "Mobile", "Properties", "Toys", "Electronics"];
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadCategories(); // Initial load
    _startAnimation();
  }

  void _loadCategories() {
    final state = context.read<FetchCategoryCubit>().state;
    if (state is FetchCategorySuccess && state.categories.isNotEmpty) {
      suggestions = state.categories.map((category) => category.name!).toList();
    } else {
      suggestions = ["Bikes", "Jobs", "Cars", "Mobile"]; // Default fallback
    }
    _currentIndex = 0; // Reset index on load/change
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % suggestions.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildSearchIcon() {
      return Padding(
        padding: const EdgeInsetsDirectional.only(start: 16.0, end: 16),
        child: UiUtils.getSvg(AppIcons.search, color: context.color.territoryColor),
      );
    }

    return BlocListener<FetchCategoryCubit, FetchCategoryState>(
      listener: (context, state) {
        if (state is FetchCategorySuccess) {
          _loadCategories(); // Auto-update suggestions on category change
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 15),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            Navigator.pushNamed(context, Routes.searchScreenRoute, arguments: {"autoFocus": true});
          },
          child: AbsorbPointer(
            absorbing: true,
            child: Container(
              width: context.screenWidth,
              height: 56,
              alignment: AlignmentDirectional.center,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: context.color.borderColor.darken(30)),
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
                      fillColor: Theme.of(context).colorScheme.secondaryColor,
                      hintText: '',
                      hintStyle: TextStyle(color: context.color.textDefaultColor.withValues(alpha: 0.5)),
                      prefixIcon: buildSearchIcon(),
                      prefixIconConstraints: const BoxConstraints(minHeight: 5, minWidth: 5),
                    ),
                    enableSuggestions: true,
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                    },
                    onTap: () {},
                    style: TextStyle(color: context.color.textDefaultColor),
                  ),
                  Positioned(
                    left: 50,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      height: 56,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Search ",
                            style: TextStyle(
                              color: context.color.textDefaultColor.withValues(alpha: 0.5),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 5,),
                          TweenAnimationBuilder<double>(
                            key: ValueKey('suggestion_$_currentIndex'),
                            duration: const Duration(milliseconds: 600),
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, (1 - value) * 20), // Start 20px below, slide up
                                child: Opacity(
                                  opacity: value,
                                  child: Text(
                                    '"${suggestions[_currentIndex]}"',
                                    style: TextStyle(
                                      color: context.color.textDefaultColor.withValues(alpha: 0.5),
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
