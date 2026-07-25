import 'package:dio/dio.dart';

/// Domain-level errors the repositories throw, mapped from transport-level
/// [DioException]s so the UI never sees raw Dio types
/// (docs/flutter_app_architecture.md §4.1).
sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException([super.message = 'No internet connection.']);
}

class TimeoutException extends ApiException {
  const TimeoutException([super.message = 'The request timed out.']);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Please sign in and try again.']);
}

class ServerException extends ApiException {
  const ServerException(this.statusCode, [String? message])
    : super(message ?? 'The server returned an error.');
  final int? statusCode;
}

class UnknownApiException extends ApiException {
  const UnknownApiException([super.message = 'Something went wrong.']);
}

/// Map a Dio transport error to a typed [ApiException].
ApiException mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const TimeoutException();
    case DioExceptionType.connectionError:
      return const NetworkException();
    case DioExceptionType.badResponse:
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) return const UnauthorizedException();
      // Surface the backend envelope's error message when present.
      final data = e.response?.data;
      final message = data is Map<String, dynamic> && data['error'] is Map
          ? (data['error'] as Map)['message'] as String?
          : null;
      return ServerException(status, message);
    case DioExceptionType.cancel:
      return const UnknownApiException('The request was cancelled.');
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return const UnknownApiException();
  }
}
