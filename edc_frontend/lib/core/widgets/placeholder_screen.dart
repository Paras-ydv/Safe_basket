import 'package:flutter/material.dart';

/// Simple "Coming soon" scaffold for bottom-nav tabs whose features are not yet
/// built (History, Water Test, Learn, Profile). Replaced as each feature lands.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('$title — coming soon', style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
