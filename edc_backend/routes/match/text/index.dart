import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_matcher/edc_matcher.dart';
import 'package:edc_backend/ocr/match_service.dart';
import 'package:edc_backend/response_envelope.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return errorResponse('method_not_allowed', 'Only POST is supported.',
        statusCode: HttpStatus.methodNotAllowed);
  }

  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } catch (_) {
    return errorResponse('invalid_body', 'Expected a JSON object.');
  }

  final text = body['text'];
  if (text is! String || text.trim().isEmpty) {
    return errorResponse('missing_text', '"text" field is required.',
        statusCode: HttpStatus.unprocessableEntity);
  }

  final requestId = context.request.headers['x-request-id'] ??
      DateTime.now().microsecondsSinceEpoch.toString();

  final entries = context.read<List<EdcEntry>>();
  final result = matchAndClassify(text, entries, requestId: requestId);

  return okResponse({'request_id': requestId, 'analysis': result.toJson()});
}
