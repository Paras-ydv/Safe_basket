import '../../../core/enums/risk_level.dart';
import '../domain/app_notification.dart';
import 'notifications_repository.dart';

/// Canned [NotificationsRepository] for development
/// (docs/flutter_app_architecture.md §3 — develop against a fake repository).
class FakeNotificationsRepository implements NotificationsRepository {
  const FakeNotificationsRepository();

  @override
  Future<List<AppNotification>> getNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'n-001',
        title: 'High-risk product detected',
        body: 'Sunrise Body Lotion scored High. Tap to review detected chemicals.',
        receivedAt: now.subtract(const Duration(hours: 1)),
        risk: RiskLevel.high,
      ),
      AppNotification(
        id: 'n-002',
        title: 'Product recall',
        body: 'AquaGuard Filter Output has an active recall in your region.',
        receivedAt: now.subtract(const Duration(days: 1)),
        risk: RiskLevel.veryHigh,
      ),
      AppNotification(
        id: 'n-003',
        title: 'Your weekly exposure digest',
        body: 'You scanned 4 products this week. Overall exposure trend is steady.',
        receivedAt: now.subtract(const Duration(days: 2)),
        read: true,
      ),
    ];
  }
}
