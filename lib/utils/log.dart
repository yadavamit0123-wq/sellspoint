import 'dart:developer';
import 'dart:io';

import 'package:logger/logger.dart';

class Log {
  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      excludeBox: {Level.info: true, Level.debug: true},
      colors: Platform.isAndroid,
    ),
  );

  static set level(Level level) {
    Logger.level = level;
  }

  static Level get level => Logger.level;

  static void info(String message) {
    if (Platform.isIOS) {
      log(message);
      return;
    }
    _logger.i(message, stackTrace: null);
  }

  static void debug(String message, {Object? error, StackTrace? trace}) {
    if (Platform.isIOS) {
      log(message);
      log('$error $trace');
      return;
    }
    _logger.d(message, error: error, stackTrace: trace);
  }

  static void warning(String message) {
    if (Platform.isIOS) {
      log(message);
      return;
    }
    _logger.w(message);
  }

  static void error(String message, Object? error, StackTrace? stack) {
    if (Platform.isIOS) {
      log(message);
      log('$error $stack');
      return;
    }
    _logger.e(message, error: error, stackTrace: stack);
  }

  static void loggerCheck() {
    info('This is info log');
    debug('This is debug log');
    warning('This is warning log');
    error('This is error log', Exception(), StackTrace.current);
  }
}
