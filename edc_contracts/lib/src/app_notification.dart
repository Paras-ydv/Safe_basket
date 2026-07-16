import 'risk_level.dart';

/// A backend-triggered alert the client displays.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.risk,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final RiskLevel? risk;
  final bool read;

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
    receivedAt: DateTime.parse(json['received_at'] as String),
    risk: json['risk'] == null ? null : RiskLevel.fromWire(json['risk'] as String?),
    read: json['read'] as bool? ?? false,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'received_at': receivedAt.toUtc().toIso8601String(),
    'risk': risk?.wire,
    'read': read,
  };
}
