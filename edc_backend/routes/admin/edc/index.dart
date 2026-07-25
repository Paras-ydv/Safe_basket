import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/edc_repository/edc_cache.dart';
import 'package:edc_backend/edc_repository/edc_repository.dart';
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

  final input = EdcEntryInput.fromJson(body);

  if (input.id == null || input.id!.trim().isEmpty) {
    return errorResponse('validation_error', '"id" is required.');
  }
  if (input.name == null || input.name!.trim().isEmpty) {
    return errorResponse('validation_error', '"name" is required.');
  }
  if (input.severity == null || input.severity!.trim().isEmpty) {
    return errorResponse('validation_error', '"severity" is required.');
  }

  final repo = context.read<EdcRepository>();
  final cache = context.read<EdcCache>();

  try {
    await repo.insert(input);
  } on Exception catch (e) {
    // Postgres unique violation code: 23505
    if (e.toString().contains('23505')) {
      return errorResponse('conflict',
          'An entry with id "${input.id}" already exists.',
          statusCode: HttpStatus.conflict);
    }
    rethrow;
  }

  await cache.refresh();

  final created = await repo.findById(input.id!);
  return okResponse(created, statusCode: HttpStatus.created);
}
