import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/risk_colors.dart';
import '../application/notifications_provider.dart';
import '../domain/app_notification.dart';

/// Notifications inbox — displays backend-triggered alerts
/// (docs/flutter_app_architecture.md §2). Opened from the Home bell icon;
/// lives outside the bottom-nav shell.
///
/// Presentation only: it renders backend-provided data (including risk
/// levels) and never computes risk itself.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notifications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(message: error.toString()),
        data: (items) {
          if (items.isEmpty) {
            return const _EmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) =>
                _NotificationTile(notification: items[index]),
          );
        },
      ),
    );
  }
}

/// A single notification row: leading risk/neutral indicator, title, body,
/// relative timestamp and an unread marker.
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final risk = notification.risk;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () {},
        leading: risk != null
            ? Semantics(
                label: '${risk.label} risk alert',
                child: Icon(Icons.circle, color: context.riskColors.colorFor(risk)),
              )
            : Icon(
                Icons.notifications_outlined,
                color: theme.colorScheme.outline,
              ),
        title: Text(
          notification.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.body),
            const SizedBox(height: 4),
            Text(
              _formatReceivedAt(notification.receivedAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: notification.read
            ? null
            : Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }
}

/// Shown when the inbox has no notifications.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none,
              size: 40,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              "You're all caught up",
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              "You'll see alerts here when there's something to know.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Friendly error state for the notifications fetch.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 40),
            const SizedBox(height: 8),
            Text(
              "Couldn't load notifications",
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tiny inline "time ago" formatter so we don't pull in a dependency
/// (CLAUDE.md forbids adding packages). Falls back to a plain date for older
/// notifications.
String _formatReceivedAt(DateTime receivedAt) {
  final now = DateTime.now();
  final diff = now.difference(receivedAt);

  if (diff.isNegative) return 'Just now';
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) {
    final m = diff.inMinutes;
    return '$m minute${m == 1 ? '' : 's'} ago';
  }
  if (diff.inHours < 24) {
    final h = diff.inHours;
    return '$h hour${h == 1 ? '' : 's'} ago';
  }
  if (diff.inDays < 7) {
    final d = diff.inDays;
    return '$d day${d == 1 ? '' : 's'} ago';
  }
  String two(int n) => n.toString().padLeft(2, '0');
  return '${receivedAt.year}-${two(receivedAt.month)}-${two(receivedAt.day)}';
}
