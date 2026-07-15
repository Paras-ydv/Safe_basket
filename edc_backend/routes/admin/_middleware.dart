import 'dart:async';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/config.dart';
import 'package:postgres/postgres.dart';
import 'package:edc_backend/edc_repository/edc_cache.dart';
import 'package:edc_backend/edc_repository/edc_repository.dart';
import 'package:edc_backend/response_envelope.dart';

Handler middleware(Handler handler) {
  return (context) async {
    // ── TODO: replace allowlist check with real role-based auth ─────────────
    final config = context.read<AppConfig>();
    final userId = context.request.headers['X-User-Id'] ?? '';
    if (userId.isEmpty || !config.adminAllowlist.contains(userId)) {
      return errorResponse(
        'forbidden',
        'You do not have permission to access this resource.',
        statusCode: HttpStatus.forbidden,
      );
    }

    // ── Open DB connection ────────────────────────────────────────────────
    final Connection conn;
    try {
      conn = await config.openConnection()
          .timeout(const Duration(seconds: 5));
    } on TimeoutException {
      return errorResponse(
        'db_unavailable',
        'Database connection timed out.',
        statusCode: HttpStatus.serviceUnavailable,
      );
    } on Exception catch (e) {
      return errorResponse(
        'db_unavailable',
        'Database connection failed: $e',
        statusCode: HttpStatus.serviceUnavailable,
      );
    }
    final repo = EdcRepository(conn);

    // Reuse the shared cache instance primed at startup.
    final cache = context.read<EdcCache>();

    try {
      return await handler
          .use(provider<EdcRepository>((_) => repo))
          .use(provider<EdcCache>((_) => cache))
          .call(context);
    } finally {
      await conn.close();
    }
  };
}
