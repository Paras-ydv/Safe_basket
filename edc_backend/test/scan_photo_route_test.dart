import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_test/dart_frog_test.dart';
import 'package:edc_matcher/edc_matcher.dart';
import 'package:test/test.dart';

import 'package:edc_backend/ocr/ocr_service.dart';
import '../routes/scan/photo/index.dart' as photo_route;

// ── Helpers ───────────────────────────────────────────────────────────────────

(String contentType, List<int> body) _multipartBody(List<int> imageBytes) {
  const boundary = 'testboundary123';
  final lines = <String>[
    '--$boundary',
    'Content-Disposition: form-data; name="image"',
    '',
    String.fromCharCodes(imageBytes),
    '--$boundary--',
  ];
  final bodyBytes = utf8.encode(lines.join('\r\n'));
  return ('multipart/form-data; boundary=$boundary', bodyBytes);
}

/// Stub OcrService that returns fixed text without invoking Tesseract.
OcrService _stubbedOcr(String returnText) =>
    OcrService(extractOverride: (_) async => returnText);

EdcEntry _methylparabenEntry() => EdcEntry(
      id: 'methylparaben',
      name: 'Methylparaben',
      abbreviation: null,
      aliases: ['methylparaben', 'paraben', 'parabens', 'propylparaben', 'butylparaben'],
      commonSources: ['personal care products', 'cosmetics'],
      severity: 'Low-Moderate',
      evidenceTier: 'Limited',
      mechanism: 'Weak estrogenic activity via estrogen receptor binding',
      pediatricHarms: 'Early breast development (limited evidence)',
      adultHarms: 'Hormonal imbalance (weak evidence)',
      draftAppOutputMessage: 'Weak estrogenic activity detected',
      echaSvhcListed: false,
      echaModality: const [],
      echaAssessmentOutcome: EchaAssessmentOutcome.notYetAssessed,
      echaRegulatoryContext: EchaRegulatoryContext.outsideEchaScope,
      oecdEvidenceLevels: const [],
      needsVerification: true,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('POST /scan/photo route handler — EdcCache wiring regression', () {
    test('returns non-empty matches when List<EdcEntry> is populated from cache',
        () async {
      final (contentType, bodyBytes) = _multipartBody([0xFF, 0xD8, 0xFF]);

      final ctx = TestRequestContext(
        path: '/scan/photo',
        method: HttpMethod.post,
        headers: {'content-type': contentType, 'x-request-id': 'test-req-001'},
        body: bodyBytes,
      );

      ctx.provide<OcrService>(_stubbedOcr('Methylparaben'));
      ctx.provide<List<EdcEntry>>([_methylparabenEntry()]);

      final response = await photo_route.onRequest(ctx.context);
      expect(response.statusCode, 200);

      final body = jsonDecode(await response.body()) as Map<String, dynamic>;
      expect(body['error'], isNull);

      final analysis =
          (body['data'] as Map<String, dynamic>)['analysis'] as Map<String, dynamic>;
      final matches = analysis['matches'] as List;

      expect(matches, isNotEmpty,
          reason: 'Empty matches — List<EdcEntry> not wired from EdcCache');
      expect((matches.first as Map<String, dynamic>)['id'], 'methylparaben');
      expect(analysis['worst_severity'], 'Low-Moderate');
    });

    test('returns empty matches when List<EdcEntry> is empty — the broken state',
        () async {
      final (contentType, bodyBytes) = _multipartBody([0xFF, 0xD8, 0xFF]);

      final ctx = TestRequestContext(
        path: '/scan/photo',
        method: HttpMethod.post,
        headers: {'content-type': contentType, 'x-request-id': 'test-req-002'},
        body: bodyBytes,
      );

      ctx.provide<OcrService>(_stubbedOcr('Methylparaben'));
      ctx.provide<List<EdcEntry>>(const []);

      final response = await photo_route.onRequest(ctx.context);
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;
      final analysis =
          (body['data'] as Map<String, dynamic>)['analysis'] as Map<String, dynamic>;

      expect((analysis['matches'] as List), isEmpty);
      expect(analysis['worst_severity'], isNull);
    });
  });
}
