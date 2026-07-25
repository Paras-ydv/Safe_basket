import 'package:dio/dio.dart';

import '../../../core/models/scan_result.dart';
import '../../../core/network/api_exception.dart';
import 'history_repository.dart';

/// Dio-backed [HistoryRepository] hitting `GET /history`
/// (docs/flutter_app_architecture.md §3).
class ApiHistoryRepository implements HistoryRepository {
  ApiHistoryRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<ScanResult>> recentScans({int limit = 5}) =>
      _fetch(queryParameters: {'limit': limit});

  @override
  Future<List<ScanResult>> allScans() => _fetch();

  Future<List<ScanResult>> _fetch({Map<String, dynamic>? queryParameters}) async {
    try {
      // Response type is dynamic: the raw body is the `{data,...}` envelope
      // (a Map); the EnvelopeInterceptor unwraps `data` (a List) before we read.
      final res = await _dio.get<dynamic>(
        '/history',
        queryParameters: queryParameters,
      );
      final list = (res.data as List<dynamic>?) ?? const [];
      return list
          .map((e) => ScanResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
