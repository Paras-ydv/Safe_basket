import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/response_envelope.dart';

Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return errorResponse('METHOD_NOT_ALLOWED', 'Only GET is supported.',
        statusCode: 405);
  }
  return okResponse({'status': 'ok'});
}
