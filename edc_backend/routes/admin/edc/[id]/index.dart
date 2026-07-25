import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/edc_repository/edc_cache.dart';
import 'package:edc_backend/edc_repository/edc_repository.dart';
import 'package:edc_backend/response_envelope.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.put) {
    return errorResponse('method_not_allowed', 'Only PUT is supported.',
        statusCode: HttpStatus.methodNotAllowed);
  }

  final Map<String, dynamic> body;
  try {
    body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
  } on FormatException {
    return errorResponse('invalid_body', 'Request body must be valid JSON.');
  }

  if (body.isEmpty) {
    return errorResponse('validation_error', 'Request body must not be empty.');
  }

  final repo = context.read<EdcRepository>();
  final cache = context.read<EdcCache>();

  final input = EdcEntryInput.fromJson(body);
  final updated = await repo.update(id, input);

  if (!updated) {
    return errorResponse('not_found', 'No entry found with id "$id".',
        statusCode: HttpStatus.notFound);
  }

  await cache.refresh();

  final entry = await repo.findById(id);
  return okResponse(entry);
}
