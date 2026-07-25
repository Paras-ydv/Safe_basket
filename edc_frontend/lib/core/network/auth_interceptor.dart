import 'package:dio/dio.dart';

/// Identifies the caller to the backend. Safe_basket expects an `X-User-Id`
/// header (injected by an upstream gateway); until Google Sign-In lands we send
/// a stable per-install device id. When auth is wired, switch [_readUserId] to
/// the signed-in account id (or add a Bearer token here).
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._readUserId);

  final String? Function() _readUserId;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final userId = _readUserId();
    if (userId != null && userId.isNotEmpty) {
      options.headers['X-User-Id'] = userId;
    }
    handler.next(options);
  }
}
