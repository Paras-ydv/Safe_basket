import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/enums/risk_level.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

/// A backend-triggered alert the app displays (docs/flutter_app_architecture.md
/// §2 — notifications are displayed by us but triggered by backend findings).
@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String title,
    required String body,
    required DateTime receivedAt,
    // Present for risk-related alerts; null for general messages.
    RiskLevel? risk,
    @Default(false) bool read,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
