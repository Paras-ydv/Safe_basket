import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/contracts_mapper.dart';
import 'package:edc_backend/ocr/match_service.dart';
import 'package:edc_backend/response_envelope.dart';
import 'package:edc_matcher/edc_matcher.dart';

/// Manual product / chemical entry (`POST /scan/manual`). Runs the matcher over
/// free text — no OCR involved.
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

  final query = body['query'];
  if (query is! String || query.trim().isEmpty) {
    return errorResponse('invalid_query', '"query" must be a non-empty string.');
  }

  final entries = context.read<List<EdcEntry>>();
  final match = matchAndClassify(query.trim(), entries);

  final result = scanResultFromMatch(
    scanId: 'manual-${query.trim().hashCode}',
    productName: query.trim(),
    matched: match.matches,
    worstSeverity: match.worstSeverity,
  );

  return okResponse(result.toJson());
}
