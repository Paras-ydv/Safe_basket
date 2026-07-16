import 'package:edc_contracts/edc_contracts.dart' as c;
import 'package:edc_matcher/edc_matcher.dart';

/// Maps `edc_matcher` domain objects to the shared wire DTOs in `edc_contracts`
/// so every scan flow returns the same `ScanResult` shape (with normalized
/// risk) to the client.
c.DetectedChemical detectedFromEntry(EdcEntry e) => c.DetectedChemical(
  id: e.id,
  name: e.name,
  risk: c.normalizeSeverity(e.severity),
  severity: e.severity,
  evidenceTier: e.evidenceTier,
  message: e.draftAppOutputMessage,
);

c.ScanResult scanResultFromMatch({
  required String scanId,
  required String productName,
  String? productMeta,
  required List<EdcEntry> matched,
  required String? worstSeverity,
  DateTime? scannedAt,
  String? disclaimer,
}) => c.ScanResult(
  scanId: scanId,
  productName: productName,
  productMeta: productMeta,
  scannedAt: scannedAt ?? DateTime.now().toUtc(),
  // No matches → nothing of concern detected.
  overallRisk: matched.isEmpty
      ? c.RiskLevel.low
      : c.normalizeSeverity(worstSeverity),
  detectedChemicals: matched.map(detectedFromEntry).toList(),
  disclaimer: disclaimer,
);

c.ChemicalDetail chemicalDetailFromEntry(EdcEntry e) {
  final healthEffects = <String>[
    if (e.adultHarms != null) e.adultHarms!,
    if (e.pediatricHarms != null) 'Pediatric: ${e.pediatricHarms!}',
  ];
  final regulatory = <String>[
    if (e.guidelineAuthority != null) e.guidelineAuthority!,
    if (e.guidelineValue != null) e.guidelineValue!,
    if (e.referenceRange != null) 'Reference range: ${e.referenceRange!}',
  ].join(' · ');

  return c.ChemicalDetail(
    id: e.id,
    name: e.name,
    risk: c.normalizeSeverity(e.severity),
    chemicalClass: e.mechanism ?? e.abbreviation ?? 'EDC',
    regulatoryStatus: regulatory,
    healthEffects: healthEffects,
    // EdcEntry does not model exposure routes; left empty.
    exposureRoutes: const [],
  );
}
