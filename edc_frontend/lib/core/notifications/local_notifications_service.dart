import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Thin wrapper over `flutter_local_notifications` for showing system-tray
/// alerts. We only *display* notifications; the content/trigger is a backend
/// concern (docs/flutter_app_architecture.md §2). Real push delivery needs
/// FCM/APNs wiring on top of this later.
class LocalNotificationsService {
  LocalNotificationsService._();
  static final LocalNotificationsService instance = LocalNotificationsService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'edc_risk_alerts';
  static const _channelName = 'Risk Alerts';
  static const _channelDescription = 'Backend-triggered risk and recall alerts.';

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.high,
          ),
        );

    _initialized = true;
  }

  /// Display a local notification. Call this when a backend-delivered alert
  /// arrives (e.g. via FCM) — for now it can be triggered manually/for testing.
  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(id, title, body, details);
  }
}
