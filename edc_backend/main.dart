import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/config.dart';
import 'package:edc_backend/edc_repository/edc_cache.dart';
import 'package:edc_backend/edc_repository/edc_repository.dart';

final _config = AppConfig.load();

/// Single EdcCache instance shared by /scan and /admin middleware trees.
/// Exposed so routes/_middleware.dart can provide it via context.
final edcCache = EdcCache(() async {
  final conn = await _config.openConnection();
  try {
    return await EdcRepository(conn).findAll();
  } finally {
    await conn.close();
  }
});

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  // Prime the cache BEFORE the server starts accepting connections.
  // Any failure here crashes startup intentionally — the server is useless
  // without EDC data.
  await edcCache.prime();
  return serve(handler, ip, _config.port);
}
