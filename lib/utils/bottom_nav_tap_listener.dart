import 'dart:async';

import 'package:eClassify/data/cubits/system/bottom_nav_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

class BottomNavTapListener extends StatefulWidget {
  const BottomNavTapListener({
    required this.listenFor,
    required this.onTap,
    required this.child,
    this.throttleDuration = const Duration(seconds: 5),
    super.key,
  });

  final BottomTab listenFor;
  final VoidCallback onTap;
  final Widget child;
  final Duration throttleDuration;

  @override
  State<BottomNavTapListener> createState() => _BottomNavTapListenerState();
}

class _BottomNavTapListenerState extends State<BottomNavTapListener> {
  late StreamSubscription<BottomTab> _tapSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tapSubscription = context
        .read<BottomNavCubit>()
        .taps
        .where((tab) => tab == widget.listenFor)
        .throttleTime(widget.throttleDuration)
        .listen((_) => widget.onTap());
  }

  @override
  void dispose() {
    _tapSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
