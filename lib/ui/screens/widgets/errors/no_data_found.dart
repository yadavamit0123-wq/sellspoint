import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:flutter/material.dart';

@Deprecated('Use QErrorWidget instead')
class NoDataFound extends StatelessWidget {
  final double? height;
  final String? mainMessage;
  final String? subMessage;
  final VoidCallback? onTap;
  final double? mainMsgStyle;
  final double? subMsgStyle;
  final bool? showImage;
  final bool? showBtn;
  final String? btnName;

  const NoDataFound({
    super.key,
    this.onTap,
    this.height,
    this.mainMessage,
    this.subMessage,
    this.mainMsgStyle,
    this.subMsgStyle,
    this.showImage,
    this.showBtn = false,
    this.btnName,
  });

  @override
  Widget build(BuildContext context) {
    return QErrorWidget.emptyData();
  }
}
