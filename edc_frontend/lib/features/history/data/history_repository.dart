import '../../../core/models/scan_result.dart';

/// The only place allowed to talk to the network for scan history
/// (docs/flutter_app_architecture.md §4.1). Returns domain models, never raw
/// JSON. Backed by [FakeHistoryRepository] until `GET /history` is ready.
abstract interface class HistoryRepository {
  /// Most recent scans for the signed-in account, newest first.
  Future<List<ScanResult>> recentScans({int limit = 5});

  /// The full scan history for the signed-in account, newest first.
  Future<List<ScanResult>> allScans();
}
