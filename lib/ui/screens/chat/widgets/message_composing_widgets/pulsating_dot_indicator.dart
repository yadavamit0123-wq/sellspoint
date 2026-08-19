import 'package:flutter/material.dart';

class PulsatingDotIndicator extends StatefulWidget {
  const PulsatingDotIndicator({this.color = Colors.white,super.key});
  final Color color;

  @override
  State<PulsatingDotIndicator> createState() => _PulsatingDotIndicatorState();
}

class _PulsatingDotIndicatorState extends State<PulsatingDotIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0.22, 1, 0.36, 1),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        ScaleTransition(
          scale: Tween<double>(begin: 1, end: 1.8).animate(curved),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.6, end: 0).animate(curved),
            child: _dot(),
          ),
        ),
        _dot(), // static dot
      ],
    );
  }

  Widget _dot() {
    return CircleAvatar(
      radius: 5,
      backgroundColor: widget.color,
    );
  }
}
