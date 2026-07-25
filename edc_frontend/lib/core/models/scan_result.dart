import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/risk_level.dart';
import 'detected_chemical.dart';

part 'scan_result.freezed.dart';
part 'scan_result.g.dart';

/// A scan outcome as produced by the backend. The client renders this as-is and
/// never computes `overallRisk` (docs/flutter_app_architecture.md §3).
///
/// Shared cross-feature contract (home teaser, scan result, history), so it
/// lives in `core/models` alongside the `RiskLevel` enum rather than in a
/// single feature.
@freezed
class ScanResult with _$ScanResult {
  const factory ScanResult({
    required String scanId,
    required String productName,
    required DateTime scannedAt,
    required RiskLevel overallRisk,
    @Default(<DetectedChemical>[]) List<DetectedChemical> detectedChemicals,
    String? productMeta, // batch / size
    String? disclaimer, // lab-confirmation caveat, displayed verbatim
  }) = _ScanResult;

  factory ScanResult.fromJson(Map<String, dynamic> json) =>
      _$ScanResultFromJson(json);
}
