import '../../../core/enums/risk_level.dart';

/// A single point on the exposure-over-time chart (e.g. one week bucket).
class TrendPoint {
  const TrendPoint({required this.label, required this.value});

  final String label;
  final double value;
}

/// Aggregated view of the scan history for the Trends tab. This only *counts*
/// stored backend results — it never recomputes risk categories
/// (docs/flutter_app_architecture.md §5.6).
class Trends {
  const Trends({required this.weeklyScanCounts, required this.riskDistribution});

  /// Number of scans per week bucket, oldest → newest.
  final List<TrendPoint> weeklyScanCounts;

  /// How many scans fell into each overall risk level.
  final Map<RiskLevel, int> riskDistribution;
}
