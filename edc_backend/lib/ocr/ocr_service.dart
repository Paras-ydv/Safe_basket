import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OcrFailedException implements Exception {
  const OcrFailedException(this.message);
  final String message;
}

class OcrNoTextException implements Exception {
  const OcrNoTextException();
}

class OcrService {
  OcrService({
    required this.apiKey,
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;
  final Duration timeout;

  static const _visionUrl =
      'https://vision.googleapis.com/v1/images:annotate';

  Future<String> extractTextFromImage(List<int> imageBytes) async {
    final base64Image = base64Encode(imageBytes);

    final http.Response response;
    try {
      response = await _client
          .post(
            // API key is in the URL — do NOT echo the full URL in error
            // messages or logs. Errors below use sanitised strings only.
            Uri.parse('$_visionUrl?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'requests': [
                {
                  'image': {'content': base64Image},
                  'features': [
                    {'type': 'TEXT_DETECTION', 'maxResults': 1}
                  ],
                }
              ]
            }),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const OcrFailedException(
          'Vision API timed out. Please try again.');
    } on Exception catch (e) {
      throw OcrFailedException('Vision API network error: $e');
    }

    if (response.statusCode != 200) {
      // Do not include response.request?.url — it contains the API key.
      throw OcrFailedException(
          'Vision API returned HTTP ${response.statusCode}');
    }

    final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw const OcrFailedException('Vision API returned non-JSON response');
    }

    final responses = body['responses'] as List?;
    if (responses == null || responses.isEmpty) {
      throw const OcrFailedException(
          'Vision API returned empty responses array');
    }

    final first = responses.first as Map<String, dynamic>;
    if (first.containsKey('error')) {
      final err = first['error'] as Map<String, dynamic>;
      throw OcrFailedException(
          err['message'] as String? ?? 'Unknown Vision API error');
    }

    final fullText = (first['fullTextAnnotation']
        as Map<String, dynamic>?)?['text'] as String?;

    if (fullText == null || fullText.trim().isEmpty) {
      throw OcrNoTextException();
    }

    return _clean(fullText);
  }

  String _clean(String raw) {
    return raw
        .split(RegExp(r'[\n\r,]+'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .join(', ');
  }
}
