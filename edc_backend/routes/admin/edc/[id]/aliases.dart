import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/edc_repository/edc_cache.dart';
import 'package:edc_backend/edc_repository/edc_repository.dart';
import 'package:edc_backend/response_envelope.dart';

Future<Response> onRequest(RequestContext context, String id) async {
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

  final alias = body['alias'];
  if (alias is! String || alias.trim().isEmpty) {
    return errorResponse('validation_error', '"alias" must be a non-empty string.');
  }

  final repo = context.read<EdcRepository>();
  final cache = context.read<EdcCache>();

  // Verify the parent entry exists
  final entry = await repo.findById(id);
  if (entry == null) {
    return errorResponse('not_found', 'No entry found with id "$id".',
        statusCode: HttpStatus.notFound);
  }

  final aliasId = await repo.insertAlias(id, alias.trim());
  if (aliasId == null) {
    return errorResponse('conflict',
        'Alias "${alias.trim()}" already exists for entry "$id".',
        statusCode: HttpStatus.conflict);
  }

  await cache.refresh();

  return okResponse({'id': aliasId, 'edc_entry_id': id, 'alias': alias.trim()},
      statusCode: HttpStatus.created);
}
