import 'risk_level.dart';

/// A chemical the backend detected in a product. `risk` is the normalized
/// enum; `severity`/`evidenceTier`/`message` carry the backend's richer,
/// display-only detail.
class DetectedChemical {
  const DetectedChemical({
    required this.id,
    required this.name,
    required this.risk,
    this.severity,
    this.evidenceTier,
    this.message,
  });

  final String id;
  final String name;
  final RiskLevel risk;
  final String? severity;
  final String? evidenceTier;
  final String? message;

  factory DetectedChemical.fromJson(Map<String, dynamic> json) =>
      DetectedChemical(
        id: json['id'] as String,
        name: json['name'] as String,
        risk: RiskLevel.fromWire(json['risk'] as String?),
        severity: json['severity'] as String?,
        evidenceTier: json['evidence_tier'] as String?,
        message: json['message'] as String?,
      );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'risk': risk.wire,
    'severity': severity,
    'evidence_tier': evidenceTier,
    'message': message,
  };
}
