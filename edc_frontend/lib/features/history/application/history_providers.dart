import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/enums/risk_level.dart';
import '../../../core/models/scan_result.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/dio_provider.dart';
import '../data/api_history_repository.dart';
import '../data/fake_history_repository.dart';
import '../data/history_repository.dart';
import '../domain/trends.dart';

part 'history_providers.g.dart';

/// Binding for the [HistoryRepository]. Binds the real Dio-backed repo by
/// default; falls back to the fake with `--dart-define=USE_FAKES=true`.
@riverpod
HistoryRepository historyRepository(HistoryRepositoryRef ref) =>
    ApiConfig.useFakes
    ? FakeHistoryRepository()
    : ApiHistoryRepository(ref.watch(dioProvider));

/// Full scan history for the History tab (newest first).
@riverpod
Future<List<ScanResult>> historyList(HistoryListRef ref) {
  return ref.watch(historyRepositoryProvider).allScans();
}

/// Aggregated [Trends] for the Trends tab. Counts stored results only — it does
/// not recompute any risk category (§5.6).
@riverpod
Future<Trends> trends(TrendsRef ref) async {
  final scans = await ref.watch(historyRepositoryProvider).allScans();
  return _aggregate(scans);
}

Trends _aggregate(List<ScanResult> scans) {
  // Risk distribution: count scans by their (backend-decided) overall risk.
  final distribution = <RiskLevel, int>{
    for (final level in RiskLevel.values) level: 0,
  };
  for (final scan in scans) {
    distribution[scan.overallRisk] = distribution[scan.overallRisk]! + 1;
  }

  // Weekly buckets over the last 6 weeks (index 0 = oldest, 5 = current week).
  const weeks = 6;
  final now = DateTime.now();
  final counts = List<int>.filled(weeks, 0);
  for (final scan in scans) {
    final daysAgo = now.difference(scan.scannedAt).inDays;
    final weeksAgo = daysAgo ~/ 7;
    if (weeksAgo < weeks) {
      counts[weeks - 1 - weeksAgo]++;
    }
  }
  final weekly = [
    for (var i = 0; i < weeks; i++)
      TrendPoint(
        label: i == weeks - 1 ? 'Now' : '${weeks - 1 - i}w',
        value: counts[i].toDouble(),
      ),
  ];

  return Trends(weeklyScanCounts: weekly, riskDistribution: distribution);
}
