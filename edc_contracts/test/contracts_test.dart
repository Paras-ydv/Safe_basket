import 'package:edc_contracts/edc_contracts.dart';
import 'package:test/test.dart';

void main() {
  group('severity normalization', () {
    test('maps known severities', () {
      expect(normalizeSeverity('High'), RiskLevel.high);
      expect(normalizeSeverity('Moderate-High'), RiskLevel.high);
      expect(normalizeSeverity('Acute'), RiskLevel.veryHigh);
      expect(normalizeSeverity('Moderate'), RiskLevel.moderate);
      expect(normalizeSeverity('Low'), RiskLevel.low);
      expect(normalizeSeverity('Non-EDC'), RiskLevel.low);
    });

    test('unknown/null default to moderate', () {
      expect(normalizeSeverity(null), RiskLevel.moderate);
      expect(normalizeSeverity('Weird'), RiskLevel.moderate);
    });

    test('RiskLevel wire round-trips', () {
      for (final level in RiskLevel.values) {
        expect(RiskLevel.fromWire(level.wire), level);
      }
    });
  });

  test('ScanResult round-trips through JSON', () {
    final result = ScanResult(
      scanId: 's1',
      productName: 'Test Lotion',
      productMeta: 'Batch 1',
      scannedAt: DateTime.utc(2026, 7, 16, 10),
      overallRisk: RiskLevel.high,
      detectedChemicals: const [
        DetectedChemical(
          id: 'bpa',
          name: 'Bisphenol A',
          risk: RiskLevel.high,
          severity: 'High',
          evidenceTier: 'Strong',
          message: 'High EDC risk',
        ),
      ],
      disclaimer: 'not medical advice',
    );

    final round = ScanResult.fromJson(result.toJson());
    expect(round.scanId, 's1');
    expect(round.overallRisk, RiskLevel.high);
    expect(round.scannedAt, result.scannedAt);
    expect(round.detectedChemicals.single.name, 'Bisphenol A');
    expect(round.detectedChemicals.single.evidenceTier, 'Strong');
  });

  test('ScanJobStatus parses pending/done', () {
    expect(
      ScanJobStatus.fromJson({'status': 'pending'}).state,
      ScanJobState.pending,
    );
    final done = ScanJobStatus.fromJson({
      'status': 'done',
      'result': {
        'scan_id': 's2',
        'product_name': 'X',
        'scanned_at': DateTime.utc(2026).toIso8601String(),
        'overall_risk': 'low',
        'detected_chemicals': <dynamic>[],
      },
    });
    expect(done.isDone, isTrue);
    expect(done.result!.scanId, 's2');
  });
}
