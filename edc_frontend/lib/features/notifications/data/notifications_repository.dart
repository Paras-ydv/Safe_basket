import '../domain/app_notification.dart';

/// Network boundary for notifications (docs/flutter_app_architecture.md §4.1).
/// Backed by [FakeNotificationsRepository] until `GET /notifications` is ready.
abstract interface class NotificationsRepository {
  Future<List<AppNotification>> getNotifications();
}
