import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

const _disclaimer = 'This is not medical advice. '
    'Consult a qualified health professional before making any decisions '
    'based on this information.';

Response okResponse(Object? data, {int statusCode = 200}) {
  return Response(
    statusCode: statusCode,
    headers: {'content-type': 'application/json'},
    body: jsonEncode({'data': data, 'disclaimer': _disclaimer, 'error': null}),
  );
}

Response errorResponse(String code, String message, {int statusCode = 400}) {
  return Response(
    statusCode: statusCode,
    headers: {'content-type': 'application/json'},
    body: jsonEncode({
      'data': null,
      'disclaimer': null,
      'error': {'code': code, 'message': message},
    }),
  );
}
