import '../../../core/enums/risk_level.dart';
import '../../../core/models/scan_result.dart';
import 'history_repository.dart';

/// Canned [HistoryRepository] used while the backend `/history` endpoint is not
/// yet available (docs/flutter_app_architecture.md §3 — develop against a fake
/// repository so screen work is never blocked).
class FakeHistoryRepository implements HistoryRepository {
  const FakeHistoryRepository();

  /// A spread of scans over the past ~6 weeks so the Trends charts have shape.
  List<ScanResult> _all() {
    final now = DateTime.now();
    ScanResult scan(
      String id,
      String name,
      int daysAgo,
      RiskLevel risk,
    ) => ScanResult(
      scanId: id,
      productName: name,
      scannedAt: now.subtract(Duration(days: daysAgo, hours: id.hashCode % 12)),
      overallRisk: risk,
    );

    final scans = [
      scan('h-001', 'Sunrise Body Lotion', 1, RiskLevel.moderate),
      scan('h-002', 'ClearFlow Bottled Water', 2, RiskLevel.low),
      scan('h-003', 'MattePro Nail Hardener', 4, RiskLevel.high),
      scan('h-004', 'GlowDaily Face Serum', 6, RiskLevel.moderate),
      scan('h-005', 'PureSpring Tap Sample', 9, RiskLevel.low),
      scan('h-006', 'FreshScent Deodorant', 13, RiskLevel.veryHigh),
      scan('h-007', 'SoftTouch Hand Cream', 18, RiskLevel.moderate),
      scan('h-008', 'AquaGuard Filter Output', 24, RiskLevel.low),
      scan('h-009', 'ShineMax Hair Spray', 31, RiskLevel.high),
      scan('h-010', 'GardenFresh Produce Wash', 40, RiskLevel.moderate),
    ];

    scans.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    return scans;
  }

  @override
  Future<List<ScanResult>> recentScans({int limit = 5}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _all().take(limit).toList();
  }

  @override
  Future<List<ScanResult>> allScans() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _all();
  }
}
