import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/risk_level.dart';
import '../../../core/models/scan_result.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/risk_colors.dart';
import '../application/home_recent_scans_provider.dart';

/// Home dashboard — hero banner + primary "Start Scanning" CTA and a read-only
/// "Recent Scans" teaser pulled from the local history cache.
///
/// Presentation only (docs/flutter_app_architecture.md §5.1): it navigates and
/// renders backend-provided risk values, never computing risk itself. The bottom
/// nav is supplied by the app shell (StatefulShellRoute), not this screen.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EDC Scan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () => context.goNamed(RouteNames.notifications),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _HeroBanner(),
            SizedBox(height: 24),
            _RecentScansSection(),
          ],
        ),
      ),
    );
  }
}

/// Headline, supporting subtitle and the primary "Start Scanning" CTA.
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scan. Know. Protect.',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check everyday products for endocrine-disrupting chemicals '
              'and understand what they mean for you.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.goNamed(RouteNames.scan),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Start Scanning'),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Recent Scans" teaser. Watches [homeRecentScansProvider] and renders each
/// [AsyncValue] branch. No logic lives here beyond mapping to widgets.
class _RecentScansSection extends ConsumerWidget {
  const _RecentScansSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recentScans = ref.watch(homeRecentScansProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Recent Scans',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        recentScans.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
          ),
          error: (error, _) => _ErrorRow(message: error.toString()),
          data: (scans) {
            if (scans.isEmpty) {
              return const _EmptyState();
            }
            return Column(
              children: [
                for (final scan in scans) _RecentScanTile(scan: scan),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// A single recent-scan row: product name, when it was scanned, and a risk chip.
class _RecentScanTile extends StatelessWidget {
  const _RecentScanTile({required this.scan});

  final ScanResult scan;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () {},
        title: Text(
          scan.productName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(_formatScannedAt(scan.scannedAt)),
        trailing: _RiskChip(risk: scan.overallRisk),
      ),
    );
  }
}

/// Small colored chip showing a backend-provided risk level. The color comes
/// from the theme's [RiskColors] extension — never computed here.
class _RiskChip extends StatelessWidget {
  const _RiskChip({required this.risk});

  final RiskLevel risk;

  @override
  Widget build(BuildContext context) {
    final color = context.riskColors.colorFor(risk);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        risk.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Shown when the history cache has no scans yet.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 40,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 8),
          Text(
            'No recent scans yet',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Tap "Start Scanning" to check your first product.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Friendly error row for the recent-scans fetch.
class _ErrorRow extends StatelessWidget {
  const _ErrorRow({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Couldn't load recent scans",
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tiny inline "time ago" formatter so we don't pull in a dependency
/// (CLAUDE.md forbids adding packages). Falls back to a plain date for older
/// scans.
String _formatScannedAt(DateTime scannedAt) {
  final now = DateTime.now();
  final diff = now.difference(scannedAt);

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
  return '${scannedAt.year}-${two(scannedAt.month)}-${two(scannedAt.day)}';
}
