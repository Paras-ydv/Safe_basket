import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/risk_level.dart';
import '../../../core/models/scan_result.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/risk_colors.dart';
import '../application/history_providers.dart';
import '../domain/trends.dart';

/// History & Trends — `/history` (docs/flutter_app_architecture.md §5.6).
///
/// Tabbed screen: "History" lists past scans (backend-provided risk chips);
/// "Trends" renders exposure-over-time and risk-breakdown charts built from
/// [trendsProvider]'s aggregation of already-stored scan results. This screen
/// is presentation only — it never recomputes risk categories, it only
/// renders what the notifiers/providers hand it. Lives inside the app shell's
/// bottom-navigation, so no BottomNavigationBar here.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'History'),
              Tab(text: 'Trends'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _HistoryTab(),
            _TrendsTab(),
          ],
        ),
      ),
    );
  }
}

/// Tab 1: full scan history list, newest first.
class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyListProvider);

    return history.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorState(message: error.toString()),
      data: (scans) {
        if (scans.isEmpty) {
          return const _EmptyHistoryState();
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: scans.length,
          itemBuilder: (context, index) => _HistoryTile(scan: scans[index]),
        );
      },
    );
  }
}

/// A single history row: product name, formatted scan date, and a risk chip.
class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.scan});

  final ScanResult scan;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => context.goNamed(
          RouteNames.scanResult,
          pathParameters: {'scanId': scan.scanId},
        ),
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

/// Shown when there is no scan history at all.
class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

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
              Icons.history_outlined,
              size: 40,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text('No scans yet', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'Scans you complete will show up here.',
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

/// Friendly error state shared by both tabs.
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
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 32),
            const SizedBox(height: 8),
            Text("Couldn't load your history", style: theme.textTheme.titleSmall),
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

/// Tab 2: exposure-over-time chart + risk-breakdown chart, built from
/// pre-aggregated [Trends]. No risk computation happens here.
class _TrendsTab extends ConsumerWidget {
  const _TrendsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trends = ref.watch(trendsProvider);

    return trends.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorState(message: error.toString()),
      data: (data) {
        final hasScans = data.riskDistribution.values.any((c) => c > 0);
        if (!hasScans) {
          return const _EmptyTrendsState();
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Exposure Over Time',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: _WeeklyScanCountsChart(points: data.weeklyScanCounts),
              ),
              const SizedBox(height: 24),
              Text(
                'Risk Breakdown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: _RiskDistributionChart(distribution: data.riskDistribution),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Bar chart of scan counts per week bucket (oldest → newest), from
/// [Trends.weeklyScanCounts]. Chosen over a line chart because weekly scan
/// counts are discrete buckets, which reads more naturally as bars.
class _WeeklyScanCountsChart extends StatelessWidget {
  const _WeeklyScanCountsChart({required this.points});

  final List<TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final maxValue = points.fold<double>(
      0,
      (max, p) => p.value > max ? p.value : max,
    );
    final chartMax = maxValue <= 0 ? 1.0 : maxValue * 1.2;

    return BarChart(
      BarChartData(
        maxY: chartMax,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: chartMax / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: chartMax / 4,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    points[index].label,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < points.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: points[i].value,
                  color: colorScheme.primary,
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Bar chart of scan counts per [RiskLevel], colored via the theme's
/// [RiskColors] extension. Counts arrive pre-aggregated from the backend's
/// stored results — this widget never decides what "high risk" means.
class _RiskDistributionChart extends StatelessWidget {
  const _RiskDistributionChart({required this.distribution});

  final Map<RiskLevel, int> distribution;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final riskColors = context.riskColors;

    final levels = RiskLevel.values;
    final maxCount = levels.fold<int>(
      0,
      (max, level) => (distribution[level] ?? 0) > max ? distribution[level]! : max,
    );
    final chartMax = maxCount <= 0 ? 1.0 : maxCount * 1.2;

    return BarChart(
      BarChartData(
        maxY: chartMax,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: chartMax / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: chartMax / 4,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= levels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    levels[index].label,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < levels.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (distribution[levels[i]] ?? 0).toDouble(),
                  color: riskColors.colorFor(levels[i]),
                  width: 24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Shown when there are no scans to aggregate trends from.
class _EmptyTrendsState extends StatelessWidget {
  const _EmptyTrendsState();

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
              Icons.show_chart,
              size: 40,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text('No trends yet', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'Complete a few scans to see your exposure trends here.',
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

/// Tiny inline date formatter so we don't pull in a dependency (CLAUDE.md
/// forbids adding packages).
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
