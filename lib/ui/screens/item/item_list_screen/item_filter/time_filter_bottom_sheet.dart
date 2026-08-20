import 'package:eClassify/data/enums.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class TimeFilterBottomSheet extends StatelessWidget {
  const TimeFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: PostedSince.values.map((element) {
          return ListTile(
            title: Text(element.label.translate(context)),
            onTap: () {
              Navigator.pop(context, element);
            },
          );
        }).toList(),
      ),
    );
  }
}
