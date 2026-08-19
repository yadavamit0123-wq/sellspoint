import 'dart:async';
import 'dart:developer';

import 'package:eClassify/data/enums.dart';
import 'package:eClassify/utils/notification/notification_utility.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum NotificationMode { foreground, background, terminated }

abstract class NotificationEventState {
  NotificationEventState({
    required this.remoteMessage,
    required this.mode,
    required this.type,
  });

  final RemoteMessage? remoteMessage;
  final NotificationMode? mode;
  final NotificationType? type;
}

class NotificationEventInitial extends NotificationEventState {
  NotificationEventInitial()
    : super(remoteMessage: null, mode: null, type: null);
}

class BackgroundNotificationReceived extends NotificationEventState {
  BackgroundNotificationReceived({
    required super.remoteMessage,
    required super.mode,
    required super.type,
  });
}

class ForegroundNotificationReceived extends NotificationEventState {
  ForegroundNotificationReceived({
    required super.remoteMessage,
    required super.type,
  }) : super(mode: NotificationMode.foreground);
}

class ForegroundNotificationActionReceived extends NotificationEventState {
  ForegroundNotificationActionReceived({
    required super.remoteMessage,
    required this.payload,
    required super.type,
  }) : super(mode: null);
  final Map<String, String?> payload;
}

class NotificationEventCubit extends Cubit<NotificationEventState> {
  NotificationEventCubit() : super(NotificationEventInitial()) {
    _initializeNotification();
  }

  StreamSubscription<RemoteMessage>? _foregroundNotificationStream;

  Future<void> _initializeNotification() async {
    final permissionGiven =
        await NotificationUtility.initializeNotificationService(
          onForegroundNotificationTap: (payload) => emit(
            ForegroundNotificationActionReceived(
              remoteMessage: null,
              payload: payload,
              type: _getNotificationType(payload['type']),
            ),
          ),
        );

    if (permissionGiven) {
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        log('Notification Tap while in background state');
        emit(
          BackgroundNotificationReceived(
            remoteMessage: message,
            mode: NotificationMode.background,
            type: _getNotificationType(message.data['type']),
          ),
        );
      });
      _foregroundNotificationStream = FirebaseMessaging.onMessage.listen((
        message,
      ) {
        log('Foreground Notification Received');
        emit(
          ForegroundNotificationReceived(
            remoteMessage: message,
            type: _getNotificationType(message.data['type']),
          ),
        );
      });
      final message = await FirebaseMessaging.instance.getInitialMessage();
      if (message != null) {
        emit(
          BackgroundNotificationReceived(
            remoteMessage: message,
            mode: NotificationMode.terminated,
            type: _getNotificationType(message.data['type']),
          ),
        );
      }
    }
  }

  NotificationType? _getNotificationType(String? value) =>
      NotificationType.parse(value ?? '');

  @override
  Future<void> close() {
    _foregroundNotificationStream?.cancel();
    return super.close();
  }
}
