// Proves the client models parse the Safe_basket backend's snake_case wire
// format (the edc_contracts shape), including the normalized risk enum.

import 'package:edc_app/core/enums/risk_level.dart';
import 'package:edc_app/core/models/scan_result.dart';
import 'package:edc_app/features/chemical/domain/chemical_detail.dart';
import 'package:edc_app/features/notifications/domain/app_notification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ScanResult parses backend snake_case + very_high risk', () {
    final json = {
      'scan_id': 'barcode-123',
      'product_name': 'Sunrise Lotion',
      'product_meta': 'Acme',
      'scanned_at': '2026-07-16T10:00:00.000Z',
      'overall_risk': 'very_high',
      'detected_chemicals': [
        {'id': 'bpa', 'name': 'Bisphenol A', 'risk': 'high'},
      ],
      'disclaimer': 'not medical advice',
    };

    final result = ScanResult.fromJson(json);
    expect(result.scanId, 'barcode-123');
    expect(result.productName, 'Sunrise Lotion');
    expect(result.overallRisk, RiskLevel.veryHigh);
    expect(result.detectedChemicals.single.risk, RiskLevel.high);
    expect(result.disclaimer, 'not medical advice');
  });

  test('ChemicalDetail parses snake_case fields', () {
    final json = {
      'id': 'bpa',
      'name': 'Bisphenol A',
      'risk': 'high',
      'chemical_class': 'estrogenic',
      'regulatory_status': 'ECHA SVHC',
      'health_effects': ['endocrine disruption'],
      'exposure_routes': ['dermal', 'ingestion'],
    };

    final detail = ChemicalDetail.fromJson(json);
    expect(detail.risk, RiskLevel.high);
    expect(detail.chemicalClass, 'estrogenic');
    expect(detail.regulatoryStatus, 'ECHA SVHC');
    expect(detail.healthEffects, ['endocrine disruption']);
    expect(detail.exposureRoutes.length, 2);
  });

  test('AppNotification parses received_at + risk', () {
    final json = {
      'id': 'n1',
      'title': 'High-risk product',
      'body': 'Tap to review',
      'received_at': '2026-07-16T09:00:00.000Z',
      'risk': 'high',
      'read': false,
    };

    final n = AppNotification.fromJson(json);
    expect(n.risk, RiskLevel.high);
    expect(n.read, isFalse);
    expect(n.receivedAt.isUtc, isTrue);
  });

  test('RiskLevel enum uses snake_case wire values', () {
    final json = {
      'scan_id': 's',
      'product_name': 'p',
      'scanned_at': '2026-07-16T10:00:00.000Z',
      'overall_risk': 'very_high',
      'detected_chemicals': <dynamic>[],
    };
    final round = ScanResult.fromJson(ScanResult.fromJson(json).toJson());
    expect(round.overallRisk, RiskLevel.veryHigh);
    // Confirm the wire value is snake_case, not the Dart name.
    expect(ScanResult.fromJson(json).toJson()['overall_risk'], 'very_high');
  });
}
