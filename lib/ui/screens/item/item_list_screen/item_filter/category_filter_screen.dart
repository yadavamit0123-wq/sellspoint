import 'package:eClassify/data/cubits/category/category_browsing_cubit.dart';
import 'package:eClassify/ui/screens/widgets/category/category_view.dart';
import 'package:eClassify/ui/screens/widgets/category/category_picker.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryFilterScreen extends StatelessWidget {
  const CategoryFilterScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider(
        create: (_) => CategoryBrowsingCubit(),
        child: const CategoryFilterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('categories'.translate(context))),
      body: SafeArea(
        child: Padding(
          padding: Constant.appContentPadding.copyWith(bottom: 10),
          child: CategoryPicker(
            mainCategoryMode: CategoryViewMode.list,
            onSelect: (selected, path) {
              // If it's a terminal selection (leaf node), navigate to items list.
              // Note: CategoryPicker's internally handles the drill-down via processCategory.
              // This onSelect is called when CategorySelected state is emitted.
              Navigator.of(context).pop(selected);
            },
          ),
        ),
      ),
    );
  }
}
