import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_matcher/edc_matcher.dart';
import 'package:edc_backend/edc_repository/edc_cache.dart';
import 'package:edc_backend/ocr/match_service.dart';
import 'package:edc_backend/product_resolution/product_resolution.dart';
import 'package:edc_backend/product_resolution/product_resolution_service.dart';
import 'package:edc_backend/response_envelope.dart';

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

  final barcode = body['barcode'];
  if (barcode is! String || barcode.trim().isEmpty) {
    return errorResponse('invalid_barcode', '"barcode" must be a non-empty string.');
  }

  final service = context.read<ProductResolutionService>();

  final ProductResolution product;
  try {
    product = await service.resolveBarcode(barcode.trim());
  } on ProductNotFoundException {
    return errorResponse('not_found', 'No product found for barcode $barcode.',
        statusCode: HttpStatus.notFound);
  } on ProductNetworkException catch (e) {
    return errorResponse('network_error', e.message,
        statusCode: HttpStatus.badGateway);
  }

  final requestId = context.request.headers['x-request-id'] ??
      DateTime.now().microsecondsSinceEpoch.toString();

  final entries = context.read<EdcCache>().entries;
  final analysis = matchAndClassify(
    product.ingredientsText,
    entries,
    requestId: requestId,
  );

  return okResponse({
    'product': product.toJson(),
    'matched_chemicals': analysis.matches
        .map((e) => {
              'id': e.id,
              'name': e.name,
              'severity': e.severity,
              'evidence_tier': e.evidenceTier,
              'draft_app_output_message': e.draftAppOutputMessage,
            })
        .toList(),
    'risk_assessment': {
      'worst_severity': analysis.worstSeverity,
      'match_count': analysis.matches.length,
    },
  });
}
