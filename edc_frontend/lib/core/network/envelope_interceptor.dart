import 'package:dio/dio.dart';

/// Unwraps the backend's response envelope `{ data, disclaimer, error }` so
/// repositories can parse `response.data` as the model directly
/// (docs/flutter_app_architecture.md §3, Safe_basket `response_envelope.dart`).
///
/// Error envelopes arrive with a non-2xx status, so they surface through Dio's
/// error path (`mapDioException`) — this interceptor only unwraps the success
/// payload.
class EnvelopeInterceptor extends Interceptor {
  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final data = response.data;
    if (data is Map<String, dynamic> &&
        data.containsKey('data') &&
        data.containsKey('error')) {
      response.data = data['data'];
    }
    handler.next(response);
  }
}
