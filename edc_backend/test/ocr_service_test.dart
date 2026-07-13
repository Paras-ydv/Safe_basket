import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:edc_backend/ocr/ocr_service.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

http.Client _visionClient(Map<String, dynamic> responseBody,
    {int statusCode = 200}) {
  return MockClient((_) async => http.Response(
        jsonEncode(responseBody),
        statusCode,
        headers: {'content-type': 'application/json'},
      ));
}

Map<String, dynamic> _visionSuccess(String text) => {
      'responses': [
        {
          'fullTextAnnotation': {'text': text}
        }
      ]
    };

Map<String, dynamic> _visionEmpty() => {
      'responses': [
        <String, dynamic>{}  // no fullTextAnnotation key
      ]
    };

Map<String, dynamic> _visionApiError(String message) => {
      'responses': [
        {
          'error': {'code': 403, 'message': message}
        }
      ]
    };

const _fakeBytes = [0xFF, 0xD8, 0xFF]; // minimal JPEG header bytes
const _apiKey = 'test-key';

OcrService _service(http.Client client) =>
    OcrService(apiKey: _apiKey, client: client);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('OcrService.extractTextFromImage', () {
    test('successful extraction returns cleaned text', () async {
      // Raw Vision output uses newlines between ingredients
      const raw = 'Water\nSodium Lauryl Sulfate\nParabens\nFragrance';
      final client = _visionClient(_visionSuccess(raw));

      final result = await _service(client).extractTextFromImage(_fakeBytes);

      expect(result, 'Water, Sodium Lauryl Sulfate, Parabens, Fragrance');
    });

    test('cleans mixed newlines and commas into uniform comma-separated string',
        () async {
      const raw = 'Aqua\nBHA, Triclosan\r\nPerfume';
      final client = _visionClient(_visionSuccess(raw));

      final result = await _service(client).extractTextFromImage(_fakeBytes);

      expect(result, 'Aqua, BHA, Triclosan, Perfume');
    });

    test('throws OcrNoTextException when image yields no text', () async {
      final client = _visionClient(_visionEmpty());

      expect(
        () => _service(client).extractTextFromImage(_fakeBytes),
        throwsA(isA<OcrNoTextException>()),
      );
    });

    test('throws OcrNoTextException when fullTextAnnotation.text is blank',
        () async {
      final client = _visionClient(_visionSuccess('   \n  '));

      expect(
        () => _service(client).extractTextFromImage(_fakeBytes),
        throwsA(isA<OcrNoTextException>()),
      );
    });

    test('throws OcrFailedException on non-200 HTTP status', () async {
      final client = _visionClient({}, statusCode: 403);

      expect(
        () => _service(client).extractTextFromImage(_fakeBytes),
        throwsA(isA<OcrFailedException>()),
      );
    });

    test('throws OcrFailedException when Vision API returns an error object',
        () async {
      final client =
          _visionClient(_visionApiError('API key not valid. Please pass a valid API key.'));

      expect(
        () => _service(client).extractTextFromImage(_fakeBytes),
        throwsA(
          isA<OcrFailedException>().having(
            (e) => e.message,
            'message',
            contains('API key not valid'),
          ),
        ),
      );
    });

    test('throws OcrFailedException on network exception', () async {
      final client = MockClient((_) async => throw Exception('connection refused'));

      expect(
        () => _service(client).extractTextFromImage(_fakeBytes),
        throwsA(isA<OcrFailedException>()),
      );
    });
  });
}
