import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/response_envelope.dart';

/// Sliding-window in-process rate limiter.
///
/// Tracks request timestamps per key (X-User-Id, falling back to remote IP).
/// Evicts stale entries on each check — no background timer needed.
///
/// Limitations (acceptable until Redis is wired in):
///   - State is per-isolate. If Dart Frog spawns multiple isolates each has
///     its own counter. For a single-isolate dev/staging server this is exact.
///   - On restart all counters reset.
///   - TODO: replace _store with a Redis ZSET (ZADD + ZREMRANGEBYSCORE +
///     ZCARD) for multi-instance correctness.
class RateLimiter {
  RateLimiter({required this.maxRequests, required this.window});

  final int maxRequests;
  final Duration window;

  final _store = <String, List<DateTime>>{};

  /// Returns true if the request for [key] is within the allowed rate.
  bool allow(String key) {
    final now = DateTime.now();
    final cutoff = now.subtract(window);
    final timestamps = _store.putIfAbsent(key, () => []);

    timestamps.removeWhere((t) => t.isBefore(cutoff));
    if (timestamps.length >= maxRequests) return false;

    timestamps.add(now);
    return true;
  }
}

/// Dart Frog [Middleware] that applies [limiter] to every request.
/// Key defaults to X-User-Id → x-forwarded-for → 'unknown'.
Middleware rateLimitMiddleware(
  RateLimiter limiter, {
  String Function(Request)? keyExtractor,
}) {
  return (handler) => (context) {
        final key = keyExtractor?.call(context.request) ??
            context.request.headers['X-User-Id'] ??
            context.request.headers['x-forwarded-for'] ??
            'unknown';

        if (!limiter.allow(key)) {
          return Future.value(errorResponse(
            'rate_limited',
            'Too many requests. Please wait before trying again.',
            statusCode: HttpStatus.tooManyRequests,
          ));
        }
        return handler(context);
      };
}
