import 'package:test/test.dart';
import 'package:edc_backend/ocr/ocr_service.dart';

OcrService _service(Future<String> Function(List<int>) override) =>
    OcrService(extractOverride: override);

const _fakeBytes = [0xFF, 0xD8, 0xFF];

void main() {
  group('OcrService.extractTextFromImage', () {
    test('successful extraction returns cleaned text', () async {
      const raw = 'Water\nSodium Lauryl Sulfate\nParabens\nFragrance';
      final result = await _service((_) async => raw.split(RegExp(r'[\n\r,]+'))
              .map((t) => t.trim())
              .where((t) => t.isNotEmpty)
              .join(', '))
          .extractTextFromImage(_fakeBytes);

      expect(result, 'Water, Sodium Lauryl Sulfate, Parabens, Fragrance');
    });

    test('cleans mixed newlines and commas into uniform comma-separated string',
        () async {
      const raw = 'Aqua\nBHA, Triclosan\r\nPerfume';
      final svc = OcrService(extractOverride: (_) async => raw);
      final result = await svc.extractTextFromImage(_fakeBytes);
      expect(result, 'Aqua, BHA, Triclosan, Perfume');
    });

    test('throws OcrNoTextException when override returns empty string',
        () async {
      final svc = OcrService(extractOverride: (_) async {
        throw const OcrNoTextException();
      });
      expect(
        () => svc.extractTextFromImage(_fakeBytes),
        throwsA(isA<OcrNoTextException>()),
      );
    });

    test('throws OcrFailedException when override throws it', () async {
      final svc = OcrService(extractOverride: (_) async {
        throw const OcrFailedException('Tesseract exited with code 1');
      });
      expect(
        () => svc.extractTextFromImage(_fakeBytes),
        throwsA(isA<OcrFailedException>()),
      );
    });
  });
}
