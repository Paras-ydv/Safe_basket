import 'risk_level.dart';

/// Full chemical detail, mapped from the backend `EdcEntry`. `exposureRoutes`
/// carries wire strings (`dermal`/`ingestion`/`inhalation`) the client maps to
/// its own enum; it may be empty when the source data doesn't specify routes.
class ChemicalDetail {
  const ChemicalDetail({
    required this.id,
    required this.name,
    required this.risk,
    required this.chemicalClass,
    required this.regulatoryStatus,
    this.healthEffects = const [],
    this.exposureRoutes = const [],
  });

  final String id;
  final String name;
  final RiskLevel risk;
  final String chemicalClass;
  final String regulatoryStatus;
  final List<String> healthEffects;
  final List<String> exposureRoutes;

  factory ChemicalDetail.fromJson(Map<String, dynamic> json) => ChemicalDetail(
    id: json['id'] as String,
    name: json['name'] as String,
    risk: RiskLevel.fromWire(json['risk'] as String?),
    chemicalClass: json['chemical_class'] as String? ?? '',
    regulatoryStatus: json['regulatory_status'] as String? ?? '',
    healthEffects: ((json['health_effects'] as List<dynamic>?) ?? const [])
        .map((e) => e as String)
        .toList(),
    exposureRoutes: ((json['exposure_routes'] as List<dynamic>?) ?? const [])
        .map((e) => e as String)
        .toList(),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'risk': risk.wire,
    'chemical_class': chemicalClass,
    'regulatory_status': regulatoryStatus,
    'health_effects': healthEffects,
    'exposure_routes': exposureRoutes,
  };
}
