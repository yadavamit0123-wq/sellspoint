import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:eClassify/utils/app_icons.dart';

class MessageAudioButton extends StatefulWidget {
  const MessageAudioButton({
    required this.onRecordStart,
    required this.onRecordEnd,
    required this.onOffsetUpdate,
    super.key,
  });

  final Future<bool> Function() onRecordStart;
  final Function(bool cancelled, bool locked) onRecordEnd;
  final ValueChanged<Offset> onOffsetUpdate;

  @override
  State<MessageAudioButton> createState() => _MessageAudioButtonState();
}

class _MessageAudioButtonState extends State<MessageAudioButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  // Gesture State Notifiers
  final ValueNotifier<Offset> _offsetNotifier = ValueNotifier(Offset.zero);
  final ValueNotifier<bool> _isRecordingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isLockTriggeredNotifier = ValueNotifier(false);

  Offset _startPosition = Offset.zero;
  bool _isCancelTriggered = false;
  bool _isGestureActive = false;

  // Thresholds for gestures
  static const double _lockThreshold = -80.0;
  static const double _cancelThresholdValue = 160.0;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.4,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _offsetNotifier.dispose();
    _isRecordingNotifier.dispose();
    _isLockTriggeredNotifier.dispose();
    super.dispose();
  }

  void _handleLongPressStart(LongPressStartDetails details) async {
    _isGestureActive = true;
    _startPosition = details.globalPosition;
    _offsetNotifier.value = Offset.zero;

    // Check permission/start before doing anything visual
    final started = await widget.onRecordStart();

    // Only proceed if permission was granted AND the user is STILL holding
    if (started && _isGestureActive) {
      _isRecordingNotifier.value = true;
      _isLockTriggeredNotifier.value = false;
      _isCancelTriggered = false;
      _scaleController.forward();
      HapticFeedback.vibrate();
    } else {
      _isGestureActive = false;
    }
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (_isLockTriggeredNotifier.value || _isCancelTriggered) return;

    final currentPosition = details.globalPosition;
    final offset = currentPosition - _startPosition;
    _offsetNotifier.value = offset;

    // Report offset for UI animations (e.g. slide to cancel text)
    widget.onOffsetUpdate(offset);

    // RTL Detection
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    // Check for lock (swiping up -> negative Y)
    if (offset.dy < _lockThreshold) {
      _isLockTriggeredNotifier.value = true;
      _isRecordingNotifier.value = false;
      _scaleController.reverse();
      widget.onRecordEnd(false, true);
      HapticFeedback.vibrate();
    }
    // Check for cancel (swiping "outward" from the button side)
    // In LTR: button is on right, swipe left is negative.
    // In RTL: button is on left, swipe right is positive.
    else {
      final bool triggered = isRtl
          ? offset.dx > _cancelThresholdValue
          : offset.dx < -_cancelThresholdValue;

      if (triggered) {
        _isCancelTriggered = true;
        _isRecordingNotifier.value = false;
        _scaleController.reverse();
        widget.onRecordEnd(true, false);
        HapticFeedback.vibrate();
      }
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _isGestureActive = false;
    if (_isLockTriggeredNotifier.value || _isCancelTriggered) return;
    if (!_isRecordingNotifier.value) return;

    _isRecordingNotifier.value = false;
    _scaleController.reverse();
    widget.onRecordEnd(false, false);
  }

  void _handleLongPressCancel() {
    _isGestureActive = false;
    if (_isRecordingNotifier.value) {
      _scaleController.reverse();
      _isRecordingNotifier.value = false;
      widget.onRecordEnd(true, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Only rebuild the LockIndicator when offset or recording state changes
        ListenableBuilder(
          listenable: Listenable.merge([
            _isRecordingNotifier,
            _isLockTriggeredNotifier,
            _offsetNotifier,
          ]),
          builder: (context, _) {
            if (_isRecordingNotifier.value && !_isLockTriggeredNotifier.value) {
              final offset = _offsetNotifier.value;
              return Positioned(
                bottom: 60 + (offset.dy.clamp(_lockThreshold, 0.0).abs() * 0.5),
                child: _LockIndicator(offset: offset),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        GestureDetector(
          onLongPressStart: _handleLongPressStart,
          onLongPressMoveUpdate: _handleLongPressMoveUpdate,
          onLongPressEnd: _handleLongPressEnd,
          onLongPressCancel: _handleLongPressCancel,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: context.colorScheme.primary,
                foregroundColor: context.colorScheme.onPrimary,
                fixedSize: const Size.square(40),
                iconSize: 24,
              ),
              onPressed: () {}, // Handled by LongPress
              icon: const Icon(AppIcons.microphoneFill),
            ),
          ),
        ),
      ],
    );
  }
}

class _LockIndicator extends StatelessWidget {
  const _LockIndicator({required this.offset});

  final Offset offset;

  @override
  Widget build(BuildContext context) {
    // Opacity fades out as it gets closer to the lock threshold
    final opacity = (1.0 - (offset.dy.clamp(-80.0, 0.0) / -80.0)).clamp(
      0.0,
      1.0,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.secondary,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Opacity(
          opacity: opacity,
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade600,
            highlightColor: Colors.white,
            direction: ShimmerDirection.btt,
            child: Column(
              spacing: 10,
              children: const [
                Icon(AppIcons.lock, size: 20),
                Icon(AppIcons.caretUp, size: 16),
                Icon(AppIcons.caretUp, size: 16),
                Icon(AppIcons.caretUp, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
