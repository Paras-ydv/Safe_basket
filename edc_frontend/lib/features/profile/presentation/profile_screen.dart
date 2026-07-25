import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/profile_controller.dart';
import '../domain/profile_preferences.dart';

/// Profile screen — account placeholder, notification preferences and a
/// small "About" section (docs/flutter_app_architecture.md §5.4).
///
/// Presentation only: preference toggles are forwarded straight to
/// [ProfileController]; no business logic lives here. Lives inside the app
/// shell, so no bottom nav is rendered by this screen.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _AccountSection(),
          SizedBox(height: 24),
          _NotificationsSection(),
          SizedBox(height: 24),
          _AboutSection(),
        ],
      ),
    );
  }
}

/// Signed-out account placeholder. Auth isn't wired up yet, so this only
/// offers a stub "Sign in with Google" affordance.
class _AccountSection extends StatelessWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              title: const Text('Not signed in'),
              subtitle: const Text(
                'Sign in to sync your scan history across devices',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Google Sign-In coming soon'),
                  ),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Notification preference toggles. Watches [profileControllerProvider] and
/// forwards changes to the notifier — no state is held in the widget.
class _NotificationsSection extends ConsumerWidget {
  const _NotificationsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ProfilePreferences prefs = ref.watch(profileControllerProvider);
    final notifier = ref.read(profileControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Notifications',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('High-risk alerts'),
                subtitle: const Text(
                  'Notify me when a scan is high or very-high risk',
                ),
                value: prefs.highRiskAlerts,
                onChanged: notifier.setHighRiskAlerts,
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Weekly digest'),
                subtitle: const Text(
                  'A weekly summary of my exposure trends',
                ),
                value: prefs.weeklyDigest,
                onChanged: notifier.setWeeklyDigest,
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Product recalls'),
                subtitle: const Text(
                  "Alert me about recalls on products I've scanned",
                ),
                value: prefs.productRecalls,
                onChanged: notifier.setProductRecalls,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Static "About" section — app identity and a disclaimer that risk
/// assessments come from the backend, not this client.
class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'About',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EDC Scan',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Scan. Know. Protect.', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                Text(
                  'Assessments are provided by the backend and are not a '
                  'substitute for lab confirmation.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
