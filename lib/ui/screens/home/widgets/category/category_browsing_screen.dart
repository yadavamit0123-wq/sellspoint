import 'dart:io';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/category/category_browsing_cubit.dart';
import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/data/model/item/item_list.dart';
import 'package:eClassify/ui/screens/widgets/category/category_picker.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryBrowsingScreen extends StatelessWidget {
  const CategoryBrowsingScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    final initialCategory = routeSettings.arguments as Category?;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider(
        create: (_) => CategoryBrowsingCubit(initialPath: [?initialCategory]),
        child: CategoryBrowsingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pathNotifier = context.read<CategoryBrowsingCubit>().pathNotifier;
    return PopScope(
      canPop: !Platform.isAndroid,
      onPopInvokedWithResult: (didPop, _) {
        if(didPop) return;
        if(pathNotifier.isNotEmpty){
          context.read<CategoryBrowsingCubit>().navigateBackTo(pathNotifier.last);
          return;
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('categories'.translate(context))
        ),
        body: SafeArea(
          child: Padding(
            padding: Constant.appContentPadding.copyWith(bottom: 10),
            child: CategoryPicker(
              onSelect: (selected, path) {
                // If it's a terminal selection (leaf node), navigate to items list.
                // Note: CategoryPicker's internally handles the drill-down via processCategory.
                // This onSelect is called when CategorySelected state is emitted.
                Navigator.of(context).pushNamed(
                  Routes.itemsList,
                  arguments: CategoryMetaData(
                    category: selected,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
