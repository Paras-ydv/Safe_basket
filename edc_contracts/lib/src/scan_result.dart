import 'detected_chemical.dart';
import 'risk_level.dart';

/// Canonical scan outcome shared by every scan flow (barcode, image, manual,
/// water, history). The client renders this as-is.
class ScanResult {
  const ScanResult({
    required this.scanId,
    required this.productName,
    required this.scannedAt,
    required this.overallRisk,
    this.productMeta,
    this.detectedChemicals = const [],
    this.disclaimer,
  });

  final String scanId;
  final String productName;
  final DateTime scannedAt;
  final RiskLevel overallRisk;
  final String? productMeta;
  final List<DetectedChemical> detectedChemicals;
  final String? disclaimer;

  factory ScanResult.fromJson(Map<String, dynamic> json) => ScanResult(
    scanId: json['scan_id'] as String,
    productName: json['product_name'] as String,
    scannedAt: DateTime.parse(json['scanned_at'] as String),
    overallRisk: RiskLevel.fromWire(json['overall_risk'] as String?),
    productMeta: json['product_meta'] as String?,
    detectedChemicals: ((json['detected_chemicals'] as List<dynamic>?) ?? const [])
        .map((e) => DetectedChemical.fromJson(e as Map<String, dynamic>))
        .toList(),
    disclaimer: json['disclaimer'] as String?,
  );

  Map<String, Object?> toJson() => {
    'scan_id': scanId,
    'product_name': productName,
    'scanned_at': scannedAt.toUtc().toIso8601String(),
    'overall_risk': overallRisk.wire,
    'product_meta': productMeta,
    'detected_chemicals': detectedChemicals.map((e) => e.toJson()).toList(),
    'disclaimer': disclaimer,
  };
}
