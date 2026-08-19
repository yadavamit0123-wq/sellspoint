import 'dart:math';

import 'package:eClassify/ui/screens/chat/widgets/chat_bubble.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChatShimmerWidget extends StatelessWidget {
  const ChatShimmerWidget({this.seed, this.count = 20, super.key});

  final int? seed;
  final int count;

  @override
  Widget build(BuildContext context) {
    final random = Random(seed ?? count);
    return Column(
      spacing: 10,
      children: List.generate(count, (index) {
        final n = random.nextBool();
        final alignment = n
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart;
        return Align(
          alignment: alignment,
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.shimmerBaseColor,
            highlightColor: Theme.of(context).colorScheme.shimmerHighlightColor,
            child: ChatBubble(
              child: SizedBox.fromSize(
                size: Size(MediaQuery.sizeOf(context).width * .5, 40),
              ),
              isMe: n,
            ),
          ),
        );
      }),
    );
  }
}
