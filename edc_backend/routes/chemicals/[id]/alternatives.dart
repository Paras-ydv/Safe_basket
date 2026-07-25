import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/edc_repository/edc_cache.dart';
import 'package:edc_backend/response_envelope.dart';
import 'package:edc_contracts/edc_contracts.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return errorResponse('method_not_allowed', 'Only GET is supported.',
        statusCode: HttpStatus.methodNotAllowed);
  }

  final cache = context.read<EdcCache>();
  final entry = cache.entries.where((e) => e.id == id).firstOrNull;

  if (entry == null) {
    return errorResponse('not_found', 'No chemical found with id "$id".',
        statusCode: HttpStatus.notFound);
  }

  final targetRisk = normalizeSeverity(entry.severity);

  // Return entries with strictly lower risk, capped at 5.
  final alternatives = cache.entries
      .where((e) => e.id != id && normalizeSeverity(e.severity).index < targetRisk.index)
      .take(5)
      .map((e) => Alternative(
            id: e.id,
            name: e.name,
            risk: normalizeSeverity(e.severity),
            note: e.draftAppOutputMessage,
          ).toJson())
      .toList();

  return okResponse(alternatives);
}
