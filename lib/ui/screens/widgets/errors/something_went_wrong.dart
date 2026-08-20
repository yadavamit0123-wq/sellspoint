import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:flutter/material.dart';

@Deprecated('Use QErrorWidget instead')
class SomethingWentWrong extends StatelessWidget {
  const SomethingWentWrong({super.key});

  @override
  Widget build(BuildContext context) {
    return QErrorWidget(error: Exception(),);
  }
}
