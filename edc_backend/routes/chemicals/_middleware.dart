import 'dart:async';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:edc_backend/config.dart';
import 'package:edc_backend/edc_repository/edc_cache.dart';
import 'package:edc_backend/edc_repository/edc_repository.dart';
import 'package:edc_backend/response_envelope.dart';

EdcCache? _cache;

Handler middleware(Handler handler) {
  return (context) async {
    if (_cache == null) {
      final config = context.read<AppConfig>();
      final Connection conn;
      try {
        conn = await config.openConnection().timeout(const Duration(seconds: 5));
      } on TimeoutException {
        return errorResponse('db_unavailable', 'Database connection timed out.',
            statusCode: 503);
      } on Exception catch (e) {
        return errorResponse('db_unavailable', 'Database connection failed: $e',
            statusCode: 503);
      }
      final repo = EdcRepository(conn);
      _cache = EdcCache(() => repo.findAll());
      await _cache!.prime();
    }

    return handler
        .use(provider<EdcCache>((_) => _cache!))
        .call(context);
  };
}
