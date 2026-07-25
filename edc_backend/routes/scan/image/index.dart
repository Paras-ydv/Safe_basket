import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mime/mime.dart';
import 'package:edc_matcher/edc_matcher.dart';
import 'package:edc_backend/ocr/ocr_service.dart';
import 'package:edc_backend/ocr/match_service.dart';
import 'package:edc_backend/middleware/rate_limiter.dart';
import 'package:edc_backend/response_envelope.dart';

// 10 OCR calls per user per minute.
final _limiter = RateLimiter(
  maxRequests: 10,
  window: const Duration(minutes: 1),
);

/// In-memory job store: jobId → completed job payload.
/// Keyed by jobId; entries are maps with keys: status, result, error.
/// In production this would be a database table or Redis, but an in-memory
/// map is sufficient for a single-instance dev server.
final Map<String, Map<String, dynamic>> jobStore = {};

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

  // ── Generate a job ID ─────────────────────────────────────────────────────
  final jobId = 'job-${DateTime.now().microsecondsSinceEpoch}';

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

  final bodyBytes = await context.request.bytes();
  final parts = MimeMultipartTransformer(boundary)
      .bind(Stream<List<int>>.value(bodyBytes as List<int>))
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

  // ── OCR + match (synchronous but returned as a completed job) ─────────────
  final ocr = context.read<OcrService>();
  final entries = context.read<List<EdcEntry>>();

  try {
    final cleanedText = await ocr.extractTextFromImage(imageBytes);
    final result = matchAndClassify(cleanedText, entries, requestId: jobId);

    jobStore[jobId] = {
      'status': 'done',
      'result': {
        'request_id': jobId,
        'raw_text': cleanedText,
        'analysis': result.toJson(),
      },
    };
  } on OcrNoTextException {
    jobStore[jobId] = {
      'status': 'failed',
      'error': 'No text detected — image may be blurry or unclear.',
    };
  } on OcrFailedException catch (e) {
    jobStore[jobId] = {
      'status': 'failed',
      'error': e.message,
    };
  }

  // Return the jobId immediately; client polls GET /scan/image/:jobId
  return okResponse({'jobId': jobId});
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
