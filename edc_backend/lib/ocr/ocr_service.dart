import 'dart:io';
import 'dart:async';

class OcrFailedException implements Exception {
  const OcrFailedException(this.message);
  final String message;
}

class OcrNoTextException implements Exception {
  const OcrNoTextException();
}

class OcrService {
  OcrService({
    this.tesseractPath = r'C:\Program Files\Tesseract-OCR\tesseract.exe',
    this.timeout = const Duration(seconds: 30),
    Future<String> Function(List<int> imageBytes)? extractOverride,
  }) : _extractOverride = extractOverride;

  final String tesseractPath;
  final Duration timeout;
  final Future<String> Function(List<int> imageBytes)? _extractOverride;

  Future<String> extractTextFromImage(List<int> imageBytes) async {
    if (_extractOverride != null) return _extractOverride!(imageBytes);

    final tmpDir = Directory.systemTemp;
    final tmpFile = File(
        '${tmpDir.path}${Platform.pathSeparator}edc_ocr_${DateTime.now().microsecondsSinceEpoch}.jpg');

    try {
      await tmpFile.writeAsBytes(imageBytes);

      final ProcessResult result;
      try {
        result = await Process.run(
          tesseractPath,
          [tmpFile.path, 'stdout', '-l', 'eng', '--psm', '3'],
        ).timeout(timeout);
      } on TimeoutException {
        throw const OcrFailedException('Tesseract timed out.');
      } on ProcessException catch (e) {
        throw OcrFailedException('Tesseract process error: ${e.message}');
      }

      if (result.exitCode != 0) {
        final stderr = (result.stderr as String).trim();
        throw OcrFailedException(
            'Tesseract exited with code ${result.exitCode}: $stderr');
      }

      final raw = (result.stdout as String).trim();
      if (raw.isEmpty) throw const OcrNoTextException();

      return _clean(raw);
    } finally {
      if (await tmpFile.exists()) await tmpFile.delete();
    }
  }

  String _clean(String raw) {
    return raw
        .split(RegExp(r'[\n\r,]+'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .join(', ');
  }
}
