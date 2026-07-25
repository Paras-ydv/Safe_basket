import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/config.dart';

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers':
      'Content-Type, Authorization, X-User-Id, X-Request-Id',
};

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  final config = AppConfig.load();

  // Wrap every request: return 204 for OPTIONS preflight, attach CORS headers
  // to all other responses. This must sit outside the dart_frog route pipeline
  // so it fires before any route can reject with 405.
  Handler corsHandler = (context) async {
    if (context.request.method == HttpMethod.options) {
      return Response(statusCode: 204, headers: _corsHeaders);
    }
    final response = await handler(context);
    return response.copyWith(
      headers: {...response.headers, ..._corsHeaders},
    );
  };

  return serve(corsHandler, ip, config.port);
}
