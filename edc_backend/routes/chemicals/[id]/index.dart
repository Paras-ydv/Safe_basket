import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/contracts_mapper.dart';
import 'package:edc_backend/edc_repository/edc_cache.dart';
import 'package:edc_backend/response_envelope.dart';

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

  return okResponse(chemicalDetailFromEntry(entry).toJson());
}
