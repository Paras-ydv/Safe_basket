import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/dio_provider.dart';
import '../data/api_notifications_repository.dart';
import '../data/fake_notifications_repository.dart';
import '../data/notifications_repository.dart';
import '../domain/app_notification.dart';

part 'notifications_provider.g.dart';

/// Binding for the [NotificationsRepository]. Real Dio-backed repo by default;
/// falls back to the fake with `--dart-define=USE_FAKES=true`.
@riverpod
NotificationsRepository notificationsRepository(
  NotificationsRepositoryRef ref,
) => ApiConfig.useFakes
    ? const FakeNotificationsRepository()
    : ApiNotificationsRepository(ref.watch(dioProvider));

/// The user's notification inbox, newest first.
@riverpod
Future<List<AppNotification>> notificationsList(NotificationsListRef ref) {
  return ref.watch(notificationsRepositoryProvider).getNotifications();
}
