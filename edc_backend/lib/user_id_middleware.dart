import 'package:dart_frog/dart_frog.dart';

/// Reads the [X-User-Id] header (set by upstream auth gateway) and makes the
/// value available via [RequestContext.read<String?>()].
///
/// Does NOT reject requests with a missing header — individual routes that
/// require a user should call [requireUserId] to enforce presence.
Handler userIdMiddleware(Handler handler) {
  return (context) {
    final userId = context.request.headers['X-User-Id'];
    return handler(context.provide<String?>(() => userId));
  };
}

/// Throws a [MissingUserIdException] if no user-id is present in context.
/// Call this at the top of any route handler that requires authentication.
String requireUserId(RequestContext context) {
  final userId = context.read<String?>();
  if (userId == null || userId.isEmpty) {
    throw MissingUserIdException();
  }
  return userId;
}

class MissingUserIdException implements Exception {
  const MissingUserIdException();
}
