import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

extension NullOrEmptyCheck<T> on T? {
  bool get isNullOrEmpty {
    if (this == null) return true;

    if (this is String) {
      return (this! as String).isEmpty;
    } else if (this is Iterable) {
      return (this! as Iterable).isEmpty;
    } else if (this is Map) {
      return (this! as Map).isEmpty;
    } else {
      throw UnsupportedError(
        'Only String and Iterable supports isNullOrEmpty, but got $runtimeType',
      );
    }
  }

  bool get isNotNullAndNotEmpty => !isNullOrEmpty;
}

extension ScrollExtension on ScrollNotification {
  bool get isScrollEndNotification => this is ScrollEndNotification;

  bool get isAtBottom =>
      isScrollEndNotification && metrics.pixels >= metrics.maxScrollExtent;

  bool get isNearBottom => metrics.pixels >= metrics.maxScrollExtent - 300;
}
