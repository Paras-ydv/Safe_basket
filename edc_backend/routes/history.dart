import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/response_envelope.dart';

/// `GET /history` — returns the user's scan history.
///
/// Query params:
///   limit (int, optional) — max number of results to return.
///
/// NOTE: Persistent scan history requires a database. Until the DB is fully
/// wired (migrations run + scan results persisted on each scan call), this
/// returns an empty list so the frontend renders gracefully instead of
/// crashing. Replace the body of this handler with a real DB query once ready.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return errorResponse('method_not_allowed', 'Only GET is supported.',
        statusCode: HttpStatus.methodNotAllowed);
  }

  // Parse optional `limit` query param.
  final limitParam = context.request.uri.queryParameters['limit'];
  final limit = limitParam != null ? int.tryParse(limitParam) : null;

  // TODO: replace with real DB query once EdcRepository is wired.
  // e.g. final repo = context.read<ScanHistoryRepository>();
  //      final scans = await repo.recentScans(userId: userId, limit: limit ?? 20);
  final List<Map<String, dynamic>> scans = [];

  final result = limit != null ? scans.take(limit).toList() : scans;

  return okResponse(result);
}
