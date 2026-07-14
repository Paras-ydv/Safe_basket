import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mime/mime.dart';
import 'package:edc_backend/edc_repository/edc_cache.dart';
import 'package:edc_backend/ocr/ocr_service.dart';
import 'package:edc_backend/ocr/match_service.dart';
import 'package:edc_backend/middleware/rate_limiter.dart';
import 'package:edc_backend/response_envelope.dart';

// 10 OCR calls per user per minute.
// Adjust maxRequests/window before production based on Vision API budget.
final _limiter = RateLimiter(
  maxRequests: 10,
  window: const Duration(minutes: 1),
);

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return errorResponse('method_not_allowed', 'Only POST is supported.',
        statusCode: HttpStatus.methodNotAllowed);
  }

  // ── Rate limit ────────────────────────────────────────────────────────────
  final rateLimitKey = context.request.headers['X-User-Id'] ??
      context.request.headers['x-forwarded-for'] ??
      'unknown';
  if (!_limiter.allow(rateLimitKey)) {
    return errorResponse(
      'rate_limited',
      'Too many requests. Please wait before trying again.',
      statusCode: HttpStatus.tooManyRequests,
    );
  }

  // ── Request ID for log correlation ────────────────────────────────────────
  final requestId = context.request.headers['x-request-id'] ??
      DateTime.now().microsecondsSinceEpoch.toString();

  // ── Parse multipart/form-data ─────────────────────────────────────────────
  final contentType = context.request.headers['content-type'] ?? '';
  if (!contentType.contains('multipart/form-data')) {
    return errorResponse(
        'invalid_content_type', 'Expected multipart/form-data.');
  }

  final boundary = _boundary(contentType);
  if (boundary == null) {
    return errorResponse('invalid_content_type', 'Missing multipart boundary.');
  }

  final parts = MimeMultipartTransformer(boundary)
      .bind(context.request.bytes())
      .asBroadcastStream();

  List<int>? imageBytes;
  await for (final part in parts) {
    final disposition = part.headers['content-disposition'] ?? '';
    if (disposition.contains('name="image"')) {
      imageBytes = await part.fold<List<int>>(
          [], (buf, chunk) => buf..addAll(chunk));
      break;
    }
  }

  if (imageBytes == null || imageBytes.isEmpty) {
    return errorResponse(
        'missing_image', 'Multipart field "image" is required.');
  }

  // ── OCR ───────────────────────────────────────────────────────────────────
  final ocr = context.read<OcrService>();
  final String cleanedText;
  try {
    cleanedText = await ocr.extractTextFromImage(imageBytes);
  } on OcrNoTextException {
    return errorResponse(
        'ocr_no_text', 'No text detected — image may be blurry or unclear.',
        statusCode: HttpStatus.unprocessableEntity);
  } on OcrFailedException catch (e) {
    return errorResponse('ocr_failed', e.message,
        statusCode: HttpStatus.badGateway);
  }

  // ── Match + classify ──────────────────────────────────────────────────────
  final entries = context.read<EdcCache>().entries;
  final result = matchAndClassify(
    cleanedText,
    entries,
    requestId: requestId,
  );

  return okResponse({
    'request_id': requestId,
    'raw_text': cleanedText,
    'analysis': result.toJson(),
  });
}

String? _boundary(String contentType) {
  for (final part in contentType.split(';')) {
    final trimmed = part.trim();
    if (trimmed.startsWith('boundary=')) {
      return trimmed.substring('boundary='.length).replaceAll('"', '');
    }
  }
  return null;
}
