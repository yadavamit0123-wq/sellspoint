import 'dart:async';

import 'package:eClassify/data/cubits/system/bottom_nav_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

/// Runs [onRepeatTap] when the user selects the same bottom tab again (2.14).
class BottomNavTapListener extends StatefulWidget {
  const BottomNavTapListener({
    super.key,
    required this.listenFor,
    required this.onRepeatTap,
    required this.child,
    this.throttleDuration = const Duration(milliseconds: 800),
  });

  final BottomTab listenFor;
  final VoidCallback onRepeatTap;
  final Widget child;
  final Duration throttleDuration;

  @override
  State<BottomNavTapListener> createState() => _BottomNavTapListenerState();
}

class _BottomNavTapListenerState extends State<BottomNavTapListener> {
  StreamSubscription<BottomTab>? _tapSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tapSubscription?.cancel();
    _tapSubscription = context
        .read<BottomNavCubit>()
        .repeatTaps
        .where((tab) => tab == widget.listenFor)
        .throttleTime(widget.throttleDuration)
        .listen((_) => widget.onRepeatTap());
  }

  @override
  void dispose() {
    _tapSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
