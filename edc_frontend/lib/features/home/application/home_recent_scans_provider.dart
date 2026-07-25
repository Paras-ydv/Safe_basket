import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/scan_result.dart';
import '../../history/application/history_providers.dart';

part 'home_recent_scans_provider.g.dart';

/// UI state for the Home "Recent Scans" teaser. Orchestration only — the actual
/// fetch lives in the history feature's repository
/// (docs/flutter_app_architecture.md §4.1). Home depends on `history`, which
/// owns the scan-history data.
@riverpod
class HomeRecentScans extends _$HomeRecentScans {
  @override
  Future<List<ScanResult>> build() {
    return ref.watch(historyRepositoryProvider).recentScans(limit: 3);
  }
}
