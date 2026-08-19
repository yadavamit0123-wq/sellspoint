import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:flutter/material.dart';

@Deprecated('Use QErrorWidget instead')
class NoInternet extends StatelessWidget {
  const NoInternet({super.key, this.onRetry});
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return QErrorWidget(type: QErrorType.socket, onRetry: onRetry);
  }
}
