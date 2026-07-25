import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/contracts_mapper.dart';
import 'package:edc_backend/ocr/match_service.dart';
import 'package:edc_backend/product_resolution/product_resolution_service.dart';
import 'package:edc_backend/response_envelope.dart';
import 'package:edc_backend/scan_store.dart';
import 'package:edc_matcher/edc_matcher.dart';

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

  try {
    final product = await service.resolveBarcode(barcode.trim());

    // Run the matcher over the resolved ingredients so a barcode scan returns
    // risk, not just product info.
    final entries = context.read<List<EdcEntry>>();
    final match = matchAndClassify(product.ingredientsText, entries);

    final result = scanResultFromMatch(
      scanId: 'barcode-${barcode.trim()}',
      productName: product.name,
      productMeta: product.brand.isEmpty ? null : product.brand,
      matched: match.matches,
      worstSeverity: match.worstSeverity,
    );

    // Cache so GET /scan/[scanId] can retrieve it after redirect.
    scanResultStore[result.scanId] = result.toJson();

    return okResponse(result.toJson());
  } on ProductNotFoundException {
    return errorResponse('not_found', 'No product found for barcode $barcode.',
        statusCode: HttpStatus.notFound);
  } on ProductNetworkException catch (e) {
    return errorResponse('network_error', e.message,
        statusCode: HttpStatus.badGateway);
  }
}
