import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/response_envelope.dart';
import 'package:edc_backend/scan_store.dart';

/// GET /scan/:scanId
/// Retrieves a previously computed scan result by its ID.
/// Results are stored in [scanResultStore] by each scan route after processing.
Future<Response> onRequest(RequestContext context, String scanId) async {
  if (context.request.method != HttpMethod.get) {
    return errorResponse('method_not_allowed', 'Only GET is supported.',
        statusCode: HttpStatus.methodNotAllowed);
  }

  final result = scanResultStore[scanId];

  if (result == null) {
    return errorResponse(
      'not_found',
      'No scan result found for id "$scanId".',
      statusCode: HttpStatus.notFound,
    );
  }

  return okResponse(result);
}
