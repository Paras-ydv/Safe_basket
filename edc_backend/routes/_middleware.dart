import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/config.dart';
import 'package:edc_backend/user_id_middleware.dart';

final _config = AppConfig.load();

Handler middleware(Handler handler) {
  return (context) async {
    // ── CORS ────────────────────────────────────────────────────────────────
    // Allow any origin in dev. Tighten to a specific origin in production.
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers':
          'Content-Type, Authorization, X-User-Id, X-Request-Id',
    };

    // Handle preflight OPTIONS request immediately — no further processing.
    if (context.request.method == HttpMethod.options) {
      return Response(headers: corsHeaders);
    }

    // Process the real request, then attach CORS headers to the response.
    final response = await handler
        .use(requestLogger())
        .use(provider<AppConfig>((_) => _config))
        .use(userIdMiddleware)
        .call(context);

    return response.copyWith(
      headers: {...response.headers, ...corsHeaders},
    );
  };
}
