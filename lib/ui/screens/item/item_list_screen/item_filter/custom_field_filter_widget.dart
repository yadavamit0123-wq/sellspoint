import 'package:eClassify/data/cubits/custom_field/custom_fields_cubit.dart';
import 'package:eClassify/ui/screens/item/custom_fields/custom_fields_controller.dart';
import 'package:eClassify/ui/screens/item/custom_fields/custom_fields_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomFieldFilterWidget extends StatefulWidget {
  const CustomFieldFilterWidget({
    required this.categoryId,
    required this.controller,
    this.initialData = const {},
    super.key,
  });

  final int categoryId;
  final CustomFieldsController controller;
  final Map<String, dynamic>? initialData;

  @override
  State<CustomFieldFilterWidget> createState() =>
      _CustomFieldFilterWidgetState();
}

class _CustomFieldFilterWidgetState extends State<CustomFieldFilterWidget> {
  @override
  void initState() {
    super.initState();
    context.read<CustomFieldsCubit>().getCustomFields(
      categoryId: widget.categoryId,
      isForFilter: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomFieldsCubit, CustomFieldsState>(
      listener: (context, state) {
        if (state is CustomFieldsSuccess) {
          final Map<String, dynamic> initialValues = {};
          if (widget.initialData != null) {
            widget.initialData!.forEach((key, value) {
              final match = RegExp(r'custom_fields\[(\d+)\]').firstMatch(key);
              if (match != null) {
                initialValues[match.group(1)!] = value;
              }
            });
          }

          widget.controller.clear();
          widget.controller.registerFields(state.fields, initialValues, false);
        }
      },
      builder: (context, state) {
        if (state is CustomFieldsSuccess && state.fields.isNotEmpty) {
          return CustomFieldsControllerProvider(
            controller: widget.controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: state.fields.map((field) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9.0),
                  child: CustomFieldsWidgetFactory.createField(field),
                );
              }).toList(),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
