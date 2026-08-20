import 'package:eClassify/ui/screens/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';

class LoadingOverlay {
  static OverlayEntry? _overlayEntry;

  static bool get _isShowing => _overlayEntry != null;

  static void show(BuildContext context) {
    if (_isShowing) return;

    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return const _LoadingOverlayWidget();
      },
    );

    overlay.insert(_overlayEntry!);
  }

  static void hide() {
    if (!_isShowing) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _LoadingOverlayWidget extends StatelessWidget {
  const _LoadingOverlayWidget();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        ModalBarrier(dismissible: false, color: Colors.black45),
        Center(child: LoadingIndicator()),
      ],
    );
  }
}
