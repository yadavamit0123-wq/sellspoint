import 'dart:async';

import 'package:flutter/cupertino.dart';

/// A mixin that provides debouncing logic for inputs/actions in [StatefulWidget]s.
///
/// Intended for widgets or actions where operations (like API calls) should be
/// triggered only after the user pauses interaction.
///
/// ### Usage
/// The consuming class **must** call [debounce] to trigger the debounce behavior.
///
/// ```dart
/// TextField(
///   onChanged: debounce,
/// )
/// ```
///
/// This mixin handles cancellation of the timer and calls [onDebounced]
/// after a pause in user input.
///
/// Override [onDebounced] to define the behavior when the debounced input triggers.
mixin DebounceMixin<T extends StatefulWidget, V> on State<T> {
  Timer? _timer;

  @protected
  Duration get debounceDuration => const Duration(milliseconds: 500);

  void debounce(V value) {
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer(debounceDuration, () => onDebounced(value));
  }

  void cancelDebounce() {
    _timer?.cancel();
    _timer = null;
  }

  bool get isDebounceActive => _timer?.isActive ?? false;

  @protected
  void onDebounced(V value);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
