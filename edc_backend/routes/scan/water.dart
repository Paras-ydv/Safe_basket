import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/contracts_mapper.dart';
import 'package:edc_backend/ocr/match_service.dart';
import 'package:edc_backend/response_envelope.dart';
import 'package:edc_backend/scan_store.dart';
import 'package:edc_matcher/edc_matcher.dart';

/// Water source check (`POST /scan/water`).
/// Accepts { sourceType, location } and runs the matcher over the combined
/// text so the same risk pipeline applies to water contaminants.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return errorResponse('method_not_allowed', 'Only POST is supported.',
        statusCode: HttpStatus.methodNotAllowed);
  }

  final Map<String, dynamic> body;
  try {
    body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
  } on FormatException {
    return errorResponse('invalid_body', 'Request body must be valid JSON.');
  }

  final sourceType = body['sourceType'];
  final location = body['location'];

  if (sourceType is! String || sourceType.trim().isEmpty) {
    return errorResponse(
        'invalid_source_type', '"sourceType" must be a non-empty string.');
  }

  final query = [
    sourceType.trim(),
    if (location is String && location.trim().isNotEmpty) location.trim(),
  ].join(' ');

  final entries = context.read<List<EdcEntry>>();
  final match = matchAndClassify(query, entries);

  final result = scanResultFromMatch(
    scanId: 'water-${query.hashCode}',
    productName: sourceType.trim(),
    productMeta: location is String ? location.trim() : null,
    matched: match.matches,
    worstSeverity: match.worstSeverity,
  );

  // Cache so GET /scan/[scanId] can retrieve it after redirect.
  scanResultStore[result.scanId] = result.toJson();

  return okResponse(result.toJson());
}
