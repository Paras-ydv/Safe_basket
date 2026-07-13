import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/edc_repository/edc_cache.dart';
import 'package:edc_backend/edc_repository/edc_repository.dart';
import 'package:edc_backend/response_envelope.dart';

Future<Response> onRequest(
    RequestContext context, String id, String aliasId) async {
  if (context.request.method != HttpMethod.delete) {
    return errorResponse('method_not_allowed', 'Only DELETE is supported.',
        statusCode: HttpStatus.methodNotAllowed);
  }

  final parsedAliasId = int.tryParse(aliasId);
  if (parsedAliasId == null) {
    return errorResponse('validation_error',
        '"aliasId" must be an integer.');
  }

  final repo = context.read<EdcRepository>();
  final cache = context.read<EdcCache>();

  final deleted = await repo.deleteAlias(parsedAliasId);
  if (!deleted) {
    return errorResponse('not_found', 'No alias found with id "$aliasId".',
        statusCode: HttpStatus.notFound);
  }

  await cache.refresh();

  return okResponse({'deleted': true, 'alias_id': parsedAliasId});
}
