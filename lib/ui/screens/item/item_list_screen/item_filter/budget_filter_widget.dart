import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class BudgetFilterWidget extends StatelessWidget {
  const BudgetFilterWidget({
    required this.minController,
    required this.maxController,
    super.key,
  });

  final TextEditingController minController;
  final TextEditingController maxController;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('budget'.translate(context), style: context.labelLarge),
        Row(
          spacing: 20,
          children: [
            Expanded(
              child: TextField(
                autofocus: false,
                controller: minController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'min'.translate(context),
                ),
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
            Expanded(
              child: TextField(
                autofocus: false,
                controller: maxController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'max'.translate(context),
                ),
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
