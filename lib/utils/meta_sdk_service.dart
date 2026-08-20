import 'package:eClassify/data/model/system_settings.dart';
import 'package:eClassify/utils/log.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/services.dart';

/// Admin-driven Meta (Facebook) App Events integration.
class MetaSdkService {
  MetaSdkService._();

  static const MethodChannel _channel = MethodChannel('com.pt.sellspoint/meta_sdk');

  static final FacebookAppEvents _events = FacebookAppEvents();

  static bool _configured = false;
  static bool _isEnabled = false;
  static bool _logActivateApp = true;
  static bool _logRegistration = true;
  static bool _logPurchase = true;
  static String? _appId;

  static bool get isEnabled => _isEnabled && _configured;

  /// Configures SDK credentials from [get-system-settings] and activates the app.
  static Future<void> configure(SystemSettings settings) async {
    _isEnabled = settings.isMetaSdkEnabled;
    _logActivateApp = settings.metaLogActivateApp;
    _logRegistration = settings.metaLogRegistration;
    _logPurchase = settings.metaLogPurchase;
    _appId = settings.facebookAppId;

    if (!_isEnabled ||
        settings.facebookAppId == null ||
        settings.facebookAppId!.isEmpty ||
        settings.facebookClientToken == null ||
        settings.facebookClientToken!.isEmpty) {
      _configured = false;
      return;
    }

    try {
      await _channel
          .invokeMethod<void>('configure', {
            'appId': settings.facebookAppId,
            'clientToken': settings.facebookClientToken,
          })
          .timeout(const Duration(seconds: 8));

      await _events.setAutoLogAppEventsEnabled(false);

      if (settings.metaTestMode) {
        await _events.setAdvertiserTracking(enabled: true);
      }

      _configured = true;

      if (_logActivateApp) {
        await logActivateApp();
      }
    } catch (e, stack) {
      _configured = false;
      Log.error('Meta SDK configure failed', e, stack);
    }
  }

  static Future<void> logActivateApp() async {
    if (!isEnabled || !_logActivateApp) return;
    // Native configure() already calls AppEvents activateApp on both platforms.
  }

  static Future<void> logRegistration({String? method}) async {
    if (!isEnabled || !_logRegistration) return;
    try {
      await _events.logCompletedRegistration(registrationMethod: method);
    } catch (e, stack) {
      Log.error('Meta SDK registration event failed', e, stack);
    }
  }

  static Future<void> logPurchase({
    required double amount,
    required String currency,
    String? orderId,
    int? packageId,
  }) async {
    if (!isEnabled || !_logPurchase) return;
    try {
      await _events.logPurchase(
        amount: amount,
        currency: currency,
        parameters: {
          if (orderId != null) 'order_id': orderId,
          if (packageId != null) 'package_id': packageId,
        },
      );
      if (orderId != null) {
        await _events.logSubscribe(
          price: amount,
          currency: currency,
          orderId: orderId,
        );
      }
    } catch (e, stack) {
      Log.error('Meta SDK purchase event failed', e, stack);
    }
  }
}
